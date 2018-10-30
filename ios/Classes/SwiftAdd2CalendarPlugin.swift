import Flutter
import UIKit
import EventKit
import Foundation

extension Date {
      var millisecondsSince1970:Int {
          return Int((self.timeIntervalSince1970 * 1000.0).rounded())
      }

      init(milliseconds:Int!) {
          self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
      }
}

public class SwiftAdd2CalendarPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter.javih.com/add_2_calendar", binaryMessenger: registrar.messenger())
    let instance = SwiftAdd2CalendarPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
            case "add2Cal":
                let args = call.arguments as! [String:Any]
                let title = args["title"] as! String
                let desc = args["desc"] as! String
                addEventToCalendar(title: title, description: desc, startDate: Date(milliseconds: (args["startDate"] as! Int)), endDate: Date(milliseconds: (args["endDate"] as! Int)))
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
    }
  }

  private func addEventToCalendar(title: String!, description: String, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
      let eventStore = EKEventStore()

      eventStore.requestAccess(to: .event, completion: { (granted, error) in
          if (granted) && (error == nil) {
              let event = EKEvent(eventStore: eventStore)
              event.title = title!
              event.startDate = startDate
              event.endDate = endDate
              event.notes = description
              event.calendar = eventStore.defaultCalendarForNewEvents
              do {
                  try eventStore.save(event, span: .thisEvent)
              } catch let e as NSError {
                  completion?(false, e)
                  return
              }
              completion?(true, nil)
          } else {
              completion?(false, error as NSError?)
          }
      })
}
