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
      if call.method == "getContacts"{
		self?.getContacts(result: result)
	  } else if call.method == "saveNewContact" {
		self?.getContacts(result: result)
	  } else {
		result(FlutterMethodNotImplemented)
        return
	  }
    })


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  
//- (void)saveNewContact{
//    //1.创建Contact对象，必须是可变的
//    CNMutableContact *contact = [[CNMutableContact alloc] init];
//    //2.为contact赋值，setValue4Contact中会给出常用值的对应关系
//    [self setValue4Contact:contact existContect:NO];
//    //3.创建新建好友页面
//    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
//    //代理内容根据自己需要实现
//    controller.delegate = self;
//    //4.跳转
//    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
//    [self presentViewController:navigation animated:YES completion:^{
//
//    }];
//
//}

  private func saveNewContact() {
//	let contact = CNMutableContact.init();
//	let controller = CNContactViewController.targetViewController(<#T##self: UIViewController##UIViewController#>)
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
        
            //1.获取姓名
            let lastName = contact.familyName
            let firstName = contact.givenName
            let identifier = contact.identifier
//            print("姓名 : \(lastName)\(firstName)")
            
            //2.获取电话号码
            var numbers : [[String: String?]] = []
            
            
            let phoneNumbers = contact.phoneNumbers
            for phoneNumber in phoneNumbers
            {
				print(phoneNumber.value.stringValue)
				numbers.append(["label": phoneNumber.label, "value": phoneNumber.value.stringValue])
            }
            contacts.append(["identifier": identifier, "firstName": firstName, "lastName": lastName, "phoneNumbers": numbers ]);
            
        })
    } catch {
        result(FlutterError(code: DialFlutterErrorCode.unavailable,
                          message: "不可用",
                          details: nil))
        return
	}
    result(contacts)
  }
}
