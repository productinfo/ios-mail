// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import ProtonCore_Keymaker
import ProtonCore_Services

protocol HasAttachmentMetadataStrippingProtocol {
    var attachmentMetadataStripStatusProvider: AttachmentMetadataStrippingProtocol { get }
}

extension GlobalContainer: HasAttachmentMetadataStrippingProtocol {
    var attachmentMetadataStripStatusProvider: AttachmentMetadataStrippingProtocol {
        attachmentMetadataStripStatusProviderFactory()
    }
}

extension UserContainer: HasAttachmentMetadataStrippingProtocol {
    var attachmentMetadataStripStatusProvider: AttachmentMetadataStrippingProtocol {
        globalContainer.attachmentMetadataStripStatusProvider
    }
}

protocol HasCachedUserDataProvider {
    var cachedUserDataProvider: CachedUserDataProvider { get }
}

extension GlobalContainer: HasCachedUserDataProvider {
    var cachedUserDataProvider: CachedUserDataProvider {
        cachedUserDataProviderFactory()
    }
}

extension UserContainer: HasCachedUserDataProvider {
    var cachedUserDataProvider: CachedUserDataProvider {
        globalContainer.cachedUserDataProvider
    }
}

protocol HasCoreDataContextProviderProtocol {
    var contextProvider: CoreDataContextProviderProtocol { get }
}

extension GlobalContainer: HasCoreDataContextProviderProtocol {
    var contextProvider: CoreDataContextProviderProtocol {
        contextProviderFactory()
    }
}

extension UserContainer: HasCoreDataContextProviderProtocol {
    var contextProvider: CoreDataContextProviderProtocol {
        globalContainer.contextProvider
    }
}

protocol HasFeatureFlagCache {
    var featureFlagCache: FeatureFlagCache { get }
}

extension GlobalContainer: HasFeatureFlagCache {
    var featureFlagCache: FeatureFlagCache {
        featureFlagCacheFactory()
    }
}

extension UserContainer: HasFeatureFlagCache {
    var featureFlagCache: FeatureFlagCache {
        globalContainer.featureFlagCache
    }
}

protocol HasInternetConnectionStatusProviderProtocol {
    var internetConnectionStatusProvider: InternetConnectionStatusProviderProtocol { get }
}

extension GlobalContainer: HasInternetConnectionStatusProviderProtocol {
    var internetConnectionStatusProvider: InternetConnectionStatusProviderProtocol {
        internetConnectionStatusProviderFactory()
    }
}

extension UserContainer: HasInternetConnectionStatusProviderProtocol {
    var internetConnectionStatusProvider: InternetConnectionStatusProviderProtocol {
        globalContainer.internetConnectionStatusProvider
    }
}

protocol HasKeychain {
    var keychain: Keychain { get }
}

extension GlobalContainer: HasKeychain {
    var keychain: Keychain {
        keychainFactory()
    }
}

extension UserContainer: HasKeychain {
    var keychain: Keychain {
        globalContainer.keychain
    }
}

protocol HasKeyMakerProtocol {
    var keyMaker: KeyMakerProtocol { get }
}

extension GlobalContainer: HasKeyMakerProtocol {
    var keyMaker: KeyMakerProtocol {
        keyMakerFactory()
    }
}

extension UserContainer: HasKeyMakerProtocol {
    var keyMaker: KeyMakerProtocol {
        globalContainer.keyMaker
    }
}

protocol HasLastUpdatedStore {
    var lastUpdatedStore: LastUpdatedStore { get }
}

extension GlobalContainer: HasLastUpdatedStore {
    var lastUpdatedStore: LastUpdatedStore {
        lastUpdatedStoreFactory()
    }
}

extension UserContainer: HasLastUpdatedStore {
    var lastUpdatedStore: LastUpdatedStore {
        globalContainer.lastUpdatedStore
    }
}

protocol HasLockCacheStatus {
    var lockCacheStatus: LockCacheStatus { get }
}

extension GlobalContainer: HasLockCacheStatus {
    var lockCacheStatus: LockCacheStatus {
        lockCacheStatusFactory()
    }
}

extension UserContainer: HasLockCacheStatus {
    var lockCacheStatus: LockCacheStatus {
        globalContainer.lockCacheStatus
    }
}

protocol HasNotificationCenter {
    var notificationCenter: NotificationCenter { get }
}

extension GlobalContainer: HasNotificationCenter {
    var notificationCenter: NotificationCenter {
        notificationCenterFactory()
    }
}

extension UserContainer: HasNotificationCenter {
    var notificationCenter: NotificationCenter {
        globalContainer.notificationCenter
    }
}

protocol HasPinFailedCountCache {
    var pinFailedCountCache: PinFailedCountCache { get }
}

extension GlobalContainer: HasPinFailedCountCache {
    var pinFailedCountCache: PinFailedCountCache {
        pinFailedCountCacheFactory()
    }
}

extension UserContainer: HasPinFailedCountCache {
    var pinFailedCountCache: PinFailedCountCache {
        globalContainer.pinFailedCountCache
    }
}

protocol HasQueueManager {
    var queueManager: QueueManager { get }
}

extension GlobalContainer: HasQueueManager {
    var queueManager: QueueManager {
        queueManagerFactory()
    }
}

extension UserContainer: HasQueueManager {
    var queueManager: QueueManager {
        globalContainer.queueManager
    }
}

protocol HasUnlockManager {
    var unlockManager: UnlockManager { get }
}

extension GlobalContainer: HasUnlockManager {
    var unlockManager: UnlockManager {
        unlockManagerFactory()
    }
}

extension UserContainer: HasUnlockManager {
    var unlockManager: UnlockManager {
        globalContainer.unlockManager
    }
}

protocol HasUsersManager {
    var usersManager: UsersManager { get }
}

extension GlobalContainer: HasUsersManager {
    var usersManager: UsersManager {
        usersManagerFactory()
    }
}

extension UserContainer: HasUsersManager {
    var usersManager: UsersManager {
        globalContainer.usersManager
    }
}

protocol HasUserCachedStatus {
    var userCachedStatus: UserCachedStatus { get }
}

extension GlobalContainer: HasUserCachedStatus {
    var userCachedStatus: UserCachedStatus {
        userCachedStatusFactory()
    }
}

extension UserContainer: HasUserCachedStatus {
    var userCachedStatus: UserCachedStatus {
        globalContainer.userCachedStatus
    }
}

protocol HasUserIntroductionProgressProvider {
    var userIntroductionProgressProvider: UserIntroductionProgressProvider { get }
}

extension GlobalContainer: HasUserIntroductionProgressProvider {
    var userIntroductionProgressProvider: UserIntroductionProgressProvider {
        userIntroductionProgressProviderFactory()
    }
}

extension UserContainer: HasUserIntroductionProgressProvider {
    var userIntroductionProgressProvider: UserIntroductionProgressProvider {
        globalContainer.userIntroductionProgressProvider
    }
}

protocol HasAPIService {
    var apiService: APIService { get }
}

extension UserContainer: HasAPIService {
    var apiService: APIService {
        apiServiceFactory()
    }
}

protocol HasCacheService {
    var cacheService: CacheService { get }
}

extension UserContainer: HasCacheService {
    var cacheService: CacheService {
        cacheServiceFactory()
    }
}

protocol HasComposerViewFactory {
    var composerViewFactory: ComposerViewFactory { get }
}

extension UserContainer: HasComposerViewFactory {
    var composerViewFactory: ComposerViewFactory {
        composerViewFactoryFactory()
    }
}

protocol HasContactDataService {
    var contactService: ContactDataService { get }
}

extension UserContainer: HasContactDataService {
    var contactService: ContactDataService {
        contactServiceFactory()
    }
}

protocol HasContactGroupsDataService {
    var contactGroupService: ContactGroupsDataService { get }
}

extension UserContainer: HasContactGroupsDataService {
    var contactGroupService: ContactGroupsDataService {
        contactGroupServiceFactory()
    }
}

protocol HasConversationDataServiceProxy {
    var conversationService: ConversationDataServiceProxy { get }
}

extension UserContainer: HasConversationDataServiceProxy {
    var conversationService: ConversationDataServiceProxy {
        conversationServiceFactory()
    }
}

protocol HasConversationStateService {
    var conversationStateService: ConversationStateService { get }
}

extension UserContainer: HasConversationStateService {
    var conversationStateService: ConversationStateService {
        conversationStateServiceFactory()
    }
}

protocol HasEventsFetching {
    var eventsService: EventsFetching { get }
}

extension UserContainer: HasEventsFetching {
    var eventsService: EventsFetching {
        eventsServiceFactory()
    }
}

protocol HasFeatureFlagsDownloadService {
    var featureFlagsDownloadService: FeatureFlagsDownloadService { get }
}

extension UserContainer: HasFeatureFlagsDownloadService {
    var featureFlagsDownloadService: FeatureFlagsDownloadService {
        featureFlagsDownloadServiceFactory()
    }
}

protocol HasFetchAndVerifyContacts {
    var fetchAndVerifyContacts: FetchAndVerifyContacts { get }
}

extension UserContainer: HasFetchAndVerifyContacts {
    var fetchAndVerifyContacts: FetchAndVerifyContacts {
        fetchAndVerifyContactsFactory()
    }
}

protocol HasFetchAttachment {
    var fetchAttachment: FetchAttachment { get }
}

extension UserContainer: HasFetchAttachment {
    var fetchAttachment: FetchAttachment {
        fetchAttachmentFactory()
    }
}

protocol HasIncomingDefaultService {
    var incomingDefaultService: IncomingDefaultService { get }
}

extension UserContainer: HasIncomingDefaultService {
    var incomingDefaultService: IncomingDefaultService {
        incomingDefaultServiceFactory()
    }
}

protocol HasLabelsDataService {
    var labelService: LabelsDataService { get }
}

extension UserContainer: HasLabelsDataService {
    var labelService: LabelsDataService {
        labelServiceFactory()
    }
}

protocol HasLocalNotificationService {
    var localNotificationService: LocalNotificationService { get }
}

extension UserContainer: HasLocalNotificationService {
    var localNotificationService: LocalNotificationService {
        localNotificationServiceFactory()
    }
}

protocol HasMessageDataService {
    var messageService: MessageDataService { get }
}

extension UserContainer: HasMessageDataService {
    var messageService: MessageDataService {
        messageServiceFactory()
    }
}

protocol HasQueueHandler {
    var queueHandler: QueueHandler { get }
}

extension UserContainer: HasQueueHandler {
    var queueHandler: QueueHandler {
        queueHandlerFactory()
    }
}

protocol HasUndoActionManagerProtocol {
    var undoActionManager: UndoActionManagerProtocol { get }
}

extension UserContainer: HasUndoActionManagerProtocol {
    var undoActionManager: UndoActionManagerProtocol {
        undoActionManagerFactory()
    }
}

protocol HasUserDataService {
    var userService: UserDataService { get }
}

extension UserContainer: HasUserDataService {
    var userService: UserDataService {
        userServiceFactory()
    }
}

protocol HasUserManager {
    var user: UserManager { get }
}

extension UserContainer: HasUserManager {
    var user: UserManager {
        userFactory()
    }
}

