//
//  ContactsViewController.swift
//  Proton Mail - Created on 3/6/17.
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

import Contacts
import CoreData
import LifetimeTracker
import MBProgressHUD
import ProtonCore_UIFoundations
import UIKit

protocol ContactsVCUIProtocol: AnyObject {
    func reloadTable()
}

final class ContactsViewController: ContactsAndGroupsSharedCode {
    typealias Dependencies = HasContactViewsFactory & ContactsAndGroupsSharedCode.Dependencies

    class var lifetimeConfiguration: LifetimeConfiguration {
        .init(maxCount: 1)
    }

    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var searchView: UIView!
    @IBOutlet var searchViewConstraint: NSLayoutConstraint!

    private let viewModel: ContactsViewModel
    private let dependencies: Dependencies
    private var searchString: String = ""
    private var refreshControl: UIRefreshControl?
    private var searchController: UISearchController?
    private let internetConnectionStatusProvider = InternetConnectionStatusProvider.shared

    deinit {
        self.viewModel.resetFetchedController()
    }

    init(viewModel: ContactsViewModel, dependencies: Dependencies) {
        self.viewModel = viewModel
        self.dependencies = dependencies
        super.init(dependencies: dependencies, nibName: "ContactsViewController")
        trackLifetime()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ColorProvider.BackgroundNorm

        self.tableView.register(ContactsTableViewCell.nib,
                                forCellReuseIdentifier: ContactsTableViewCell.cellID)
        let refreshControl = UIRefreshControl()
        self.refreshControl = refreshControl
        self.refreshControl?.addTarget(self,
                                      action: #selector(self.fireFetch),
                                      for: UIControl.Event.valueChanged)

        self.tableView.estimatedRowHeight = 60.0
        self.tableView.addSubview(refreshControl)
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.refreshControl?.tintColor = ColorProvider.BrandNorm
        self.refreshControl?.tintColorDidChange()

        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        self.tableView.noSeparatorsBelowFooter()
        self.tableView.sectionIndexColor = ColorProvider.BrandNorm
        self.tableView.backgroundColor = ColorProvider.BackgroundNorm

        //get all contacts
        self.viewModel.setupFetchedResults()
        self.viewModel.setup(uiDelegate: self)
        self.prepareSearchBar()

        emptyBackButtonTitleForNextView()

        setupMenuButton()

        prepareNavigationItemRightDefault()

        generateAccessibilityIdentifiers()
        navigationItem.assignNavItemIndentifiers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.setEditing(false, animated: true)
        self.title = LocalString._contacts_title

        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.setupTimer(true)
        NotificationCenter.default.addKeyboardObserver(self)

        self.isOnMainView = true

        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .layoutChanged,
                                 argument: self.navigationController?.view)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.stopTimer()
        NotificationCenter.default.removeKeyboardObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    // run once
    private func prepareSearchBar() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.searchBar.placeholder = LocalString._general_search_placeholder
        self.searchController?.searchResultsUpdater = self
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.hidesNavigationBarDuringPresentation = true
        self.searchController?.searchBar.sizeToFit()
        self.searchController?.searchBar.keyboardType = .default
        self.searchController?.searchBar.keyboardAppearance = .light
        self.searchController?.searchBar.autocapitalizationType = .none
        self.searchController?.searchBar.isTranslucent = false
        self.searchController?.searchBar.tintColor = ColorProvider.TextNorm
        self.searchController?.searchBar.barTintColor = ColorProvider.BackgroundNorm
        self.searchController?.searchBar.backgroundColor = .clear

        self.searchViewConstraint.constant = 0.0
        self.searchView.isHidden = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = self.searchController
        self.navigationItem.assignNavItemIndentifiers()
    }

    override func addContactGroupTapped() {
        if viewModel.user.hasPaidMailPlan {
            let newView = dependencies.contactViewsFactory.makeGroupEditView(
                state: .create,
                groupID: nil,
                name: nil,
                color: nil,
                emailIDs: []
            )
            let nav = UINavigationController(rootViewController: newView)
            self.present(nav, animated: true, completion: nil)
        } else {
            presentPlanUpgrade()
        }
    }

    override func showContactImportView() {
        self.isOnMainView = true

        let newView = dependencies.contactViewsFactory.makeImportView()
        setPresentationStyleForSelfController(presentingController: newView, style: .overFullScreen)
        newView.reloadAllContact = { [weak self] in
            self?.tableView.reloadData()
        }
        self.present(newView, animated: false, completion: nil)
    }

    private func showContactDetailView(contact: ContactEntity) {
        let newView = dependencies.contactViewsFactory.makeDetailView(contact: contact)
        self.show(newView, sender: nil)
        isOnMainView = false

            // detect view dismiss above iOS 13
            if let nav = self.navigationController {
                nav.children[0].presentationController?.delegate = self
            }
            newView.presentationController?.delegate = self
    }

    override func addContactTapped() {
        let newView = dependencies.contactViewsFactory.makeEditView(contact: nil)
        let nav = UINavigationController(rootViewController: newView)
        self.present(nav, animated: true)

            // detect view dismiss above iOS 13
            nav.children[0].presentationController?.delegate = self
            nav.presentationController?.delegate = self
    }

    @objc internal func fireFetch() {
        guard internetConnectionStatusProvider.status.isConnected else {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            return
        }
        self.viewModel.fetchContacts { [weak self] error in
            if let error = error as NSError? {
                let alertController = error.alertController()
                alertController.addOKAction()
                self?.present(alertController, animated: true, completion: nil)
            }
            self?.refreshControl?.endRefreshing()
        }
    }

    private func showDeleteContactAlert(for contact: ContactEntity) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(
            UIAlertAction(title: LocalString._general_cancel_button, style: .cancel, handler: nil)
        )
        alertController.addAction(
            UIAlertAction(
                title: LocalString._delete_contact,
                style: .destructive,
                handler: { _ in
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.viewModel.delete(contactID: contact.contactID, complete: { error in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        if let err = error {
                            err.alert(at: self.view)
                        }
                    })
                }
            )
        )

        alertController.popoverPresentationController?.sourceView = tableView
        alertController.popoverPresentationController?.sourceRect = CGRect(
            x: tableView.bounds.midX,
            y: tableView.bounds.maxY - 100,
            width: 0,
            height: 0
        )
        alertController.assignActionsAccessibilityIdentifiers()
        present(alertController, animated: true, completion: nil)
    }
}

// Search part
extension ContactsViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchString = searchController.searchBar.text ?? ""
        self.viewModel.search(text: self.searchString)
        self.tableView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.refreshControl?.endRefreshing()
        self.refreshControl?.removeFromSuperview()
        self.viewModel.set(searching: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let refreshControl = self.refreshControl {
            self.tableView.addSubview(refreshControl)
        }
        self.viewModel.set(searching: false)
    }
}

// MARK: - UITableViewDataSource
extension ContactsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowCount(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactsTableViewCell.cellID,
                                                 for: indexPath)
        if let contactCell = cell as? ContactsTableViewCell {
            if let contact = self.viewModel.item(index: indexPath) {
                contactCell.config(name: contact.name,
                                   email: contact.displayEmails,
                                   highlight: self.searchString)
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let contextItem = UIContextualAction(
            style: .destructive,
            title: LocalString._general_delete_action
        ) { [weak self] action, view, completion in
            guard let self,
                  let contact = self.viewModel.item(index: indexPath) else {
                completion(false)
                return
            }
            self.showDeleteContactAlert(for: contact)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [contextItem])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let contact = self.viewModel.item(index: indexPath) {
            self.showContactDetailView(contact: contact)
        }
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.viewModel.sectionForSectionIndexTitle(title: title, at: index)
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.viewModel.sectionIndexTitle()
    }
}

// MARK: - NSNotificationCenterKeyboardObserverProtocol

extension ContactsViewController: NSNotificationCenterKeyboardObserverProtocol {
    func keyboardWillHideNotification(_ notification: Notification) {
        self.tableViewBottomConstraint.constant = 0
        let keyboardInfo = notification.keyboardInfo
        UIView.animate(withDuration: keyboardInfo.duration,
                       delay: 0,
                       options: keyboardInfo.animationOption,
                       animations: { () in
                           self.view.layoutIfNeeded()
                       }, completion: nil)
    }

    func keyboardWillShowNotification(_ notification: Notification) {
        let keyboardInfo = notification.keyboardInfo
        let info: NSDictionary = notification.userInfo! as NSDictionary
        if let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableViewBottomConstraint.constant = keyboardSize.height

            UIView.animate(withDuration: keyboardInfo.duration,
                           delay: 0,
                           options: keyboardInfo.animationOption,
                           animations: { () in
                               self.view.layoutIfNeeded()
                           }, completion: nil)
        }
    }
}

extension ContactsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        self.isOnMainView = true
    }
}

extension ContactsViewController: ContactsVCUIProtocol {
    func reloadTable() {
        self.tableView.reloadData()
    }
}
