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
public class Add2CalendarPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "add_2_calendar", binaryMessenger: registrar.messenger())
    let instance = Add2CalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

 public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      if call.method == "add2Cal" {
        let args = call.arguments as! [String:Any]
        
        addEventToCalendar(from: args, result: result)
      }
    }

    private func addEventToCalendar(from args: [String:Any], result: @escaping FlutterResult) {
        let title = args["title"] as! String
        let description = args["desc"] is NSNull ? nil: args["desc"] as? String
        let location = args["location"] is NSNull ? nil: args["location"] as? String
        let timeZone = args["timeZone"] is NSNull ? nil: TimeZone(identifier: args["timeZone"] as! String)
        let startDate = Date(milliseconds: (args["startDate"] as! Double))
        let endDate = Date(milliseconds: (args["endDate"] as! Double))
        let alarmInterval = args["alarmInterval"] as? Double
        let allDay = args["allDay"] as! Bool
        let url = args["url"] as? String
        
        let eventStore = EKEventStore()
        let event = createEvent(eventStore: eventStore, alarmInterval: alarmInterval, title: title, description: description, location: location, timeZone: timeZone, startDate: startDate, endDate: endDate, allDay: allDay, url: url, args: args)

        presentCalendarModalToAddEvent(event, eventStore: eventStore, result: result)
    }
    
    private func createEvent(eventStore: EKEventStore, alarmInterval: Double?, title: String, description: String?, location: String?, timeZone: TimeZone?, startDate: Date?, endDate: Date?, allDay: Bool, url: String?, args: [String:Any]) -> EKEvent {
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
        
        return event
    }

    private func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    // Show event kit ui to add event to calendar
    
    func presentCalendarModalToAddEvent(_ event: EKEvent, eventStore: EKEventStore, result: @escaping FlutterResult) {
        if #available(iOS 17, *) {
            OperationQueue.main.addOperation {
                self.presentEventCalendarDetailModal(
                    event: event,
                    eventStore: eventStore,
                    result: result
                )
            }
        } else {
            let authStatus = getAuthorizationStatus()
            switch authStatus {
            case .authorized:
                OperationQueue.main.addOperation {
                    self.presentEventCalendarDetailModal(
                        event: event,
                        eventStore: eventStore,
                        result: result
                    )
                }
            case .notDetermined:
                // Auth is not determined
                // We should request access to the calendar
                eventStore.requestAccess(to: .event, completion: { [weak self] (granted, error) in
                    if granted {
                        OperationQueue.main.addOperation {
                            self?.presentEventCalendarDetailModal(event: event, eventStore: eventStore, result: result)
                        }
                    } else {
                        // Auth denied
                        result("permissionDenied")
                    }
                })
            case .denied, .restricted:
                // Auth denied or restricted
                result("permissionDenied")
            default:
                result("permissionDenied")
            }
        }
    }
    
    // Present edit event calendar modal
    
    func presentEventCalendarDetailModal(event: EKEvent, eventStore: EKEventStore, result: @escaping FlutterResult) {
        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = Add2CalendarEditViewDelegate(result: result)
        
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

class Add2CalendarEditViewDelegate: NSObject, EKEventEditViewDelegate {
    final var result: FlutterResult

    init(result: @escaping FlutterResult) {
        self.result = result
    }
    
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if action == .saved {
            result("success")
        } else {
            result("canceled")
        }

        controller.dismiss(animated: true, completion: {
            UIApplication.shared.statusBarStyle = statusBarStyle
        })
    }
}
