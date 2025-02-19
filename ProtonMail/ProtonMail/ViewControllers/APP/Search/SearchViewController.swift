//
//  SearchViewController.swift
//  Proton Mail
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
import LifetimeTracker
import MBProgressHUD
import ProtonCore_Foundations
import ProtonCore_UIFoundations
import ProtonMailAnalytics
import UIKit

protocol SearchViewUIProtocol: UIViewController {
    var listEditing: Bool { get }

    func update(progress: Float)
    func setupProgressBar(isHidden: Bool)
    func activityIndicator(isAnimating: Bool)
    func refreshActionBarItems()
    func reloadTable()
}

class SearchViewController: ProtonMailViewController, ComposeSaveHintProtocol, CoordinatorDismissalObserver, ScheduledAlertPresenter, LifetimeTrackable {
    typealias Dependencies = ConversationCoordinator.Dependencies

    class var lifetimeConfiguration: LifetimeConfiguration {
        .init(maxCount: 1)
    }

    private let customView: SearchView
    private var actionSheet: PMActionSheet?

    // MARK: - Private Constants
    private let kLongPressDuration: CFTimeInterval = 0.60 // seconds

    private let serialQueue = DispatchQueue(label: "com.protonamil.messageTapped")
    private var messageTapped = false
    private(set) var listEditing: Bool = false

    private let viewModel: SearchVMProtocol
    private var query: String = ""
    private let mailListActionSheetPresenter = MailListActionSheetPresenter()
    private lazy var moveToActionSheetPresenter = MoveToActionSheetPresenter()
    private lazy var labelAsActionSheetPresenter = LabelAsActionSheetPresenter()
    private let cellPresenter = NewMailboxMessageCellPresenter()
    var pendingActionAfterDismissal: (() -> Void)?
    private let dependencies: Dependencies

    init(viewModel: SearchVMProtocol, dependencies: Dependencies) {
        self.viewModel = viewModel
        self.customView = .init()
        self.dependencies = dependencies

        super.init(nibName: nil, bundle: nil)
        self.viewModel.uiDelegate = self
        trackLifetime()
    }

    override func loadView() {
        view = customView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.navigationController?.navigationBar.isTranslucent = false

        self.emptyBackButtonTitleForNextView()

        self.setupSearchBar()
        self.setupTableview()
        self.viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        customView.tableView.reloadData()
        self.viewModel.user.undoActionManager.register(handler: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        customView.searchBar.textField.resignFirstResponder()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customView.tableView.zeroMargin()
    }
}

// MARK: UI related
extension SearchViewController {
    private func setupSearchBar() {
        customView.searchBar.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        customView.searchBar.clearButton.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        customView.searchBar.textField.delegate = self
        customView.searchBar.textField.becomeFirstResponder()
    }

    private func setupTableview() {
        customView.tableView.delegate = self
        customView.tableView.dataSource = self
        customView.tableView.noSeparatorsBelowFooter()
        customView.tableView.register(NewMailboxMessageCell.self, forCellReuseIdentifier: NewMailboxMessageCell.defaultID())
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                      action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = kLongPressDuration
        customView.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
}

// MARK: Actions
extension SearchViewController {
    @objc
    private func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        self.showCheckOptions(longPressGestureRecognizer)
    }

    @objc
    private func cancelButtonTapped() {
        if listEditing {
            self.cancelEditingMode()
        } else {
            self.viewModel.cleanLocalIndex()
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    @objc
    private func clearAction() {
        customView.searchBar.textField.text = nil
        customView.searchBar.textField.sendActions(for: .editingChanged)
        customView.searchBar.clearButton.isHidden = true
    }

    @IBAction func tapAction(_ sender: AnyObject) {
        customView.searchBar.textField.resignFirstResponder()
    }
}

// MARK: Action bar / sheet related
extension SearchViewController {
    func refreshActionBarItems() {
        let actions = self.viewModel.getActionBarActions()
        var actionItems: [PMToolBarView.ActionItem] = []

        for action in actions {
            let actionHandler: () -> Void = { [weak self] in
                guard let self = self else { return }
                if action == .more {
                    self.moreButtonTapped()
                } else {
                    guard !self.viewModel.selectedIDs.isEmpty else {
                        self.showNoEmailSelected(title: LocalString._warning)
                        return
                    }
                    switch action {
                    case .delete:
                        self.showDeleteAlert { [weak self] in
                            guard let `self` = self else { return }
                            self.viewModel.handleBarActions(action)
                            self.showMessageMoved(title: LocalString._messages_has_been_deleted)
                        }
                    case .moveTo:
                        self.folderButtonTapped()
                    case .labelAs:
                        self.labelButtonTapped()
                    case .markUnread, .markRead:
                        self.viewModel.handleBarActions(action)
                    case .trash:
                        self.showTrashScheduleAlertIfNeeded { [weak self] scheduledNum in
                            self?.viewModel.handleBarActions(action)
                            let title: String
                            if scheduledNum == 0 {
                                title = LocalString._messages_has_been_moved
                            } else {
                                title = String(format: LocalString._message_moved_to_drafts, scheduledNum)
                            }
                            self?.showMessageMoved(title: title)
                        }

                    case .more:
                        assertionFailure("handled above")
                    case .reply, .replyAll, .forward, .archive, .spam, .print, .viewHeaders, .viewHTML,
                            .reportPhishing, .dismiss, .inbox, .spamMoveToInbox, .star,. unstar,
                            .viewInDarkMode, .viewInLightMode, .toolbarCustomization, .replyOrReplyAll, .saveAsPDF, .replyInConversation, .forwardInConversation, .replyOrReplyAllInConversation, .replyAllInConversation:
                        assertionFailure("should not reach here")
                    }
                }
            }

            let barItem = PMToolBarView.ActionItem(type: action, handler: actionHandler)
            actionItems.append(barItem)
        }
        customView.toolBar.setUpActions(actionItems)
    }

    private func showActionBar() {
        self.setToolBarHidden(false)
    }

    private func hideActionBar() {
        self.setToolBarHidden(true)
    }

    private func setToolBarHidden(_ hidden: Bool) {
        /*
         http://www.openradar.me/25087688

         > isHidden seems to be cumulative in UIStackViews, so we have to ensure to not set it the same value twice.
         */
        guard customView.toolBar.isHidden != hidden else {
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.customView.toolBar.isHidden = hidden
        }
    }

    private func hideActionSheet() {
        self.actionSheet?.dismiss(animated: true)
        self.actionSheet = nil
    }

    private func moreButtonTapped() {
        mailListActionSheetPresenter.present(
            on: navigationController ?? self,
            viewModel: viewModel.getActionSheetViewModel(),
            action: { [weak self] in
                self?.viewModel.handleActionSheetAction($0)
                self?.handleActionSheetAction($0)
            }
        )
    }

    private func folderButtonTapped() {
        guard !self.viewModel.selectedIDs.isEmpty else {
            showNoEmailSelected(title: LocalString._apply_labels)
            return
        }

        let isEnableColor = viewModel.user.isEnableFolderColor
        let isInherit = viewModel.user.isInheritParentFolderColor
        let messages = viewModel.selectedMessages
        if !messages.isEmpty {
            showMoveToActionSheet(messages: messages,
                                  isEnableColor: isEnableColor,
                                  isInherit: isInherit)
        }
    }

    private func labelButtonTapped() {
        guard !viewModel.selectedIDs.isEmpty else {
            showNoEmailSelected(title: LocalString._apply_labels)
            return
        }
        showLabelAsActionSheet(messages: viewModel.selectedMessages)
    }

    private func handleActionSheetAction(_ action: MessageViewActionSheetAction) {
        switch action {
        case .dismiss:
            dismissActionSheet()
        case .trash, .archive, .spam, .inbox:
            showMessageMoved(title: LocalString._messages_has_been_moved)
            cancelButtonTapped()
        case .markRead, .markUnread, .star, .unstar:
            break
        case .delete:
            showDeleteAlert { [weak self] in
                guard let `self` = self else { return }
                self.viewModel.deleteSelectedMessages()
            }
        case .labelAs:
            labelButtonTapped()
        case .moveTo:
            folderButtonTapped()
        case .toolbarCustomization:
            // TODO: Add implementation
            break
        case .reply, .replyAll, .forward, .print, .viewHeaders, .viewHTML, .reportPhishing, .spamMoveToInbox, .viewInDarkMode, .viewInLightMode, .more, .replyOrReplyAll, .saveAsPDF, .replyInConversation, .forwardInConversation, .replyOrReplyAllInConversation, .replyAllInConversation:
            break
        }
    }

    private func showNoEmailSelected(title: String) {
        let alert = UIAlertController(title: title,
                                      message: LocalString._message_list_no_email_selected,
                                      preferredStyle: .alert)
        alert.addOKAction()
        self.present(alert, animated: true, completion: nil)
    }

    private func showDeleteAlert(yesHandler: @escaping () -> Void) {
        let messagesCount = viewModel.selectedIDs.count
        let title = messagesCount > 1 ?
            String(format: LocalString._messages_delete_confirmation_alert_title, messagesCount) :
            LocalString._single_message_delete_confirmation_alert_title
        let message = String(format: LocalString._messages_delete_confirmation_alert_message, messagesCount)
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let yes = UIAlertAction(title: LocalString._general_delete_action, style: .destructive) { [weak self] _ in
            yesHandler()
            self?.cancelButtonTapped()
        }
        let cancel = UIAlertAction(title: LocalString._general_cancel_button, style: .cancel)
        [yes, cancel].forEach(alert.addAction)
        present(alert, animated: true, completion: nil)
    }

    private func showTrashScheduleAlertIfNeeded(continueAction: @escaping (Int) -> Void) {
        let num = viewModel.scheduledMessagesFromSelected().count
        guard num > 0 else {
            continueAction(0)
            return
        }
        displayScheduledAlert(scheduledNum: num) {
            continueAction(num)
        }
    }

    private func showMessageMoved(title: String) {
        guard UIApplication.shared.applicationState == .active else {
            return
        }
        let banner = PMBanner(
            message: title,
            style: PMBannerNewStyle.info,
            dismissDuration: 3,
            bannerHandler: PMBanner.dismiss
        )
        banner.show(at: .bottom, on: self)
    }

    private var moveToActionHandler: MoveToActionSheetProtocol? {
        guard let searchVM = self.viewModel as? SearchViewModel else {
            return nil
        }
        return searchVM
    }

    private func showMoveToActionSheet(messages: [MessageEntity], isEnableColor: Bool, isInherit: Bool) {
        guard let handler = moveToActionHandler else { return }
        let moveToViewModel = MoveToActionSheetViewModelMessages(
            menuLabels: handler.getFolderMenuItems(),
            isEnableColor: isEnableColor,
            isInherit: isInherit
        )

        moveToActionSheetPresenter.present(
            on: self.navigationController ?? self,
            viewModel: moveToViewModel,
            addNewFolder: { [weak self] in
                self?.pendingActionAfterDismissal = { [weak self] in
                    self?.showMoveToActionSheet(messages: messages,
                                                isEnableColor: isEnableColor,
                                                isInherit: isInherit)
                }
                self?.presentCreateFolder(type: .folder)
            },
            selected: { [weak self] menuLabel, isSelected in
                guard isSelected else { return }
                self?.didSelectFolderToMoveTo(folder: menuLabel, messages: messages)
            },
            cancel: { [weak self] in
                self?.dismissActionSheet()
            }
        )
    }

    private func didSelectFolderToMoveTo(folder: MenuLabel, messages: [MessageEntity]) {
        moveToActionHandler?.handleMoveToAction(messages: messages, to: folder)

        dismissActionSheet()
        cancelButtonTapped()
    }

    private var labelAsActionHandler: LabelAsActionSheetProtocol? {
        guard let searchVM = self.viewModel as? SearchViewModel else {
            return nil
        }
        return searchVM
    }

    private func showLabelAsActionSheet(messages: [MessageEntity]) {
        guard let handler = labelAsActionHandler else { return }
        let labelAsViewModel = LabelAsActionSheetViewModelMessages(menuLabels: handler.getLabelMenuItems(),
                                                                   messages: messages)

        labelAsActionSheetPresenter
            .present(on: self.navigationController ?? self,
                     viewModel: labelAsViewModel,
                     addNewLabel: { [weak self] in
                        self?.pendingActionAfterDismissal = { [weak self] in
                            self?.showLabelAsActionSheet(messages: messages)
                        }
                        self?.presentCreateFolder(type: .label)
                     },
                     selected: { menuLabel, isOn in
                        handler.updateSelectedLabelAsDestination(menuLabel: menuLabel, isOn: isOn)
                     },
                     cancel: { [weak self] isHavingUnsavedChanges in
                        if isHavingUnsavedChanges {
                            self?.showDiscardAlert(handleDiscard: {
                                handler.updateSelectedLabelAsDestination(menuLabel: nil, isOn: false)
                                self?.dismissActionSheet()
                            })
                        } else {
                            self?.dismissActionSheet()
                        }
                     },
                     done: { [weak self] isArchive, currentOptionsStatus in
                        handler.handleLabelAsAction(messages: messages,
                                                    shouldArchive: isArchive,
                                                    currentOptionsStatus: currentOptionsStatus)
                        self?.dismissActionSheet()
                     })
    }

    private func presentCreateFolder(type: PMLabelType) {
        let folderLabels = viewModel.user.labelService.getMenuFolderLabels()
        let dependencies = LabelEditViewModel.Dependencies(userManager: viewModel.user)
        let labelEditNavigationController = LabelEditStackBuilder.make(
            editMode: .creation,
            type: type,
            labels: folderLabels,
            dependencies: dependencies,
            coordinatorDismissalObserver: self
        )
        self.navigationController?.present(labelEditNavigationController, animated: true, completion: nil)
    }
}

extension SearchViewController {
    private func updateTapped(status: Bool) {
        serialQueue.sync {
            self.messageTapped = status
        }
    }

    private func getTapped() -> Bool {
        serialQueue.sync {
            let ret = self.messageTapped
            if ret == false {
                self.messageTapped = true
            }
            return ret
        }
    }

    private func prepareForDraft(_ message: MessageEntity) {
        self.updateTapped(status: true)
        viewModel.fetchMessageDetail(message: message, callback: { [weak self] result in
            self?.updateTapped(status: false)
            switch result {
            case .failure(let error):
                let alert = error.localizedDescription.alertController()
                alert.addOKAction()
                self?.present(alert, animated: true, completion: nil)
                self?.customView.tableView.indexPathsForSelectedRows?.forEach {
                    self?.customView.tableView.deselectRow(at: $0, animated: true)
                }
            case .success(let message):
                self?.showComposer(message: message)
            }
        })
    }
    private func showComposer(message: MessageEntity) {
        guard let navigationController = self.navigationController else { return }
        let composer = dependencies.composerViewFactory.makeComposer(msg: message, action: .openDraft)
        navigationController.present(composer, animated: true)
    }

    private func showComposer(msgID: MessageID) {
        guard let message = viewModel.getMessageObject(by: msgID),
              let navigationController = self.navigationController else {
            return
        }
        let composer = dependencies.composerViewFactory.makeComposer(
            msg: message,
            action: .openDraft,
            isEditingScheduleMsg: true
        )
        navigationController.present(composer, animated: true)
    }

    private func prepareFor(message: MessageEntity) {
        guard self.viewModel.viewMode == .singleMessage else {
            self.prepareConversationFor(message: message)
            return
        }
        if message.isDraft {
            self.prepareForDraft(message)
            return
        }
        self.updateTapped(status: false)
        guard let navigationController = navigationController else { return }
        let coordinator = SingleMessageCoordinator(
            navigationController: navigationController,
            labelId: "",
            message: message,
            dependencies: dependencies,
            highlightedKeywords: query.components(separatedBy: .whitespacesAndNewlines)
        )
        coordinator.goToDraft = { [weak self] msgID, _ in
            guard let self = self else { return }
            // trigger the data to be updated.
            _ = self.textFieldShouldReturn(self.customView.searchBar.textField)
            self.showComposer(msgID: msgID)
        }
        coordinator.start()
    }

    private func prepareConversationFor(message: MessageEntity) {
        guard let navigation = self.navigationController else {
            self.updateTapped(status: false)
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let conversationID = message.conversationID
        let messageID = message.messageID
        self.viewModel.getConversation(conversationID: conversationID, messageID: messageID) { [weak self] result in
            guard let self = self else { return }

            self.updateTapped(status: false)
            MBProgressHUD.hide(for: self.view, animated: true)

            switch result {
            case .success(let conversation):
                let coordinator = ConversationCoordinator(
                    labelId: self.viewModel.labelID,
                    navigationController: navigation,
                    conversation: conversation,
                    highlightedKeywords: self.query.components(separatedBy: .whitespacesAndNewlines),
                    dependencies: self.dependencies,
                    targetID: messageID
                )
                coordinator.goToDraft = { [weak self] msgID, _ in
                    guard let self = self else { return }
                    // trigger the data to be updated.
                    _ = self.textFieldShouldReturn(self.customView.searchBar.textField)
                    self.showComposer(msgID: msgID)
                }
                coordinator.start()
            case .failure(let error):
                error.alert(at: nil)
            }
        }
    }

    private func showCheckOptions(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        let point: CGPoint = longPressGestureRecognizer.location(in: customView.tableView)
        let indexPath: IndexPath? = customView.tableView.indexPathForRow(at: point)
        guard let touchedRowIndexPath = indexPath,
              longPressGestureRecognizer.state == .began && listEditing == false else { return }
        enterListEditingMode(indexPath: touchedRowIndexPath)
    }

    private func hideCheckOptions() {
        guard listEditing else { return }
        self.listEditing = false
        customView.tableView.reloadData()
    }

    private func enterListEditingMode(indexPath: IndexPath) {
        self.listEditing = true

        guard let visibleRowsIndexPaths = customView.tableView.indexPathsForVisibleRows else { return }
        visibleRowsIndexPaths.forEach { visibleRowIndexPath in
            let visibleCell = customView.tableView.cellForRow(at: visibleRowIndexPath)
            guard let messageCell = visibleCell as? NewMailboxMessageCell else { return }
            cellPresenter.presentSelectionStyle(style: .selection(isSelected: false), in: messageCell.customView)
            guard indexPath == visibleRowIndexPath else { return }
            tableView(customView.tableView, didSelectRowAt: indexPath)
        }
    }

    private func handleEditingDataSelection(of id: String, indexPath: IndexPath) {
        let itemAlreadySelected = self.viewModel.isSelected(messageID: id)
        let selectionAction = itemAlreadySelected ? self.viewModel.removeSelected : self.viewModel.addSelected
        selectionAction(id)

        if self.viewModel.selectedIDs.isEmpty {
            self.hideActionBar()
        } else {
            self.refreshActionBarItems()
            self.showActionBar()
        }

        // update checkbox state
        if let mailboxCell = customView.tableView.cellForRow(at: indexPath) as? NewMailboxMessageCell {
            cellPresenter.presentSelectionStyle(
                style: .selection(isSelected: !itemAlreadySelected),
                in: mailboxCell.customView
            )
        }

        customView.tableView.deselectRow(at: indexPath, animated: true)
    }

    private func cancelEditingMode() {
        self.viewModel.removeAllSelectedIDs()
        self.hideCheckOptions()
        self.hideActionBar()
        self.hideActionSheet()
    }

    private func showSenderImageIfNeeded(
        in cell: NewMailboxMessageCell,
        item: MailboxItem
    ) {
        viewModel.fetchSenderImageIfNeeded(
            item: item,
            isDarkMode: isDarkMode,
            scale: currentScreenScale) { [weak self, weak cell] image in
                if let image = image, let cell = cell, cell.mailboxItem == item {
                    self?.cellPresenter.presentSenderImage(image, in: cell.customView)
                }
            }
    }
}

extension SearchViewController: SearchViewUIProtocol {
    func update(progress: Float) {
        customView.progressView.setProgress(progress, animated: true)
    }

    func setupProgressBar(isHidden: Bool) {
        customView.progressView.isHidden = isHidden
    }

    func checkNoResultView() {
        if customView.activityIndicator.isAnimating {
            customView.hideNoResult()
            return
        }
        if viewModel.messages.isEmpty {
            customView.showNoResult()
        } else {
            customView.hideNoResult()
        }
    }

    func activityIndicator(isAnimating: Bool) {
        isAnimating ? customView.activityIndicator.startAnimating(): customView.activityIndicator.stopAnimating()
        if isAnimating {
            customView.hideNoResult()
        }
    }

    func reloadTable() {
        self.checkNoResultView()
        customView.tableView.reloadData()
    }
}

// MARK: - UITableView
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let mailboxCell = tableView.dequeueReusableCell(
                withIdentifier: NewMailboxMessageCell.defaultID(),
                for: indexPath
        ) as? NewMailboxMessageCell else {
            assert(false)
            return UITableViewCell()
        }

        let message = self.viewModel.messages[indexPath.row]
        let viewModel = self.viewModel.getMessageCellViewModel(message: message)
        cellPresenter.present(
            viewModel: viewModel,
            in: mailboxCell.customView,
            highlightedKeywords: query.components(separatedBy: .whitespacesAndNewlines)
        )

        showSenderImageIfNeeded(in: mailboxCell, item: .message(message))

        mailboxCell.mailboxItem = .message(message)
        mailboxCell.cellDelegate = self
        mailboxCell.generateCellAccessibilityIdentifiers(message.title)
        return mailboxCell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.zeroMargin()
        self.viewModel.loadMoreDataIfNeeded(currentRow: indexPath.row)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.viewModel.messages[indexPath.row]
        let breadcrumbMsg = "SearchVC selected message (msgId: \(message.messageID.rawValue), convId: \(message.conversationID.rawValue)"
        Breadcrumbs.shared.add(message: breadcrumbMsg, to: .malformedConversationRequest)
        guard !listEditing else {
            self.handleEditingDataSelection(of: message.messageID.rawValue,
                                            indexPath: indexPath)
            return
        }
        if self.getTapped() {
            // Fetching other draft data
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        self.prepareFor(message: message)
    }
}

extension SearchViewController: NewMailboxMessageCellDelegate {
    func didSelectButtonStatusChange(cell: NewMailboxMessageCell) {
        guard let indexPath = customView.tableView.indexPath(for: cell) else { return }

        if !listEditing {
            self.enterListEditingMode(indexPath: indexPath)
        } else {
            tableView(customView.tableView, didSelectRowAt: indexPath)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        customView.searchBar.clearButton.isHidden = (textField.text?.isEmpty ?? true)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        query = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        customView.searchBar.clearButton.isHidden = query.isEmpty == true
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customView.searchBar.clearButton.isHidden = true
        textField.resignFirstResponder()
        self.query = self.query.trim()
        textField.text = self.query
        guard !self.query.isEmpty else {
            return true
        }
        self.viewModel.fetchRemoteData(query: self.query, fromStart: true)
        self.cancelEditingMode()
        return true
    }
}

extension SearchViewController: UndoActionHandlerBase {
    var undoActionManager: UndoActionManagerProtocol? {
        nil
    }

    var delaySendSeconds: Int {
        self.viewModel.user.userInfo.delaySendSeconds
    }

    var composerPresentingVC: UIViewController? {
        navigationController
    }

    func showUndoAction(undoTokens: [String], title: String) { }
}
