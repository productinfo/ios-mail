//
//  LabelsDataService.swift
//  Proton Mail - Created on 8/13/15.
//
//
//  Copyright (c) 2019 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import CoreData
import Foundation
import Groot
import PromiseKit
import ProtonCore_Services

enum LabelFetchType: Int {
    case all = 0
    case label = 1
    case folder = 2
    case contactGroup = 3
    case folderWithInbox = 4
    case folderWithOutbox = 5
}

// sourcery: mock
protocol LabelProviderProtocol: AnyObject {
    func makePublisher() -> LabelPublisherProtocol
    func getCustomFolders() -> [LabelEntity]
    func fetchV4Labels(completion: ((Swift.Result<Void, NSError>) -> Void)?)
}

class LabelsDataService: Service {
    let apiService: APIService
    private let userID: UserID
    private let contextProvider: CoreDataContextProviderProtocol
    private let lastUpdatedStore: LastUpdatedStoreProtocol
    private let cacheService: CacheServiceProtocol
    private let viewModeDataSource: ViewModeDataSource

    static let defaultFolderIDs: [String] = [
        Message.Location.inbox.rawValue,
        Message.Location.draft.rawValue,
        Message.HiddenLocation.draft.rawValue,
        Message.Location.sent.rawValue,
        Message.HiddenLocation.sent.rawValue,
        Message.Location.starred.rawValue,
        Message.Location.archive.rawValue,
        Message.Location.spam.rawValue,
        Message.Location.trash.rawValue,
        Message.Location.allmail.rawValue,
        Message.Location.scheduled.rawValue
    ]

    init(api: APIService,
         userID: UserID,
         contextProvider: CoreDataContextProviderProtocol,
         lastUpdatedStore: LastUpdatedStoreProtocol,
         cacheService: CacheServiceProtocol,
         viewModeDataSource: ViewModeDataSource)
    {
        self.apiService = api
        self.userID = userID
        self.contextProvider = contextProvider
        self.lastUpdatedStore = lastUpdatedStore
        self.cacheService = cacheService
        self.viewModeDataSource = viewModeDataSource
    }

    private func cleanLabelsAndFolders(except labelIDToPreserve: [String], context: NSManagedObjectContext) {
        let request = NSFetchRequest<Label>(entityName: Label.Attributes.entityName)
        request.predicate = NSPredicate(
            format: "%K == %@ AND (%K == 1 OR %K == 3) AND (NOT (%K IN %@))",
            Label.Attributes.userID,
            userID.rawValue,
            Label.Attributes.type,
            Label.Attributes.type,
            Label.Attributes.labelID,
            labelIDToPreserve
        )

        guard let labels = try? context.fetch(request) else {
            return
        }

        labels.forEach {
            context.delete($0)
        }
    }

    func cleanUp() {
        contextProvider.performAndWaitOnRootSavingContext { context in
            Label.delete(
                in: context,
                basedOn: NSPredicate(format: "%K == %@", Label.Attributes.userID, self.userID.rawValue)
            )

            ContextLabel.delete(
                in: context,
                basedOn: NSPredicate(format: "%K == %@", ContextLabel.Attributes.userID, self.userID.rawValue)
            )

                _ = context.saveUpstreamIfNeeded()
        }
    }

    static func cleanUpAll() {
            let coreDataService = sharedServices.get(by: CoreDataService.self)
            coreDataService.performAndWaitOnRootSavingContext { context in
                Label.deleteAll(in: context)
                LabelUpdate.deleteAll(in: context)
                ContextLabel.deleteAll(in: context)
            }
    }

    @available(*, deprecated, message: "Prefer the async variant")
    func fetchV4Labels(completion: ((Swift.Result<Void, NSError>) -> Void)? = nil) {
        Task {
            let result: Swift.Result<Void, NSError>
            do {
                try await fetchV4Labels()
                result = .success(())
            } catch {
                result = .failure(error as NSError)
            }

            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }

    /// Get label and folder through v4 api
    func fetchV4Labels() async throws {
        let labelReq = GetV4LabelsRequest(type: .label)
        let folderReq = GetV4LabelsRequest(type: .folder)

        async let labelsResponse = await apiService.perform(request: labelReq, response: GetLabelsResponse())
        async let foldersResponse = await apiService.perform(request: folderReq, response: GetLabelsResponse())

        let userLabelAndFolders = await [labelsResponse, foldersResponse]
            .map(\.1)
            .compactMap(\.labels)
            .joined()
            .map {
                var label = $0
                label["UserID"] = userID.rawValue
                return label
            }

        let allFolders = userLabelAndFolders.appending(Self.defaultFolderIDs.map { ["ID": $0] })

        try contextProvider.performAndWaitOnRootSavingContext { context in
            // to prevent deleted label won't be delete due to pull down to refresh
            let labelIDToPreserve = allFolders.compactMap { $0["ID"] as? String }
            self.cleanLabelsAndFolders(except: labelIDToPreserve, context: context)

            _ = try GRTJSONSerialization.objects(
                withEntityName: Label.Attributes.entityName,
                fromJSONArray: allFolders,
                in: context
            )

            let error = context.saveUpstreamIfNeeded()

            if let error = error {
                throw error
            }
        }
    }

    func fetchV4ContactGroup() -> Promise<Void> {
        return Promise { seal in
            let groupRes = GetV4LabelsRequest(type: .contactGroup)
            self.apiService.perform(request: groupRes, response: GetLabelsResponse()) { _, res in
                if let error = res.error {
                    seal.reject(error)
                    return
                }
                guard var labels = res.labels else {
                    let error = NSError(domain: "", code: -1,
                                        localizedDescription: LocalString._error_no_object)
                    seal.reject(error)
                    return
                }
                for (index, _) in labels.enumerated() {
                    labels[index]["UserID"] = self.userID.rawValue
                }
                // save
                self.contextProvider.performOnRootSavingContext { context in
                    do {
                        _ = try GRTJSONSerialization.objects(withEntityName: Label.Attributes.entityName, fromJSONArray: labels, in: context)
                        let error = context.saveUpstreamIfNeeded()
                        if error == nil {
                            seal.fulfill_()
                        } else {
                            seal.reject(error!)
                        }
                    } catch let ex as NSError {
                        seal.reject(ex)
                    }
                }
            }
        }
    }

    func getMenuFolderLabels() -> [MenuLabel] {
        let labels = self.getAllLabels(of: .all)
        let datas: [MenuLabel] = Array(labels: labels, previousRawData: [])
        let (_, folderItems) = datas.sortoutData()
        return folderItems
    }

    func getAllLabels(of type: LabelFetchType, context: NSManagedObjectContext) -> [Label] {
        let fetchRequest = NSFetchRequest<Label>(entityName: Label.Attributes.entityName)

        if type == .contactGroup, userCachedStatus.isCombineContactOn {
            // in contact group searching, predicate must be consistent with this one
            fetchRequest.predicate = NSPredicate(format: "(%K == 2)", Label.Attributes.type)
        } else {
            fetchRequest.predicate = self.fetchRequestPrecidate(type)
        }

        let context = context
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure("\(error)")
            return []
        }
    }

    func getAllLabels(of type: LabelFetchType) -> [LabelEntity] {
        contextProvider.read { context in
            let labels = getAllLabels(of: type, context: context)
            return labels.map(LabelEntity.init(label:))
        }
    }

    func makePublisher() -> LabelPublisherProtocol {
        let params = LabelPublisher.Parameters(userID: userID)
        return LabelPublisher(parameters: params, dependencies: .init(coreDataService: contextProvider))
    }

    func fetchedResultsController(_ type: LabelFetchType) -> NSFetchedResultsController<Label> {
        let moc = self.contextProvider.mainContext
        let fetchRequest = NSFetchRequest<Label>(entityName: Label.Attributes.entityName)
        fetchRequest.predicate = self.fetchRequestPrecidate(type)

        if type != .contactGroup {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: Label.Attributes.order, ascending: true)]
        } else {
            let strComp = NSSortDescriptor(key: Label.Attributes.name,
                                           ascending: true,
                                           selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            fetchRequest.sortDescriptors = [strComp]
        }
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    }

    private func fetchRequestPrecidate(_ type: LabelFetchType) -> NSPredicate {
        switch type {
        case .all:
            return NSPredicate(format: "(labelID MATCHES %@) AND ((%K == 1) OR (%K == 3)) AND (%K == %@)", "(?!^\\d+$)^.+$", Label.Attributes.type, Label.Attributes.type, Label.Attributes.userID, self.userID.rawValue)
        case .folder:
            return NSPredicate(format: "(labelID MATCHES %@) AND (%K == 3) AND (%K == %@)", "(?!^\\d+$)^.+$", Label.Attributes.type, Label.Attributes.userID, self.userID.rawValue)
        case .folderWithInbox:
            // 0 - inbox, 6 - archive, 3 - trash, 4 - spam
            let defaults = NSPredicate(format: "labelID IN %@", [0, 6, 3, 4])
            // custom folders like in previous (LabelFetchType.folder) case
            let folder = NSPredicate(format: "(labelID MATCHES %@) AND (%K == 3) AND (%K == %@)", "(?!^\\d+$)^.+$", Label.Attributes.type, Label.Attributes.userID, self.userID.rawValue)

            return NSCompoundPredicate(orPredicateWithSubpredicates: [defaults, folder])
        case .folderWithOutbox:
            // 7 - sent, 6 - archive, 3 - trash
            let defaults = NSPredicate(format: "labelID IN %@", [6, 7, 3])
            // custom folders like in previous (LabelFetchType.folder) case
            let folder = NSPredicate(format: "(labelID MATCHES %@) AND (%K == 3) AND (%K == %@)", "(?!^\\d+$)^.+$", Label.Attributes.type, Label.Attributes.userID, self.userID.rawValue)

            return NSCompoundPredicate(orPredicateWithSubpredicates: [defaults, folder])
        case .label:
            return NSPredicate(format: "(labelID MATCHES %@) AND (%K == 1) AND (%K == %@)", "(?!^\\d+$)^.+$", Label.Attributes.type, Label.Attributes.userID, self.userID.rawValue)
        case .contactGroup:
            return NSPredicate(format: "(%K == 2) AND (%K == %@) AND (%K == 0)", Label.Attributes.type, Label.Attributes.userID, self.userID.rawValue, Label.Attributes.isSoftDeleted)
        }
    }

    func addNewLabel(_ response: [String: Any]?) {
        if var label = response {
            contextProvider.performAndWaitOnRootSavingContext { context in
                do {
                    label["UserID"] = self.userID.rawValue
                    try GRTJSONSerialization.object(withEntityName: Label.Attributes.entityName, fromJSONDictionary: label, in: context)
                    _ = context.saveUpstreamIfNeeded()
                } catch {}
            }
        }
    }

    func labelFetchedController(by labelID: LabelID) -> NSFetchedResultsController<Label> {
        let context = self.contextProvider.mainContext
        return Label.labelFetchController(for: labelID.rawValue, inManagedObjectContext: context)
    }

    func label(by labelID: LabelID) -> LabelEntity? {
        return contextProvider.read { context in
            if let label = Label.labelForLabelID(labelID.rawValue, inManagedObjectContext: context) {
                return LabelEntity(label: label)
            } else {
                return nil
            }
        }
    }

    func label(name: String) -> LabelEntity? {
        return contextProvider.read { context in
            if let label = Label.labelForLabelName(name, inManagedObjectContext: context) {
                return LabelEntity(label: label)
            } else {
                return nil
            }
        }
    }

    func lastUpdate(by labelID: LabelID, userID: UserID? = nil) -> LabelCountEntity? {
        let viewMode = viewModeDataSource.viewMode
        let id = userID ?? self.userID
        return self.lastUpdatedStore.lastUpdate(by: labelID, userID: id, type: viewMode)
    }

    func unreadCount(by labelID: LabelID) -> Int {
        let viewMode = viewModeDataSource.viewMode
        return lastUpdatedStore.unreadCount(by: labelID, userID: self.userID, type: viewMode)
    }

    func getUnreadCounts(by labelIDs: [LabelID]) -> [String: Int] {
        let viewMode = viewModeDataSource.viewMode
        return lastUpdatedStore.getUnreadCounts(by: labelIDs, userID: self.userID, type: viewMode)
    }

    func resetCounter(labelID: LabelID)
    {
        lastUpdatedStore.resetCounter(labelID: labelID, userID: userID)
    }

    func createNewLabel(name: String,
                        color: String,
                        type: PMLabelType = .label,
                        parentID: LabelID? = nil,
                        notify: Bool = true,
                        objectID: String? = nil,
                        completion: ((String?, NSError?) -> Void)?)
    {
        let route = CreateLabelRequest(name: name,
                                       color: color,
                                       type: type,
                                       parentID: parentID?.rawValue,
                                       notify: notify,
                                       expanded: true)
        self.apiService.perform(request: route, response: CreateLabelRequestResponse()) { _, response in
            if let err = response.error {
                completion?(nil, err.toNSError)
            } else {
                let ID = response.label?["ID"] as? String
                let objectID = objectID ?? ""
                if let labelResponse = response.label {
                    self.cacheService.addNewLabel(serverResponse: labelResponse, objectID: objectID, completion: nil)
                }
                completion?(ID, nil)
            }
        }
    }

    func updateLabel(_ label: LabelEntity,
                     name: String,
                     color: String,
                     parentID: LabelID?,
                     notify: Bool, completion: ((NSError?) -> Void)?)
    {
        let api = UpdateLabelRequest(id: label.labelID.rawValue,
                                     name: name,
                                     color: color,
                                     parentID: parentID?.rawValue,
                                     notify: notify)
        self.apiService.perform(request: api, response: UpdateLabelRequestResponse()) { _, response in
            if let err = response.error {
                completion?(err.toNSError)
            } else {
                guard let labelDic = response.label else {
                    let error = NSError(domain: "", code: -1,
                                        localizedDescription: LocalString._error_no_object)
                    completion?(error)
                    return
                }
                self.cacheService.updateLabel(serverReponse: labelDic) {
                    completion?(nil)
                }
            }
        }
    }

    /// Send api to delete label and remove related labels from the DB
    /// - Parameters:
    ///   - label: The label want to be deleted
    ///   - subLabelIDs: Object ids array of child labels
    ///   - completion: completion
    func deleteLabel(_ label: LabelEntity,
                     subLabels: [LabelEntity] = [],
                     completion: (() -> Void)?)
    {
        let api = DeleteLabelRequest(lable_id: label.labelID.rawValue)
        self.apiService.perform(request: api, response: VoidResponse()) { _, _ in
        }
        let ids = subLabels.map{$0.objectID.rawValue} + [label.objectID.rawValue]
        self.cacheService.deleteLabels(objectIDs: ids) {
            completion?()
        }
    }
}

extension LabelsDataService: LabelProviderProtocol {
    func getCustomFolders() -> [LabelEntity] {
        getAllLabels(of: .folder)
    }
}
