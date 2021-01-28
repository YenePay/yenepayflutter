#import "YenepayflutterPlugin.h"
#if __has_include(<yenepayflutter/yenepayflutter-Swift.h>)
#import <yenepayflutter/yenepayflutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "yenepayflutter-Swift.h"
#endif

@implementation YenepayflutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftYenepayflutterPlugin registerWithRegistrar:registrar];
}
@end
