import SwiftUI
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import FacebookCore

//https://any-network.firebaseapp.com/__/auth/handler
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        FirebaseConfiguration.shared.setLoggerLevel(.debug)
        
        if let facebookAppID = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String {
            print("FacebookAppID from Info.plist:", facebookAppID)
        } else {
            print("❌ FacebookAppID is missing from Info.plist")
        }

        // Set the messaging delegate
        DispatchQueue.main.async {
            Messaging.messaging().delegate = self
        }

        // Set the notification center delegate
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request authorization: \(error.localizedDescription)")
            } else if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
            print("Permission granted: \(granted)")
        }

        application.registerForRemoteNotifications()
        
        return true
    }

    // FCM Token Callback
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "Failed to get token")")
    }

    // Register APNs Token for Firebase Auth and Messaging
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs Token Received: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")

        // Ensure Firebase Auth gets the correct APNs token
        #if DEBUG
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        #else
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        #endif

        Messaging.messaging().apnsToken = deviceToken
    }

    // Handle Received Notifications
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        
        print("Received Remote Notification: \(userInfo)")
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.newData)
    }

    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        
        ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return ApplicationDelegate.shared.application(application, open: url, options: options)
    }
}

@main
struct ANY_networkApp: App {
    @State var animationFinished: Bool = false
    
    let appFactory = AppFactory()
    @StateObject var animationRedo = AnimationRedo()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            HashGenView()
//            destination
//                .background(SceneHandlerView())
//                .onChange(of: animationRedo.redoAnimation) { _, newValue in
//                    if newValue {
//                        UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.launchAnimationPlayed)
//                        animationFinished = false
//                        UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.replayAnimation)
//                    }
//                }
//                .environmentObject(animationRedo)
        }
    }
    
    @ViewBuilder
    var destination: some View {
        if !animationFinished {
            LandingView(animationFinished: $animationFinished)
                .transition(.opacity)
        } else {
            AppCoordinatorView(
                screenFactory: ScreenFactory(appFactory: appFactory),
                coordinator: AppCoordinator(getContactsStatusUseCase: appFactory.makeContactsStatus())
            )
            .transition(.opacity)
        }
    }
}

struct SceneHandlerView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        EmptyView()
            .onChange(of: scenePhase) { _ , newPhase in
                switch newPhase {
                case .active:
                    print("App is active")
                    do {
                        try HepticService.shared.start()
                    } catch {
                        print("Error starting Heptic Service:", error.localizedDescription)
                    }
                case .inactive:
                    print("App is inactive")
                case .background:
                    print("App is in background")
                    HepticService.shared.stop()
                @unknown default:
                    print("Unknown phase")
                }
            }
    }
}

#warning("For testing puproses, remove along with Combine import later")
class AnimationRedo: ObservableObject {
    @Published var redoAnimation: Bool = false
    var cancelable: AnyCancellable?

    init() {
        cancelable = $redoAnimation
            .sink { [weak self] in
                if $0 {
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        self?.redoAnimation = false
                    }
                }
            }
    }

    deinit {
        cancelable = nil
    }
}
