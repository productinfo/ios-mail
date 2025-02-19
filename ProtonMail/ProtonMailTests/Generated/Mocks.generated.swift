// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import BackgroundTasks
import CoreData
import LocalAuthentication
import Network
import ProtonCore_Crypto
import ProtonCore_Environment
import ProtonCore_Keymaker
import ProtonCore_PaymentsUI
import ProtonCore_Services
import ProtonCore_TestingToolkit

import class PromiseKit.Promise
import class ProtonCore_DataModel.UserInfo

@testable import ProtonMail

class MockAppRatingStatusProvider: AppRatingStatusProvider {
    @FuncStub(MockAppRatingStatusProvider.isAppRatingEnabled, initialReturn: Bool()) var isAppRatingEnabledStub
    func isAppRatingEnabled() -> Bool {
        isAppRatingEnabledStub()
    }

    @FuncStub(MockAppRatingStatusProvider.setIsAppRatingEnabled) var setIsAppRatingEnabledStub
    func setIsAppRatingEnabled(_ value: Bool) {
        setIsAppRatingEnabledStub(value)
    }

    @FuncStub(MockAppRatingStatusProvider.hasAppRatingBeenShownInCurrentVersion, initialReturn: Bool()) var hasAppRatingBeenShownInCurrentVersionStub
    func hasAppRatingBeenShownInCurrentVersion() -> Bool {
        hasAppRatingBeenShownInCurrentVersionStub()
    }

    @FuncStub(MockAppRatingStatusProvider.setAppRatingAsShownInCurrentVersion) var setAppRatingAsShownInCurrentVersionStub
    func setAppRatingAsShownInCurrentVersion() {
        setAppRatingAsShownInCurrentVersionStub()
    }

}

class MockAppRatingWrapper: AppRatingWrapper {
    @FuncStub(MockAppRatingWrapper.requestAppRating) var requestAppRatingStub
    func requestAppRating() {
        requestAppRatingStub()
    }

}

class MockAutoDeleteSpamAndTrashDaysProvider: AutoDeleteSpamAndTrashDaysProvider {
    @PropertyStub(\MockAutoDeleteSpamAndTrashDaysProvider.isAutoDeleteImplicitlyDisabled, initialGet: Bool()) var isAutoDeleteImplicitlyDisabledStub
    var isAutoDeleteImplicitlyDisabled: Bool {
        isAutoDeleteImplicitlyDisabledStub()
    }

    @PropertyStub(\MockAutoDeleteSpamAndTrashDaysProvider.isAutoDeleteEnabled, initialGet: Bool()) var isAutoDeleteEnabledStub
    var isAutoDeleteEnabled: Bool {
        get {
            isAutoDeleteEnabledStub()
        }
        set {
            isAutoDeleteEnabledStub(newValue)
        }
    }

}

class MockBGTaskSchedulerProtocol: BGTaskSchedulerProtocol {
    @ThrowingFuncStub(MockBGTaskSchedulerProtocol.submit) var submitStub
    func submit(_ taskRequest: BGTaskRequest) throws {
        try submitStub(taskRequest)
    }

    @FuncStub(MockBGTaskSchedulerProtocol.register, initialReturn: Bool()) var registerStub
    func register(forTaskWithIdentifier identifier: String, using queue: DispatchQueue?, launchHandler: @escaping (BGTask) -> Void) -> Bool {
        registerStub(identifier, queue, launchHandler)
    }

    @FuncStub(MockBGTaskSchedulerProtocol.cancel) var cancelStub
    func cancel(taskRequestWithIdentifier identifier: String) {
        cancelStub(identifier)
    }

}

class MockBackendConfigurationCacheProtocol: BackendConfigurationCacheProtocol {
    @FuncStub(MockBackendConfigurationCacheProtocol.readEnvironment, initialReturn: nil) var readEnvironmentStub
    func readEnvironment() -> Environment? {
        readEnvironmentStub()
    }

}

class MockBlockedSenderCacheUpdaterDelegate: BlockedSenderCacheUpdaterDelegate {
    @FuncStub(MockBlockedSenderCacheUpdaterDelegate.blockedSenderCacheUpdater) var blockedSenderCacheUpdaterStub
    func blockedSenderCacheUpdater(_ blockedSenderCacheUpdater: BlockedSenderCacheUpdater, didEnter newState: BlockedSenderCacheUpdater.State) {
        blockedSenderCacheUpdaterStub(blockedSenderCacheUpdater, newState)
    }

}

class MockBlockedSenderFetchStatusProviderProtocol: BlockedSenderFetchStatusProviderProtocol {
    @FuncStub(MockBlockedSenderFetchStatusProviderProtocol.checkIfBlockedSendersAreFetched, initialReturn: Bool()) var checkIfBlockedSendersAreFetchedStub
    func checkIfBlockedSendersAreFetched(userID: UserID) -> Bool {
        checkIfBlockedSendersAreFetchedStub(userID)
    }

    @FuncStub(MockBlockedSenderFetchStatusProviderProtocol.markBlockedSendersAsFetched) var markBlockedSendersAsFetchedStub
    func markBlockedSendersAsFetched(_ fetched: Bool, userID: UserID) {
        markBlockedSendersAsFetchedStub(fetched, userID)
    }

}

class MockBundleType: BundleType {
    @PropertyStub(\MockBundleType.preferredLocalizations, initialGet: [String]()) var preferredLocalizationsStub
    var preferredLocalizations: [String] {
        preferredLocalizationsStub()
    }

    @FuncStub(MockBundleType.setLanguage) var setLanguageStub
    func setLanguage(with code: String, isLanguageRTL: Bool) {
        setLanguageStub(code, isLanguageRTL)
    }

}

class MockCacheServiceProtocol: CacheServiceProtocol {
    @FuncStub(MockCacheServiceProtocol.addNewLabel) var addNewLabelStub
    func addNewLabel(serverResponse: [String: Any], objectID: String?, completion: (() -> Void)?) {
        addNewLabelStub(serverResponse, objectID, completion)
    }

    @FuncStub(MockCacheServiceProtocol.updateLabel) var updateLabelStub
    func updateLabel(serverReponse: [String: Any], completion: (() -> Void)?) {
        updateLabelStub(serverReponse, completion)
    }

    @FuncStub(MockCacheServiceProtocol.deleteLabels) var deleteLabelsStub
    func deleteLabels(objectIDs: [NSManagedObjectID], completion: (() -> Void)?) {
        deleteLabelsStub(objectIDs, completion)
    }

    @FuncStub(MockCacheServiceProtocol.updateContactDetail) var updateContactDetailStub
    func updateContactDetail(serverResponse: [String: Any], completion: ((ContactEntity?, NSError?) -> Void)?) {
        updateContactDetailStub(serverResponse, completion)
    }

    @ThrowingFuncStub(MockCacheServiceProtocol.parseMessagesResponse) var parseMessagesResponseStub
    func parseMessagesResponse(labelID: LabelID, isUnread: Bool, response: [String: Any], idsOfMessagesBeingSent: [String]) throws {
        try parseMessagesResponseStub(labelID, isUnread, response, idsOfMessagesBeingSent)
    }

    @FuncStub(MockCacheServiceProtocol.updateExpirationOffset) var updateExpirationOffsetStub
    func updateExpirationOffset(of messageObjectID: NSManagedObjectID, expirationTime: TimeInterval, pwd: String, pwdHint: String, completion: (() -> Void)?) {
        updateExpirationOffsetStub(messageObjectID, expirationTime, pwd, pwdHint, completion)
    }

}

class MockCachedUserDataProvider: CachedUserDataProvider {
    @FuncStub(MockCachedUserDataProvider.set) var setStub
    func set(disconnectedUsers: [UsersManager.DisconnectedUserHandle]) {
        setStub(disconnectedUsers)
    }

    @FuncStub(MockCachedUserDataProvider.fetchDisconnectedUsers, initialReturn: [UsersManager.DisconnectedUserHandle]()) var fetchDisconnectedUsersStub
    func fetchDisconnectedUsers() -> [UsersManager.DisconnectedUserHandle] {
        fetchDisconnectedUsersStub()
    }

}

class MockConnectionMonitor: ConnectionMonitor {
    @PropertyStub(\MockConnectionMonitor.currentPathProtocol, initialGet: nil) var currentPathProtocolStub
    var currentPathProtocol: NWPathProtocol? {
        currentPathProtocolStub()
    }

    @PropertyStub(\MockConnectionMonitor.pathUpdateClosure, initialGet: nil) var pathUpdateClosureStub
    var pathUpdateClosure: ((_ newPath: NWPathProtocol) -> Void)? {
        get {
            pathUpdateClosureStub()
        }
        set {
            pathUpdateClosureStub(newValue)
        }
    }

    @FuncStub(MockConnectionMonitor.start) var startStub
    func start(queue: DispatchQueue) {
        startStub(queue)
    }

    @FuncStub(MockConnectionMonitor.cancel) var cancelStub
    func cancel() {
        cancelStub()
    }

}

class MockConnectionStatusReceiver: ConnectionStatusReceiver {
    @FuncStub(MockConnectionStatusReceiver.connectionStatusHasChanged) var connectionStatusHasChangedStub
    func connectionStatusHasChanged(newStatus: ConnectionStatus) {
        connectionStatusHasChangedStub(newStatus)
    }

}

class MockContactCacheStatusProtocol: ContactCacheStatusProtocol {
    @PropertyStub(\MockContactCacheStatusProtocol.contactsCached, initialGet: Int()) var contactsCachedStub
    var contactsCached: Int {
        get {
            contactsCachedStub()
        }
        set {
            contactsCachedStub(newValue)
        }
    }

}

class MockContactDataServiceProtocol: ContactDataServiceProtocol {
    @FuncStub(MockContactDataServiceProtocol.queueUpdate) var queueUpdateStub
    func queueUpdate(objectID: NSManagedObjectID, cardDatas: [CardData], newName: String, emails: [ContactEditEmail], completion: ContactUpdateComplete?) {
        queueUpdateStub(objectID, cardDatas, newName, emails, completion)
    }

    @FuncStub(MockContactDataServiceProtocol.queueAddContact, initialReturn: nil) var queueAddContactStub
    func queueAddContact(cardDatas: [CardData], name: String, emails: [ContactEditEmail], importedFromDevice: Bool) -> NSError? {
        queueAddContactStub(cardDatas, name, emails, importedFromDevice)
    }

    @FuncStub(MockContactDataServiceProtocol.queueDelete) var queueDeleteStub
    func queueDelete(objectID: NSManagedObjectID, completion: ContactDeleteComplete?) {
        queueDeleteStub(objectID, completion)
    }

}

class MockContactGroupsProviderProtocol: ContactGroupsProviderProtocol {
    @FuncStub(MockContactGroupsProviderProtocol.getAllContactGroupVOs, initialReturn: [ContactGroupVO]()) var getAllContactGroupVOsStub
    func getAllContactGroupVOs() -> [ContactGroupVO] {
        getAllContactGroupVOsStub()
    }

}

class MockConversationCoordinatorProtocol: ConversationCoordinatorProtocol {
    @PropertyStub(\MockConversationCoordinatorProtocol.pendingActionAfterDismissal, initialGet: nil) var pendingActionAfterDismissalStub
    var pendingActionAfterDismissal: (() -> Void)? {
        get {
            pendingActionAfterDismissalStub()
        }
        set {
            pendingActionAfterDismissalStub(newValue)
        }
    }

    @FuncStub(MockConversationCoordinatorProtocol.handle) var handleStub
    func handle(navigationAction: ConversationNavigationAction) {
        handleStub(navigationAction)
    }

}

class MockConversationProvider: ConversationProvider {
    @FuncStub(MockConversationProvider.fetchConversationCounts) var fetchConversationCountsStub
    func fetchConversationCounts(addressID: String?, completion: ((Result<Void, Error>) -> Void)?) {
        fetchConversationCountsStub(addressID, completion)
    }

    @FuncStub(MockConversationProvider.fetchConversations) var fetchConversationsStub
    func fetchConversations(for labelID: LabelID, before timestamp: Int, unreadOnly: Bool, shouldReset: Bool, completion: ((Result<Void, Error>) -> Void)?) {
        fetchConversationsStub(labelID, timestamp, unreadOnly, shouldReset, completion)
    }

    @FuncStub(MockConversationProvider.fetchConversation) var fetchConversationStub
    func fetchConversation(with conversationID: ConversationID, includeBodyOf messageID: MessageID?, callOrigin: String?, completion: @escaping (Result<Conversation, Error>) -> Void) {
        fetchConversationStub(conversationID, messageID, callOrigin, completion)
    }

    @FuncStub(MockConversationProvider.deleteConversations) var deleteConversationsStub
    func deleteConversations(with conversationIDs: [ConversationID], labelID: LabelID, completion: ((Result<Void, Error>) -> Void)?) {
        deleteConversationsStub(conversationIDs, labelID, completion)
    }

    @FuncStub(MockConversationProvider.markAsRead) var markAsReadStub
    func markAsRead(conversationIDs: [ConversationID], labelID: LabelID, completion: ((Result<Void, Error>) -> Void)?) {
        markAsReadStub(conversationIDs, labelID, completion)
    }

    @FuncStub(MockConversationProvider.markAsUnread) var markAsUnreadStub
    func markAsUnread(conversationIDs: [ConversationID], labelID: LabelID, completion: ((Result<Void, Error>) -> Void)?) {
        markAsUnreadStub(conversationIDs, labelID, completion)
    }

    @FuncStub(MockConversationProvider.label) var labelStub
    func label(conversationIDs: [ConversationID], as labelID: LabelID, completion: ((Result<Void, Error>) -> Void)?) {
        labelStub(conversationIDs, labelID, completion)
    }

    @FuncStub(MockConversationProvider.unlabel) var unlabelStub
    func unlabel(conversationIDs: [ConversationID], as labelID: LabelID, completion: ((Result<Void, Error>) -> Void)?) {
        unlabelStub(conversationIDs, labelID, completion)
    }

    @FuncStub(MockConversationProvider.move) var moveStub
    func move(conversationIDs: [ConversationID], from previousFolderLabel: LabelID, to nextFolderLabel: LabelID, callOrigin: String?, completion: ((Result<Void, Error>) -> Void)?) {
        moveStub(conversationIDs, previousFolderLabel, nextFolderLabel, callOrigin, completion)
    }

    @FuncStub(MockConversationProvider.fetchLocalConversations, initialReturn: [Conversation]()) var fetchLocalConversationsStub
    func fetchLocalConversations(withIDs selected: NSMutableSet, in context: NSManagedObjectContext) -> [Conversation] {
        fetchLocalConversationsStub(selected, context)
    }

    @FuncStub(MockConversationProvider.findConversationIDsToApplyLabels, initialReturn: [ConversationID]()) var findConversationIDsToApplyLabelsStub
    func findConversationIDsToApplyLabels(conversations: [ConversationEntity], labelID: LabelID) -> [ConversationID] {
        findConversationIDsToApplyLabelsStub(conversations, labelID)
    }

    @FuncStub(MockConversationProvider.findConversationIDSToRemoveLabels, initialReturn: [ConversationID]()) var findConversationIDSToRemoveLabelsStub
    func findConversationIDSToRemoveLabels(conversations: [ConversationEntity], labelID: LabelID) -> [ConversationID] {
        findConversationIDSToRemoveLabelsStub(conversations, labelID)
    }

}

class MockConversationStateProviderProtocol: ConversationStateProviderProtocol {
    @PropertyStub(\MockConversationStateProviderProtocol.viewMode, initialGet: .conversation) var viewModeStub
    var viewMode: ViewMode {
        get {
            viewModeStub()
        }
        set {
            viewModeStub(newValue)
        }
    }

    @FuncStub(MockConversationStateProviderProtocol.add) var addStub
    func add(delegate: ConversationStateServiceDelegate) {
        addStub(delegate)
    }

}

class MockCopyMessageUseCase: CopyMessageUseCase {
    @ThrowingFuncStub(MockCopyMessageUseCase.execute, initialReturn: .crash) var executeStub
    func execute(parameters: CopyMessage.Parameters) throws -> CopyOutput {
        try executeStub(parameters)
    }

}

class MockDarkModeCacheProtocol: DarkModeCacheProtocol {
    @PropertyStub(\MockDarkModeCacheProtocol.darkModeStatus, initialGet: .followSystem) var darkModeStatusStub
    var darkModeStatus: DarkModeStatus {
        get {
            darkModeStatusStub()
        }
        set {
            darkModeStatusStub(newValue)
        }
    }

}

class MockDeviceRegistrationUseCase: DeviceRegistrationUseCase {
    @FuncStub(MockDeviceRegistrationUseCase.execute, initialReturn: [DeviceRegistrationResult]()) var executeStub
    func execute(sessionIDs: [String], deviceToken: String, publicKey: String) -> [DeviceRegistrationResult] {
        executeStub(sessionIDs, deviceToken, publicKey)
    }

}

class MockFailedPushDecryptionMarker: FailedPushDecryptionMarker {
    @FuncStub(MockFailedPushDecryptionMarker.markPushNotificationDecryptionFailure) var markPushNotificationDecryptionFailureStub
    func markPushNotificationDecryptionFailure() {
        markPushNotificationDecryptionFailureStub()
    }

}

class MockFailedPushDecryptionProvider: FailedPushDecryptionProvider {
    @PropertyStub(\MockFailedPushDecryptionProvider.hadPushNotificationDecryptionFailed, initialGet: Bool()) var hadPushNotificationDecryptionFailedStub
    var hadPushNotificationDecryptionFailed: Bool {
        hadPushNotificationDecryptionFailedStub()
    }

    @FuncStub(MockFailedPushDecryptionProvider.clearPushNotificationDecryptionFailure) var clearPushNotificationDecryptionFailureStub
    func clearPushNotificationDecryptionFailure() {
        clearPushNotificationDecryptionFailureStub()
    }

}

class MockFeatureFlagCache: FeatureFlagCache {
    @FuncStub(MockFeatureFlagCache.storeFeatureFlags) var storeFeatureFlagsStub
    func storeFeatureFlags(_ flags: SupportedFeatureFlags, for userID: UserID) {
        storeFeatureFlagsStub(flags, userID)
    }

    @FuncStub(MockFeatureFlagCache.featureFlags, initialReturn: SupportedFeatureFlags()) var featureFlagsStub
    func featureFlags(for userID: UserID) -> SupportedFeatureFlags {
        featureFlagsStub(userID)
    }

}

class MockFeatureFlagsDownloadServiceProtocol: FeatureFlagsDownloadServiceProtocol {
    @FuncStub(MockFeatureFlagsDownloadServiceProtocol.updateFeatureFlag) var updateFeatureFlagStub
    func updateFeatureFlag(_ key: FeatureFlagKey, value: Any, completion: @escaping (Error?) -> Void) {
        updateFeatureFlagStub(key, value, completion)
    }

}

class MockImageProxyDelegate: ImageProxyDelegate {
    @FuncStub(MockImageProxyDelegate.imageProxy) var imageProxyStub
    func imageProxy(_ imageProxy: ImageProxy, output: ImageProxyOutput) {
        imageProxyStub(imageProxy, output)
    }

}

class MockIncomingDefaultServiceProtocol: IncomingDefaultServiceProtocol {
    @FuncStub(MockIncomingDefaultServiceProtocol.fetchAll) var fetchAllStub
    func fetchAll(location: IncomingDefaultsAPI.Location, completion: @escaping (Error?) -> Void) {
        fetchAllStub(location, completion)
    }

    @ThrowingFuncStub(MockIncomingDefaultServiceProtocol.save) var saveStub
    func save(dto: IncomingDefaultDTO) throws {
        try saveStub(dto)
    }

    @ThrowingFuncStub(MockIncomingDefaultServiceProtocol.performLocalUpdate) var performLocalUpdateStub
    func performLocalUpdate(emailAddress: String, newLocation: IncomingDefaultsAPI.Location) throws {
        try performLocalUpdateStub(emailAddress, newLocation)
    }

    @FuncStub(MockIncomingDefaultServiceProtocol.performRemoteUpdate) var performRemoteUpdateStub
    func performRemoteUpdate(emailAddress: String, newLocation: IncomingDefaultsAPI.Location, completion: @escaping (Error?) -> Void) {
        performRemoteUpdateStub(emailAddress, newLocation, completion)
    }

    @ThrowingFuncStub(MockIncomingDefaultServiceProtocol.softDelete) var softDeleteStub
    func softDelete(query: IncomingDefaultService.Query) throws {
        try softDeleteStub(query)
    }

    @ThrowingFuncStub(MockIncomingDefaultServiceProtocol.hardDelete) var hardDeleteStub
    func hardDelete(query: IncomingDefaultService.Query?, includeSoftDeleted: Bool) throws {
        try hardDeleteStub(query, includeSoftDeleted)
    }

    @FuncStub(MockIncomingDefaultServiceProtocol.performRemoteDeletion) var performRemoteDeletionStub
    func performRemoteDeletion(emailAddress: String, completion: @escaping (Error?) -> Void) {
        performRemoteDeletionStub(emailAddress, completion)
    }

}

class MockInternetConnectionStatusProviderProtocol: InternetConnectionStatusProviderProtocol {
    @PropertyStub(\MockInternetConnectionStatusProviderProtocol.status, initialGet: .initialize) var statusStub
    var status: ConnectionStatus {
        statusStub()
    }

    @FuncStub(MockInternetConnectionStatusProviderProtocol.apiCallIsSucceeded) var apiCallIsSucceededStub
    func apiCallIsSucceeded() {
        apiCallIsSucceededStub()
    }

    @FuncStub(MockInternetConnectionStatusProviderProtocol.register) var registerStub
    func register(receiver: ConnectionStatusReceiver, fireWhenRegister: Bool) {
        registerStub(receiver, fireWhenRegister)
    }

    @FuncStub(MockInternetConnectionStatusProviderProtocol.unRegister) var unRegisterStub
    func unRegister(receiver: ConnectionStatusReceiver) {
        unRegisterStub(receiver)
    }

    @FuncStub(MockInternetConnectionStatusProviderProtocol.updateNewStatusToAll) var updateNewStatusToAllStub
    func updateNewStatusToAll(_ newStatus: ConnectionStatus) {
        updateNewStatusToAllStub(newStatus)
    }

}

class MockLAContextProtocol: LAContextProtocol {
    @FuncStub(MockLAContextProtocol.canEvaluatePolicy, initialReturn: Bool()) var canEvaluatePolicyStub
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluatePolicyStub(policy, error)
    }

    @FuncStub(MockLAContextProtocol.evaluatePolicy) var evaluatePolicyStub
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        evaluatePolicyStub(policy, localizedReason, reply)
    }

}

class MockLabelManagerRouterProtocol: LabelManagerRouterProtocol {
    @FuncStub(MockLabelManagerRouterProtocol.navigateToLabelEdit) var navigateToLabelEditStub
    func navigateToLabelEdit(editMode: LabelEditMode, labels: [MenuLabel], type: PMLabelType, userInfo: UserInfo, labelService: LabelsDataService) {
        navigateToLabelEditStub(editMode, labels, type, userInfo, labelService)
    }

}

class MockLabelManagerUIProtocol: LabelManagerUIProtocol {
    @FuncStub(MockLabelManagerUIProtocol.viewModeDidChange) var viewModeDidChangeStub
    func viewModeDidChange(mode: LabelManagerViewModel.ViewMode) {
        viewModeDidChangeStub(mode)
    }

    @FuncStub(MockLabelManagerUIProtocol.showLoadingHUD) var showLoadingHUDStub
    func showLoadingHUD() {
        showLoadingHUDStub()
    }

    @FuncStub(MockLabelManagerUIProtocol.hideLoadingHUD) var hideLoadingHUDStub
    func hideLoadingHUD() {
        hideLoadingHUDStub()
    }

    @FuncStub(MockLabelManagerUIProtocol.reloadData) var reloadDataStub
    func reloadData() {
        reloadDataStub()
    }

    @FuncStub(MockLabelManagerUIProtocol.reload) var reloadStub
    func reload(section: Int) {
        reloadStub(section)
    }

    @FuncStub(MockLabelManagerUIProtocol.showToast) var showToastStub
    func showToast(message: String) {
        showToastStub(message)
    }

    @FuncStub(MockLabelManagerUIProtocol.showAlertMaxItemsReached) var showAlertMaxItemsReachedStub
    func showAlertMaxItemsReached() {
        showAlertMaxItemsReachedStub()
    }

    @FuncStub(MockLabelManagerUIProtocol.showNoInternetConnectionToast) var showNoInternetConnectionToastStub
    func showNoInternetConnectionToast() {
        showNoInternetConnectionToastStub()
    }

}

class MockLabelProviderProtocol: LabelProviderProtocol {
    @FuncStub(MockLabelProviderProtocol.makePublisher, initialReturn: .crash) var makePublisherStub
    func makePublisher() -> LabelPublisherProtocol {
        makePublisherStub()
    }

    @FuncStub(MockLabelProviderProtocol.getCustomFolders, initialReturn: [LabelEntity]()) var getCustomFoldersStub
    func getCustomFolders() -> [LabelEntity] {
        getCustomFoldersStub()
    }

    @FuncStub(MockLabelProviderProtocol.fetchV4Labels) var fetchV4LabelsStub
    func fetchV4Labels(completion: ((Swift.Result<Void, NSError>) -> Void)?) {
        fetchV4LabelsStub(completion)
    }

}

class MockLabelPublisherProtocol: LabelPublisherProtocol {
    @PropertyStub(\MockLabelPublisherProtocol.delegate, initialGet: nil) var delegateStub
    var delegate: LabelListenerProtocol? {
        get {
            delegateStub()
        }
        set {
            delegateStub(newValue)
        }
    }

    @FuncStub(MockLabelPublisherProtocol.fetchLabels) var fetchLabelsStub
    func fetchLabels(labelType: LabelFetchType) {
        fetchLabelsStub(labelType)
    }

}

class MockLastUpdatedStoreProtocol: LastUpdatedStoreProtocol {
    @FuncStub(MockLastUpdatedStoreProtocol.cleanUp) var cleanUpStub
    func cleanUp(userId: UserID) {
        cleanUpStub(userId)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.updateEventID) var updateEventIDStub
    func updateEventID(by userID: UserID, eventID: String) {
        updateEventIDStub(userID, eventID)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.lastEventID, initialReturn: String()) var lastEventIDStub
    func lastEventID(userID: UserID) -> String {
        lastEventIDStub(userID)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.lastEventUpdateTime, initialReturn: nil) var lastEventUpdateTimeStub
    func lastEventUpdateTime(userID: UserID) -> Date? {
        lastEventUpdateTimeStub(userID)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.lastUpdate, initialReturn: nil) var lastUpdateStub
    func lastUpdate(by labelID: LabelID, userID: UserID, type: ViewMode) -> LabelCountEntity? {
        lastUpdateStub(labelID, userID, type)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.unreadCount, initialReturn: Int()) var unreadCountStub
    func unreadCount(by labelID: LabelID, userID: UserID, type: ViewMode) -> Int {
        unreadCountStub(labelID, userID, type)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.updateUnreadCount) var updateUnreadCountStub
    func updateUnreadCount(by labelID: LabelID, userID: UserID, unread: Int, total: Int?, type: ViewMode, shouldSave: Bool) {
        updateUnreadCountStub(labelID, userID, unread, total, type, shouldSave)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.removeUpdateTime) var removeUpdateTimeStub
    func removeUpdateTime(by userID: UserID) {
        removeUpdateTimeStub(userID)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.resetCounter) var resetCounterStub
    func resetCounter(labelID: LabelID, userID: UserID) {
        resetCounterStub(labelID, userID)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.removeUpdateTimeExceptUnread) var removeUpdateTimeExceptUnreadStub
    func removeUpdateTimeExceptUnread(by userID: UserID) {
        removeUpdateTimeExceptUnreadStub(userID)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.getUnreadCounts, initialReturn: [String: Int]()) var getUnreadCountsStub
    func getUnreadCounts(by labelIDs: [LabelID], userID: UserID, type: ViewMode) -> [String: Int] {
        getUnreadCountsStub(labelIDs, userID, type)
    }

    @FuncStub(MockLastUpdatedStoreProtocol.updateLastUpdatedTime) var updateLastUpdatedTimeStub
    func updateLastUpdatedTime(labelID: LabelID, isUnread: Bool, startTime: Date, endTime: Date?, msgCount: Int, userID: UserID, type: ViewMode) {
        updateLastUpdatedTimeStub(labelID, isUnread, startTime, endTime, msgCount, userID, type)
    }

}

class MockLocalMessageDataServiceProtocol: LocalMessageDataServiceProtocol {
    @FuncStub(MockLocalMessageDataServiceProtocol.cleanMessage) var cleanMessageStub
    func cleanMessage(removeAllDraft: Bool, cleanBadgeAndNotifications: Bool) {
        cleanMessageStub(removeAllDraft, cleanBadgeAndNotifications)
    }

    @FuncStub(MockLocalMessageDataServiceProtocol.fetchMessages, initialReturn: [Message]()) var fetchMessagesStub
    func fetchMessages(withIDs selected: NSMutableSet, in context: NSManagedObjectContext) -> [Message] {
        fetchMessagesStub(selected, context)
    }

}

class MockLockCacheStatus: LockCacheStatus {
    @PropertyStub(\MockLockCacheStatus.isPinCodeEnabled, initialGet: Bool()) var isPinCodeEnabledStub
    var isPinCodeEnabled: Bool {
        isPinCodeEnabledStub()
    }

    @PropertyStub(\MockLockCacheStatus.isTouchIDEnabled, initialGet: Bool()) var isTouchIDEnabledStub
    var isTouchIDEnabled: Bool {
        isTouchIDEnabledStub()
    }

    @PropertyStub(\MockLockCacheStatus.isAppKeyEnabled, initialGet: Bool()) var isAppKeyEnabledStub
    var isAppKeyEnabled: Bool {
        isAppKeyEnabledStub()
    }

    @PropertyStub(\MockLockCacheStatus.isAppLockedAndAppKeyDisabled, initialGet: Bool()) var isAppLockedAndAppKeyDisabledStub
    var isAppLockedAndAppKeyDisabled: Bool {
        isAppLockedAndAppKeyDisabledStub()
    }

    @PropertyStub(\MockLockCacheStatus.isAppLockedAndAppKeyEnabled, initialGet: Bool()) var isAppLockedAndAppKeyEnabledStub
    var isAppLockedAndAppKeyEnabled: Bool {
        isAppLockedAndAppKeyEnabledStub()
    }

}

class MockLockPreferences: LockPreferences {
    @FuncStub(MockLockPreferences.setKeymakerRandomkey) var setKeymakerRandomkeyStub
    func setKeymakerRandomkey(key: String?) {
        setKeymakerRandomkeyStub(key)
    }

    @FuncStub(MockLockPreferences.setLockTime) var setLockTimeStub
    func setLockTime(value: AutolockTimeout) {
        setLockTimeStub(value)
    }

}

class MockMailSettingsHandler: MailSettingsHandler {
    @PropertyStub(\MockMailSettingsHandler.mailSettings, initialGet: MailSettings()) var mailSettingsStub
    var mailSettings: MailSettings {
        get {
            mailSettingsStub()
        }
        set {
            mailSettingsStub(newValue)
        }
    }

    @PropertyStub(\MockMailSettingsHandler.userInfo, initialGet: UserInfo()) var userInfoStub
    var userInfo: UserInfo {
        userInfoStub()
    }

}

class MockMailboxCoordinatorProtocol: MailboxCoordinatorProtocol {
    @PropertyStub(\MockMailboxCoordinatorProtocol.pendingActionAfterDismissal, initialGet: nil) var pendingActionAfterDismissalStub
    var pendingActionAfterDismissal: (() -> Void)? {
        get {
            pendingActionAfterDismissalStub()
        }
        set {
            pendingActionAfterDismissalStub(newValue)
        }
    }

    @PropertyStub(\MockMailboxCoordinatorProtocol.conversationCoordinator, initialGet: nil) var conversationCoordinatorStub
    var conversationCoordinator: ConversationCoordinator? {
        conversationCoordinatorStub()
    }

    @PropertyStub(\MockMailboxCoordinatorProtocol.singleMessageCoordinator, initialGet: nil) var singleMessageCoordinatorStub
    var singleMessageCoordinator: SingleMessageCoordinator? {
        singleMessageCoordinatorStub()
    }

    @FuncStub(MockMailboxCoordinatorProtocol.go) var goStub
    func go(to dest: MailboxCoordinator.Destination, sender: Any?) {
        goStub(dest, sender)
    }

    @FuncStub(MockMailboxCoordinatorProtocol.presentToolbarCustomizationView) var presentToolbarCustomizationViewStub
    func presentToolbarCustomizationView(allActions: [MessageViewActionSheetAction], currentActions: [MessageViewActionSheetAction]) {
        presentToolbarCustomizationViewStub(allActions, currentActions)
    }

}

class MockMarkLegitimateActionHandler: MarkLegitimateActionHandler {
    @FuncStub(MockMarkLegitimateActionHandler.markAsLegitimate) var markAsLegitimateStub
    func markAsLegitimate(messageId: MessageID) {
        markAsLegitimateStub(messageId)
    }

}

class MockMenuCoordinatorProtocol: MenuCoordinatorProtocol {
    @FuncStub(MockMenuCoordinatorProtocol.go) var goStub
    func go(to labelInfo: MenuLabel, deepLink: DeepLink?) {
        goStub(labelInfo, deepLink)
    }

    @FuncStub(MockMenuCoordinatorProtocol.closeMenu) var closeMenuStub
    func closeMenu() {
        closeMenuStub()
    }

    @FuncStub(MockMenuCoordinatorProtocol.lockTheScreen) var lockTheScreenStub
    func lockTheScreen() {
        lockTheScreenStub()
    }

    @FuncStub(MockMenuCoordinatorProtocol.update) var updateStub
    func update(menuWidth: CGFloat) {
        updateStub(menuWidth)
    }

}

class MockMobileSignatureCacheProtocol: MobileSignatureCacheProtocol {
    @FuncStub(MockMobileSignatureCacheProtocol.getMobileSignatureSwitchStatus, initialReturn: nil) var getMobileSignatureSwitchStatusStub
    func getMobileSignatureSwitchStatus(by uid: String) -> Bool? {
        getMobileSignatureSwitchStatusStub(uid)
    }

    @FuncStub(MockMobileSignatureCacheProtocol.setMobileSignatureSwitchStatus) var setMobileSignatureSwitchStatusStub
    func setMobileSignatureSwitchStatus(uid: String, value: Bool) {
        setMobileSignatureSwitchStatusStub(uid, value)
    }

    @FuncStub(MockMobileSignatureCacheProtocol.removeMobileSignatureSwitchStatus) var removeMobileSignatureSwitchStatusStub
    func removeMobileSignatureSwitchStatus(uid: String) {
        removeMobileSignatureSwitchStatusStub(uid)
    }

    @FuncStub(MockMobileSignatureCacheProtocol.getEncryptedMobileSignature, initialReturn: nil) var getEncryptedMobileSignatureStub
    func getEncryptedMobileSignature(userID: String) -> Data? {
        getEncryptedMobileSignatureStub(userID)
    }

    @FuncStub(MockMobileSignatureCacheProtocol.setEncryptedMobileSignature) var setEncryptedMobileSignatureStub
    func setEncryptedMobileSignature(userID: String, signatureData: Data) {
        setEncryptedMobileSignatureStub(userID, signatureData)
    }

    @FuncStub(MockMobileSignatureCacheProtocol.removeEncryptedMobileSignature) var removeEncryptedMobileSignatureStub
    func removeEncryptedMobileSignature(userID: String) {
        removeEncryptedMobileSignatureStub(userID)
    }

}

class MockNWPathProtocol: NWPathProtocol {
    @PropertyStub(\MockNWPathProtocol.pathStatus, initialGet: nil) var pathStatusStub
    var pathStatus: NWPath.Status? {
        pathStatusStub()
    }

    @PropertyStub(\MockNWPathProtocol.isPossiblyConnectedThroughVPN, initialGet: Bool()) var isPossiblyConnectedThroughVPNStub
    var isPossiblyConnectedThroughVPN: Bool {
        isPossiblyConnectedThroughVPNStub()
    }

    @FuncStub(MockNWPathProtocol.usesInterfaceType, initialReturn: Bool()) var usesInterfaceTypeStub
    func usesInterfaceType(_ type: NWInterface.InterfaceType) -> Bool {
        usesInterfaceTypeStub(type)
    }

}

class MockNewMessageBodyViewModelDelegate: NewMessageBodyViewModelDelegate {
    @FuncStub(MockNewMessageBodyViewModelDelegate.reloadWebView) var reloadWebViewStub
    func reloadWebView(forceRecreate: Bool) {
        reloadWebViewStub(forceRecreate)
    }

    @FuncStub(MockNewMessageBodyViewModelDelegate.showReloadError) var showReloadErrorStub
    func showReloadError() {
        showReloadErrorStub()
    }

}

class MockNextMessageAfterMoveStatusProvider: NextMessageAfterMoveStatusProvider {
    @PropertyStub(\MockNextMessageAfterMoveStatusProvider.shouldMoveToNextMessageAfterMove, initialGet: Bool()) var shouldMoveToNextMessageAfterMoveStub
    var shouldMoveToNextMessageAfterMove: Bool {
        get {
            shouldMoveToNextMessageAfterMoveStub()
        }
        set {
            shouldMoveToNextMessageAfterMoveStub(newValue)
        }
    }

}

class MockPMPersistentQueueProtocol: PMPersistentQueueProtocol {
    @PropertyStub(\MockPMPersistentQueueProtocol.count, initialGet: Int()) var countStub
    var count: Int {
        countStub()
    }

    @FuncStub(MockPMPersistentQueueProtocol.queueArray, initialReturn: [Any]()) var queueArrayStub
    func queueArray() -> [Any] {
        queueArrayStub()
    }

    @FuncStub(MockPMPersistentQueueProtocol.add, initialReturn: UUID()) var addStub
    func add(_ uuid: UUID, object: NSCoding) -> UUID {
        addStub(uuid, object)
    }

    @FuncStub(MockPMPersistentQueueProtocol.insert, initialReturn: UUID()) var insertStub
    func insert(uuid: UUID, object: NSCoding, index: Int) -> UUID {
        insertStub(uuid, object, index)
    }

    @FuncStub(MockPMPersistentQueueProtocol.update) var updateStub
    func update(uuid: UUID, object: NSCoding) {
        updateStub(uuid, object)
    }

    @FuncStub(MockPMPersistentQueueProtocol.clearAll) var clearAllStub
    func clearAll() {
        clearAllStub()
    }

    @FuncStub(MockPMPersistentQueueProtocol.next, initialReturn: nil) var nextStub
    func next() -> (elementID: UUID, object: Any)? {
        nextStub()
    }

    @FuncStub(MockPMPersistentQueueProtocol.remove, initialReturn: Bool()) var removeStub
    func remove(_ elementID: UUID) -> Bool {
        removeStub(elementID)
    }

}

class MockPagesViewUIProtocol: PagesViewUIProtocol {
    @FuncStub(MockPagesViewUIProtocol.dismiss) var dismissStub
    func dismiss() {
        dismissStub()
    }

    @FuncStub(MockPagesViewUIProtocol.getCurrentObjectID, initialReturn: nil) var getCurrentObjectIDStub
    func getCurrentObjectID() -> ObjectID? {
        getCurrentObjectIDStub()
    }

    @FuncStub(MockPagesViewUIProtocol.handlePageViewNavigationDirection) var handlePageViewNavigationDirectionStub
    func handlePageViewNavigationDirection(action: PagesSwipeAction, shouldReload: Bool) {
        handlePageViewNavigationDirectionStub(action, shouldReload)
    }

}

class MockPaymentsUIProtocol: PaymentsUIProtocol {
    @FuncStub(MockPaymentsUIProtocol.showCurrentPlan) var showCurrentPlanStub
    func showCurrentPlan(presentationType: PaymentsUIPresentationType, backendFetch: Bool, completionHandler: @escaping (PaymentsUIResultReason) -> Void) {
        showCurrentPlanStub(presentationType, backendFetch, completionHandler)
    }

}

class MockPinFailedCountCache: PinFailedCountCache {
    @PropertyStub(\MockPinFailedCountCache.pinFailedCount, initialGet: Int()) var pinFailedCountStub
    var pinFailedCount: Int {
        get {
            pinFailedCountStub()
        }
        set {
            pinFailedCountStub(newValue)
        }
    }

}

class MockPushDecryptionKeysProvider: PushDecryptionKeysProvider {
    @PropertyStub(\MockPushDecryptionKeysProvider.pushNotificationsDecryptionKeys, initialGet: [DecryptionKey]()) var pushNotificationsDecryptionKeysStub
    var pushNotificationsDecryptionKeys: [DecryptionKey] {
        pushNotificationsDecryptionKeysStub()
    }

}

class MockPushEncryptionManagerProtocol: PushEncryptionManagerProtocol {
    @FuncStub(MockPushEncryptionManagerProtocol.registerDeviceForNotifications) var registerDeviceForNotificationsStub
    func registerDeviceForNotifications(deviceToken: String) {
        registerDeviceForNotificationsStub(deviceToken)
    }

    @FuncStub(MockPushEncryptionManagerProtocol.registerDeviceAfterNewAccountSignIn) var registerDeviceAfterNewAccountSignInStub
    func registerDeviceAfterNewAccountSignIn() {
        registerDeviceAfterNewAccountSignInStub()
    }

    @FuncStub(MockPushEncryptionManagerProtocol.deleteAllCachedData) var deleteAllCachedDataStub
    func deleteAllCachedData() {
        deleteAllCachedDataStub()
    }

}

class MockQueueHandlerRegister: QueueHandlerRegister {
    @FuncStub(MockQueueHandlerRegister.registerHandler) var registerHandlerStub
    func registerHandler(_ handler: QueueHandler) {
        registerHandlerStub(handler)
    }

    @FuncStub(MockQueueHandlerRegister.unregisterHandler) var unregisterHandlerStub
    func unregisterHandler(for userID: UserID) {
        unregisterHandlerStub(userID)
    }

}

class MockQueueManagerProtocol: QueueManagerProtocol {
    @FuncStub(MockQueueManagerProtocol.addTask) var addTaskStub
    func addTask(_ task: QueueManager.Task, autoExecute: Bool, completion: ((Bool) -> Void)?) {
        addTaskStub(task, autoExecute, completion)
    }

    @FuncStub(MockQueueManagerProtocol.addBlock) var addBlockStub
    func addBlock(_ block: @escaping () -> Void) {
        addBlockStub(block)
    }

    @FuncStub(MockQueueManagerProtocol.queue) var queueStub
    func queue(_ readBlock: @escaping () -> Void) {
        queueStub(readBlock)
    }

}

class MockReceiptActionHandler: ReceiptActionHandler {
    @FuncStub(MockReceiptActionHandler.sendReceipt) var sendReceiptStub
    func sendReceipt(messageID: MessageID) {
        sendReceiptStub(messageID)
    }

}

class MockRefetchAllBlockedSendersUseCase: RefetchAllBlockedSendersUseCase {
    @FuncStub(MockRefetchAllBlockedSendersUseCase.execute) var executeStub
    func execute(completion: @escaping (Error?) -> Void) {
        executeStub(completion)
    }

}

class MockScheduledSendHelperDelegate: ScheduledSendHelperDelegate {
    @FuncStub(MockScheduledSendHelperDelegate.actionSheetWillAppear) var actionSheetWillAppearStub
    func actionSheetWillAppear() {
        actionSheetWillAppearStub()
    }

    @FuncStub(MockScheduledSendHelperDelegate.actionSheetWillDisappear) var actionSheetWillDisappearStub
    func actionSheetWillDisappear() {
        actionSheetWillDisappearStub()
    }

    @FuncStub(MockScheduledSendHelperDelegate.scheduledTimeIsSet) var scheduledTimeIsSetStub
    func scheduledTimeIsSet(date: Date?) {
        scheduledTimeIsSetStub(date)
    }

    @FuncStub(MockScheduledSendHelperDelegate.showSendInTheFutureAlert) var showSendInTheFutureAlertStub
    func showSendInTheFutureAlert() {
        showSendInTheFutureAlertStub()
    }

    @FuncStub(MockScheduledSendHelperDelegate.isItAPaidUser, initialReturn: Bool()) var isItAPaidUserStub
    func isItAPaidUser() -> Bool {
        isItAPaidUserStub()
    }

    @FuncStub(MockScheduledSendHelperDelegate.showScheduleSendPromotionView) var showScheduleSendPromotionViewStub
    func showScheduleSendPromotionView() {
        showScheduleSendPromotionViewStub()
    }

}

class MockSettingsAccountCoordinatorProtocol: SettingsAccountCoordinatorProtocol {
    @FuncStub(MockSettingsAccountCoordinatorProtocol.go) var goStub
    func go(to dest: SettingsAccountCoordinator.Destination) {
        goStub(dest)
    }

}

class MockSettingsLockRouterProtocol: SettingsLockRouterProtocol {
    @FuncStub(MockSettingsLockRouterProtocol.go) var goStub
    func go(to dest: SettingsLockRouterDestination) {
        goStub(dest)
    }

}

class MockSettingsLockUIProtocol: SettingsLockUIProtocol {
    @FuncStub(MockSettingsLockUIProtocol.reloadData) var reloadDataStub
    func reloadData() {
        reloadDataStub()
    }

}

class MockSideMenuProtocol: SideMenuProtocol {
    @PropertyStub(\MockSideMenuProtocol.menuViewController, initialGet: nil) var menuViewControllerStub
    var menuViewController: UIViewController! {
        get {
            menuViewControllerStub()
        }
        set {
            menuViewControllerStub(newValue)
        }
    }

    @FuncStub(MockSideMenuProtocol.hideMenu) var hideMenuStub
    func hideMenu(animated: Bool, completion: ((Bool) -> Void)?) {
        hideMenuStub(animated, completion)
    }

    @FuncStub(MockSideMenuProtocol.revealMenu) var revealMenuStub
    func revealMenu(animated: Bool, completion: ((Bool) -> Void)?) {
        revealMenuStub(animated, completion)
    }

    @FuncStub(MockSideMenuProtocol.setContentViewController) var setContentViewControllerStub
    func setContentViewController(to viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        setContentViewControllerStub(viewController, animated, completion)
    }

}

class MockSwipeActionInfo: SwipeActionInfo {
    @PropertyStub(\MockSwipeActionInfo.swipeLeft, initialGet: Int()) var swipeLeftStub
    var swipeLeft: Int {
        swipeLeftStub()
    }

    @PropertyStub(\MockSwipeActionInfo.swipeRight, initialGet: Int()) var swipeRightStub
    var swipeRight: Int {
        swipeRightStub()
    }

}

class MockToolbarCustomizationInfoBubbleViewStatusProvider: ToolbarCustomizationInfoBubbleViewStatusProvider {
    @PropertyStub(\MockToolbarCustomizationInfoBubbleViewStatusProvider.shouldHideToolbarCustomizeInfoBubbleView, initialGet: Bool()) var shouldHideToolbarCustomizeInfoBubbleViewStub
    var shouldHideToolbarCustomizeInfoBubbleView: Bool {
        get {
            shouldHideToolbarCustomizeInfoBubbleViewStub()
        }
        set {
            shouldHideToolbarCustomizeInfoBubbleViewStub(newValue)
        }
    }

}

class MockURLSessionDataTaskProtocol: URLSessionDataTaskProtocol {
    @FuncStub(MockURLSessionDataTaskProtocol.resume) var resumeStub
    func resume() {
        resumeStub()
    }

}

class MockURLSessionProtocol: URLSessionProtocol {
    @FuncStub(MockURLSessionProtocol.dataTask, initialReturn: .crash) var dataTaskStub
    func dataTask(withRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        dataTaskStub(withRequest, completionHandler)
    }

    @ThrowingFuncStub(MockURLSessionProtocol.data, initialReturn: .crash) var dataStub
    func data(for request: URLRequest) throws -> (Data, URLResponse) {
        try dataStub(request)
    }

}

class MockUnlockManagerDelegate: UnlockManagerDelegate {
    @FuncStub(MockUnlockManagerDelegate.cleanAll) var cleanAllStub
    func cleanAll(completion: @escaping () -> Void) {
        cleanAllStub(completion)
    }

    @FuncStub(MockUnlockManagerDelegate.isUserStored, initialReturn: Bool()) var isUserStoredStub
    func isUserStored() -> Bool {
        isUserStoredStub()
    }

    @FuncStub(MockUnlockManagerDelegate.isMailboxPasswordStored, initialReturn: Bool()) var isMailboxPasswordStoredStub
    func isMailboxPasswordStored(forUser uid: String?) -> Bool {
        isMailboxPasswordStoredStub(uid)
    }

    @ThrowingFuncStub(MockUnlockManagerDelegate.setupCoreData) var setupCoreDataStub
    func setupCoreData() throws {
        try setupCoreDataStub()
    }

    @FuncStub(MockUnlockManagerDelegate.loadUserDataAfterUnlock) var loadUserDataAfterUnlockStub
    func loadUserDataAfterUnlock() {
        loadUserDataAfterUnlockStub()
    }

}

class MockUnlockProvider: UnlockProvider {
    @FuncStub(MockUnlockProvider.isUnlocked, initialReturn: Bool()) var isUnlockedStub
    func isUnlocked() -> Bool {
        isUnlockedStub()
    }

}

class MockUnsubscribeActionHandler: UnsubscribeActionHandler {
    @FuncStub(MockUnsubscribeActionHandler.oneClickUnsubscribe) var oneClickUnsubscribeStub
    func oneClickUnsubscribe(messageId: MessageID) {
        oneClickUnsubscribeStub(messageId)
    }

    @FuncStub(MockUnsubscribeActionHandler.markAsUnsubscribed) var markAsUnsubscribedStub
    func markAsUnsubscribed(messageId: MessageID, finish: @escaping () -> Void) {
        markAsUnsubscribedStub(messageId, finish)
    }

}

class MockUserCachedStatusProvider: UserCachedStatusProvider {
    @PropertyStub(\MockUserCachedStatusProvider.keymakerRandomkey, initialGet: nil) var keymakerRandomkeyStub
    var keymakerRandomkey: String? {
        get {
            keymakerRandomkeyStub()
        }
        set {
            keymakerRandomkeyStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.primaryUserSessionId, initialGet: nil) var primaryUserSessionIdStub
    var primaryUserSessionId: String? {
        get {
            primaryUserSessionIdStub()
        }
        set {
            primaryUserSessionIdStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.isDohOn, initialGet: Bool()) var isDohOnStub
    var isDohOn: Bool {
        get {
            isDohOnStub()
        }
        set {
            isDohOnStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.isCombineContactOn, initialGet: Bool()) var isCombineContactOnStub
    var isCombineContactOn: Bool {
        get {
            isCombineContactOnStub()
        }
        set {
            isCombineContactOnStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.lastDraftMessageID, initialGet: nil) var lastDraftMessageIDStub
    var lastDraftMessageID: String? {
        get {
            lastDraftMessageIDStub()
        }
        set {
            lastDraftMessageIDStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.isPMMEWarningDisabled, initialGet: Bool()) var isPMMEWarningDisabledStub
    var isPMMEWarningDisabled: Bool {
        get {
            isPMMEWarningDisabledStub()
        }
        set {
            isPMMEWarningDisabledStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.serverNotices, initialGet: [String]()) var serverNoticesStub
    var serverNotices: [String] {
        get {
            serverNoticesStub()
        }
        set {
            serverNoticesStub(newValue)
        }
    }

    @PropertyStub(\MockUserCachedStatusProvider.serverNoticesNextTime, initialGet: String()) var serverNoticesNextTimeStub
    var serverNoticesNextTime: String {
        get {
            serverNoticesNextTimeStub()
        }
        set {
            serverNoticesNextTimeStub(newValue)
        }
    }

    @FuncStub(MockUserCachedStatusProvider.getDefaultSignaureSwitchStatus, initialReturn: nil) var getDefaultSignaureSwitchStatusStub
    func getDefaultSignaureSwitchStatus(uid: String) -> Bool? {
        getDefaultSignaureSwitchStatusStub(uid)
    }

    @FuncStub(MockUserCachedStatusProvider.setDefaultSignatureSwitchStatus) var setDefaultSignatureSwitchStatusStub
    func setDefaultSignatureSwitchStatus(uid: String, value: Bool) {
        setDefaultSignatureSwitchStatusStub(uid, value)
    }

    @FuncStub(MockUserCachedStatusProvider.removeDefaultSignatureSwitchStatus) var removeDefaultSignatureSwitchStatusStub
    func removeDefaultSignatureSwitchStatus(uid: String) {
        removeDefaultSignatureSwitchStatusStub(uid)
    }

    @FuncStub(MockUserCachedStatusProvider.getIsCheckSpaceDisabledStatus, initialReturn: nil) var getIsCheckSpaceDisabledStatusStub
    func getIsCheckSpaceDisabledStatus(by uid: String) -> Bool? {
        getIsCheckSpaceDisabledStatusStub(uid)
    }

    @FuncStub(MockUserCachedStatusProvider.setIsCheckSpaceDisabledStatus) var setIsCheckSpaceDisabledStatusStub
    func setIsCheckSpaceDisabledStatus(uid: String, value: Bool) {
        setIsCheckSpaceDisabledStatusStub(uid, value)
    }

    @FuncStub(MockUserCachedStatusProvider.removeIsCheckSpaceDisabledStatus) var removeIsCheckSpaceDisabledStatusStub
    func removeIsCheckSpaceDisabledStatus(uid: String) {
        removeIsCheckSpaceDisabledStatusStub(uid)
    }

}

class MockUserFeedbackServiceProtocol: UserFeedbackServiceProtocol {
    @FuncStub(MockUserFeedbackServiceProtocol.send) var sendStub
    func send(_ feedback: UserFeedback, handler: @escaping (UserFeedbackServiceError?) -> Void) {
        sendStub(feedback, handler)
    }

}

class MockUserIntroductionProgressProvider: UserIntroductionProgressProvider {
    @FuncStub(MockUserIntroductionProgressProvider.shouldShowSpotlight, initialReturn: Bool()) var shouldShowSpotlightStub
    func shouldShowSpotlight(for feature: SpotlightableFeatureKey, toUserWith userID: UserID) -> Bool {
        shouldShowSpotlightStub(feature, userID)
    }

    @FuncStub(MockUserIntroductionProgressProvider.markSpotlight) var markSpotlightStub
    func markSpotlight(for feature: SpotlightableFeatureKey, asSeen seen: Bool, byUserWith userID: UserID) {
        markSpotlightStub(feature, seen, userID)
    }

}

class MockUsersManagerProtocol: UsersManagerProtocol {
    @PropertyStub(\MockUsersManagerProtocol.firstUser, initialGet: nil) var firstUserStub
    var firstUser: UserManager? {
        firstUserStub()
    }

    @FuncStub(MockUsersManagerProtocol.hasUsers, initialReturn: Bool()) var hasUsersStub
    func hasUsers() -> Bool {
        hasUsersStub()
    }

}

class MockViewModeUpdater: ViewModeUpdater {
    @FuncStub(MockViewModeUpdater.update) var updateStub
    func update(viewMode: ViewMode, completion: ((Swift.Result<ViewMode?, Error>) -> Void)?) {
        updateStub(viewMode, completion)
    }

}

