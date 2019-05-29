import Flutter
import UIKit
import EventKit
import Foundation

extension Date {
      init(milliseconds:Double) {
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
    if call.method == "add2Cal" {
        let args = call.arguments as! [String:Any]
        let title = args["title"] as! String
        let desc = args["desc"] as! String
        let location = args["location"] as! String
        
        addEventToCalendar(title: title, description: desc, location: location, startDate: Date(milliseconds: (args["startDate"] as! Double)), endDate: Date(milliseconds: (args["endDate"] as! Double)), allDay: args["allDay"] as! Bool, completion: { (success) -> Void in
            if success {
                result(true)
            } else {
                result(false)
            }
        })
    }
  }

    private func addEventToCalendar(title: String!, description: String, location: String, startDate: Date, endDate: Date, allDay: Bool, completion: ((_ success: Bool) -> Void)? = nil) {
          let eventStore = EKEventStore()

          eventStore.requestAccess(to: .event, completion: { (granted, error) in
              if (granted) && (error == nil) {
                  let event = EKEvent(eventStore: eventStore)
                  event.title = title
                  event.startDate = startDate
                  event.endDate = endDate
                  event.location = location
                  event.notes = description
                  event.isAllDay = allDay
                  event.calendar = eventStore.defaultCalendarForNewEvents
                  do {
                      try eventStore.save(event, span: .thisEvent)
                  } catch let e as NSError? {
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
