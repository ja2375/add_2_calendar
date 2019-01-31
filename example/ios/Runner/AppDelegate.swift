import UIKit
import Flutter
import EventKit
import EventKitUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var controller : FlutterViewController?
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        
        guard let flutterViewController  = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        
        let flutterChannel = FlutterMethodChannel.init(name: "flutter.javih.com/add_2_calendar", binaryMessenger: flutterViewController);
        flutterChannel.setMethodCallHandler { (flutterMethodCall, flutterResult) in
            if flutterMethodCall.method == "add2Cal" {
                let args = flutterMethodCall.arguments as! [String:Any]
                let title = args["title"] as! String
                let desc = args["desc"] as! String
                
                self.addEventToCalendar(title: title, description: desc, startDate: Date(milliseconds: (args["startDate"] as! Int)), endDate: Date(milliseconds: (args["endDate"] as! Int)), completion: { (success) -> Void in
                    if success {
                        flutterResult(true)
                    } else {
                        flutterResult(false)
                    }
                })
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func addEventToCalendar(title: String!, description: String, startDate: Date, endDate: Date, completion: ((_ success: Bool) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false)
                    return
                }
                completion?(true)
            } else {
                completion?(false)
            }
        })
    }
}

extension FlutterViewController: EKEventEditViewDelegate {
    
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int!) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
