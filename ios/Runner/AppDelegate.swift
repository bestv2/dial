import UIKit
import Flutter
import Contacts
import ContactsUI



enum ChannelName {
  static let contacts = "dial.flutter.io/contacts"
}
enum DialFlutterErrorCode {
  static let unavailable = "UNAVAILABLE"
  static let unauthorized = "unauthorized"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }
    let contactChannel = FlutterMethodChannel(name: ChannelName.contacts,
                                              binaryMessenger: controller.binaryMessenger)
    contactChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      switch call.method {
		case "getContacts":
			self?.getContacts(result: result)
		case "addContact":
			var contact: CNMutableContact;
			var dictionary : [String:Any?] = call.args
			if( dictionary["identifier"] != nil) {
				do {
					
        
        let store = CNContactStore()
        var keys = [
                                  CNContactBirthdayKey,
                                  CNContactDatesKey,
                                  CNContactEmailAddressesKey,
                                  CNContactFamilyNameKey,
                                  CNContactGivenNameKey,
                                  CNContactJobTitleKey,
                                  CNContactMiddleNameKey,
                                  CNContactNamePrefixKey,
                                  CNContactNameSuffixKey,
                                  CNContactThumbnailImageDataKey,
                                  CNContactOrganizationNameKey,
                                  CNContactPhoneNumbersKey,
                                  CNContactPostalAddressesKey,
                                  CNContactSocialProfilesKey,
                                  CNContactUrlAddressesKey] as [CNKeyDescriptor]

        
        // Check if the contact exists
        var identifier: String = ""
        if let id = dictionary["identifier"] as? String  {
			identifier = id
		}

        if let contact = try store.unifiedContact(withIdentifier: identifier , keysToFetch: keys).mutableCopy() as? CNMutableContact {
            contact.takeFromDictionary(call.args)
            print(contact)
				do {
					let saved = try self?.updateContact(contact: contact)
					result(saved?.toDictionary())
				} catch {
					result(FlutterError(code: DialFlutterErrorCode.unavailable,
                          message: "不可用",
                          details: nil))
				}
           
           
        } else {
            throw PluginError.runtimeError(code: "contact.notFound", message: "Couldn't find contact")
        }
				} catch {
				
				}
			}else {
				contact = CNMutableContact()
				contact.takeFromDictionary(call.args)
				do {
					let saved = try self?.addContact(contact: contact)
					result(saved?.toDictionary())
				} catch {
					result(FlutterError(code: DialFlutterErrorCode.unavailable,
                          message: "不可用",
                          details: nil))
				}
			}
			
			
			
			
			
		default :
			result(FlutterMethodNotImplemented)
	  }
      return
    })


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getContacts(result: FlutterResult) {
    //1.获取授权状态
	let status = CNContactStore.authorizationStatus(for: .contacts)
    guard status == .authorized  else {
      result(FlutterError(code: DialFlutterErrorCode.unauthorized,
                          message: "未授权",
                          details: nil))
      return
    }
    var contacts : [[String:Any]] = []
    
    //3.创建通讯录对象
        let store = CNContactStore()
        
    //4.从通讯录中获取所有联系人
        
        //获取Fetch,并且指定之后要获取联系人中的什么属性
        let keys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey]
        
        
        //创建请求对象   需要传入一个(keysToFetch: [CNKeyDescriptor]) 包含'CNKeyDescriptor'类型的数组
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        //遍历所有联系人
        //需要传入一个CNContactFetchRequest
    do {
        try store.enumerateContacts(with: request, usingBlock: {(contact : CNContact, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
            contacts.append(contact.toDictionary());
        })
    } catch {
        result(FlutterError(code: DialFlutterErrorCode.unavailable,
                          message: "不可用",
                          details: nil))
        return
	}
    result(contacts)
  }
  
  @available(iOS 9.0, *)
  private func addContact(contact : CNMutableContact) throws -> CNMutableContact  {
      let store = CNContactStore()
      let saveRequest = CNSaveRequest()
        
      saveRequest.add(contact, toContainerWithIdentifier: nil)
      try store.execute(saveRequest)
      return contact
  }

@available(iOS 9.0, *)
  private func updateContact(contact : CNMutableContact) throws -> CNMutableContact  {
      let store = CNContactStore()
      let request = CNSaveRequest()
      request.update(contact)
      try store.execute(request)
      return contact
  }
}
