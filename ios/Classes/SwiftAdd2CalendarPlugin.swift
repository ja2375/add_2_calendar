import Flutter
import UIKit
import EventKit
import EventKitUI
import Foundation

extension Date {
      init(milliseconds:Double) {
          self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
      }
}

var statusBarStyle = UIApplication.shared.statusBarStyle

public class SwiftAdd2CalendarPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "flutter.javih.com/add_2_calendar", binaryMessenger: registrar.messenger())
      let instance = SwiftAdd2CalendarPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method == "add2Cal" {
          let args = call.arguments as! [String:Any]
          let title = args["title"] as! String
          let desc = args["desc"] as! String
          let location = args["location"] as! String
          let timeZone = TimeZone(identifier: args["timeZone"] as! String)
          
          addEventToCalendar(title: title,
                             description: desc,
                             location: location,
                             startDate: Date(milliseconds: (args["startDate"] as! Double)),
                             endDate: Date(milliseconds: (args["endDate"] as! Double)),
                             timeZone: timeZone,
                             alarmInterval: args["alarmInterval"] as? Double,
                             allDay: args["allDay"] as! Bool,
                             completion: { (success) -> Void in
              if success {
                  result(true)
              } else {
                  result(false)
              }
          })
      }
    }

    private func addEventToCalendar(title: String!, description: String, location: String, startDate: Date, endDate: Date, timeZone: TimeZone?, alarmInterval: Double?, allDay: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                if let alarm = alarmInterval{
                    event.addAlarm(EKAlarm(relativeOffset: alarm*(-1)))
                }
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                if (timeZone != nil) {
                    event.timeZone = timeZone
                }
                event.location = location
                event.notes = description
                event.isAllDay = allDay
                self?.presentCalendarModalToAddEvent(event, eventStore: eventStore, completion: completion)
            } else {
                completion?(false)
            }
        })
    }

    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    // Show event kit ui to add event to calendar
    
    func presentCalendarModalToAddEvent(_ event: EKEvent, eventStore: EKEventStore, completion: ((_ success: Bool) -> Void)? = nil) {
        let authStatus = getAuthorizationStatus()
        switch authStatus {
        case .authorized:
            OperationQueue.main.addOperation {
                self.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
            }
            completion?(true)
        case .notDetermined:
            //Auth is not determined
            //We should request access to the calendar
            eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
                if granted {
                    OperationQueue.main.addOperation {
                        self?.presentEventCalendarDetailModal(event: event, eventStore: eventStore)
                    }
                    completion?(true)
                } else {
                    // Auth denied
                    completion?(false)
                }
            })
        case .denied, .restricted:
            // Auth denied or restricted
            completion?(false)
        }
    }
    
    // Present edit event calendar modal
    
    func presentEventCalendarDetailModal(event: EKEvent, eventStore: EKEventStore) {
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        
        if #available(iOS 13, *) {
            eventModalVC.modalPresentationStyle = .fullScreen
        }
        
        if let root = UIApplication.shared.keyWindow?.rootViewController {
            root.present(eventModalVC, animated: true, completion: {
                statusBarStyle = UIApplication.shared.statusBarStyle
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            })
        }
    }
}

extension SwiftAdd2CalendarPlugin: EKEventEditViewDelegate {
    
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: {
            UIApplication.shared.statusBarStyle = statusBarStyle
        })
    }
}

