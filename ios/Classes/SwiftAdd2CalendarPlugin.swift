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
      let channel = FlutterMethodChannel(name: "add_2_calendar", binaryMessenger: registrar.messenger())
      let instance = SwiftAdd2CalendarPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method == "add2Cal" {
        let args = call.arguments as! [String:Any]
       
          
        addEventToCalendar(from: args,completion:{ (success) -> Void in
              if success {
                  result(true)
              } else {
                  result(false)
              }
          })
      }
    }

    private func addEventToCalendar(from args: [String:Any], completion: ((_ success: Bool) -> Void)? = nil) {
        
        
        let title = args["title"] as! String
        let description = args["desc"] is NSNull ? nil: args["desc"] as! String
        let location = args["location"] is NSNull ? nil: args["location"] as! String
        let timeZone = args["timeZone"] is NSNull ? nil: TimeZone(identifier: args["timeZone"] as! String)
        let startDate = Date(milliseconds: (args["startDate"] as! Double))
        let endDate = Date(milliseconds: (args["endDate"] as! Double))
        let primaryAlert = args["primaryAlert"] as? Double
        let secondaryAlert = args["secondaryAlert"] as? Double
        let allDay = args["allDay"] as! Bool
        let url = args["url"] as? String
        
        
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)

                
                if let alert = primaryAlert{
                    event.addAlarm(EKAlarm(relativeOffset: alert*(-1)))
                }
                
                if let secondAlert = secondaryAlert{
                    event.addAlarm(EKAlarm(relativeOffset: secondAlert*(-1)))
                }
                
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                if (timeZone != nil) {
                    event.timeZone = timeZone
                }
                if (location != nil) {
                    event.location = location
                }
                if (description != nil) {
                    event.notes = description
                }
                if let url = url{
                    event.url = URL(string: url);
                }
                event.isAllDay = allDay
                
                if let recurrence = args["recurrence"] as? [String:Any]{
                    let interval = recurrence["interval"] as! Int
                    let frequency = recurrence["frequency"] as! Int
                    let end = recurrence["endDate"] as? Double// Date(milliseconds: (args["startDate"] as! Double))
                    let ocurrences = recurrence["ocurrences"] as? Int
                    
                    let recurrenceRule = EKRecurrenceRule.init(
                        recurrenceWith: EKRecurrenceFrequency(rawValue: frequency)!,
                        interval: interval,
                        end: ocurrences != nil ? EKRecurrenceEnd.init(occurrenceCount: ocurrences!) : end != nil ? EKRecurrenceEnd.init(end: Date(milliseconds: end!)) : nil
                    )
                    event.recurrenceRules = [recurrenceRule]
                }
                
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
        default:
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

