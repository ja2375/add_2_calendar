#import "Add2CalendarPlugin.h"
#import <add_2_calendar-Swift.h>

@implementation Add2CalendarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAdd2CalendarPlugin registerWithRegistrar:registrar];
}
@end
