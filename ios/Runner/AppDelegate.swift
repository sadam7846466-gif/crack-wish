import Flutter
import UIKit
import Contacts

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
      
      let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey] as [CNKeyDescriptor]
      let request = CNContactFetchRequest(keysToFetch: keys)
      
      var contacts: [[String: Any]] = []
      
      do {
        try store.enumerateContacts(with: request) { contact, _ in
          let emails = contact.emailAddresses.map { $0.value as String }
          if !emails.isEmpty {
            contacts.append([
              "name": "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces),
              "emails": emails
            ])
          }
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
