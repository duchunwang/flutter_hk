#import "FlutterHkPlugin.h"
#import "HkController.h"
#import "PlaySurfaceViewFactory.h"
#import "hcnetsdk.h"

static NSObject<FlutterPluginRegistrar>* _registrar;
static BOOL _isInit;

@implementation FlutterHkPlugin{
    NSMutableDictionary *channels;
}

- (FlutterHkPlugin*)init{
    if(self = [super init]){
        channels = [NSMutableDictionary dictionary];
    }
    return self;
}
+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    _registrar = registrar;
    
    // 设置控制 channel
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flutter_hk/controller" binaryMessenger:[registrar messenger]];
    FlutterHkPlugin* instance = [FlutterHkPlugin new];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    [registrar registerViewFactory:[[PlaySurfaceViewFactory alloc]init] withId:@"flutter_hk/player"];
    
//    NSLog(@"add: %d", add(1, 2));
     _isInit = NO;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSLog(@"controller:%@", call.method);
    if([@"getPlatformVersion" isEqualToString:call.method]){
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else if([@"createController" isEqualToString:call.method]){
        if(_isInit == NO){
            BOOL bRet = NET_DVR_Init();
            if (!bRet)
            {
                NSLog(@"NET_DVR_Init failed");
                result(@NO);
            }
            NSLog(@"NET_DVR_Init ok!");
            _isInit = YES;
        }
        NSDictionary *params = [call arguments];
        NSString *name = params[@"name"];
        NSObject *value = [channels objectForKey:name];
        if(value == nil){
            HkController *ctl = [[HkController alloc]initWithName:name];
            [channels setObject:ctl forKey:name];
        }
        result(@YES);
    }else if ([@"dispose" isEqualToString:call.method]){
        NSDictionary *params = [call arguments];
        NSString *name = params[@"name"];
        [channels removeObjectForKey:name];
        result(@YES);
    }else{
        result(FlutterMethodNotImplemented);
    }
}

+(NSObject<FlutterPluginRegistrar> *)registrar{
    return _registrar;
}

@end
