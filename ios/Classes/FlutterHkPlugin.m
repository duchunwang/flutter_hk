#import "FlutterHkPlugin.h"
#import <flutter_hk/flutter_hk-Swift.h>

@implementation FlutterHkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterHkPlugin registerWithRegistrar:registrar];
}
@end
