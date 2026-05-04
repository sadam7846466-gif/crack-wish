import Flutter
import UIKit
import Contacts
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ⚠️ FirebaseApp.configure() burada ÇAĞIRILMAMALI!
    // Flutter tarafındaki Firebase.initializeApp() zaten native configure yapıyor.
    // İkisi birden olursa Supabase auth session bozulur.
    
    // ── iOS Push Notification (APNs) Kayıt ──
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ── APNs Token → Firebase Messaging'e ilet ──
  // iOS cihaz APNs token'ını aldığında Firebase'e aktarır.
  // Bu callback, registerForRemoteNotifications() sonrası sistem tarafından çağrılır
  // ve bu noktada Flutter engine + Firebase.initializeApp() zaten tamamlanmış olur.
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Firebase bu noktada Flutter tarafından configure edilmiş olacak.
    // Delegate'i burada set etmek, race condition'ı önler.
    Messaging.messaging().delegate = self
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // ── FCM Token yenilendiğinde ──
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔔 FCM Token yenilendi: \(fcmToken ?? "nil")")
  }

  // ── Arka planda gelen sessiz bildirimler ──
  override func application(_ application: UIApplication,
                            didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                            fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    completionHandler(.newData)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "ContactsBridge") else { return }
    let messenger = registrar.messenger()
    
    let channel = FlutterMethodChannel(name: "com.crackwish/contacts", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getContacts" {
        self?.fetchContacts(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func fetchContacts(result: @escaping FlutterResult) {
    let store = CNContactStore()
    store.requestAccess(for: .contacts) { granted, error in
      if !granted {
        DispatchQueue.main.async {
          result(FlutterError(code: "PERMISSION_DENIED", message: "Rehber izni reddedildi", details: nil))
        }
        return
      }
      
      let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
      let request = CNContactFetchRequest(keysToFetch: keys)
      
      var contacts: [[String: Any]] = []
      
      do {
        try store.enumerateContacts(with: request) { contact, _ in
          let emails = contact.emailAddresses.map { $0.value as String }
          let phones = contact.phoneNumbers.map { $0.value.stringValue }
          contacts.append([
            "name": "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces),
            "emails": emails,
            "phones": phones
          ])
        }
        DispatchQueue.main.async {
          result(contacts)
        }
      } catch {
        DispatchQueue.main.async {
          result(FlutterError(code: "FETCH_ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }
}
