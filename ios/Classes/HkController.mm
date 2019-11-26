//
//  HkController.m
//  flutter_hk
//
//  Created by 金海星 on 2019/11/20.
//

#import "HkController.h"
#import "FlutterHkPlugin.h"
#import "hcnetsdk.h"

@implementation HkController{
    NSString *_name;
    FlutterMethodChannel *channel;
    int m_iLogID, m_iStartChan, m_iChanNum;
    NSMutableDictionary *maps;
}
- (instancetype)initWithName:(NSString *)name{
    if(self = [super init]){
        m_iLogID = -1;
        maps = [NSMutableDictionary dictionary];
        _name = name;
        channel = [FlutterMethodChannel methodChannelWithName:[@"flutter_hk/controller_" stringByAppendingString:name ] binaryMessenger:[FlutterHkPlugin registrar].messenger];
        [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            NSLog(@"controller_%@:%@", _name, call.method);
            @try{
                if([@"login" isEqualToString:call.method]){
                    NSDictionary *params = [call arguments];
                    int port = [params[@"port"]intValue];
                    NSString *ip = params[@"ip"];
                    NSString *user = params[@"user"];
                    NSString *psd = params[@"psd"];
                    int uid = [self login:ip port:port user:user  psd:psd];
                    result(@(uid));
                }else if([@"logout" isEqualToString:call.method]){
                    [self logout];
                    result(@YES);
                }else if([@"getChans" isEqualToString:call.method]){
                    result([self getChans]);
                }else{
                    result(FlutterMethodNotImplemented);
                }
            }
            @catch(NSException *e){
                result([FlutterError errorWithCode:@"hkcontroller" message:@"error" details:e.reason]);
            }
        }];
    }
    return self;
}

//- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
//    if([@"login" isEqualToString:call.method]){
//        NSDictionary *params = [call arguments];
//        int port = [params[@"iUserID"]intValue];
//        NSString ip = params[@"ip"];
//        NSString user = params[@"user"];
//        NSString psd = params[@"psd"];
//        int uid = [self login:ip,port,user, psd];
//        result(uid);
//    }else if([@"logout" isEqualToString:call.method]){
//        [self logout];
//        result(@YES);
//    }else if([@"getChans" isEqualToString:call.method]){
//        result([self getChans]);
//    }else{
//        result(FlutterMethodNotImplemented);
//    }
//}

-(int)login:(NSString *)ip port:(int)port user:(NSString *)user psd:(NSString *)psd{
    NSLog(@"Logining:%@:%d:%@:%@", ip, port, user, psd);
    NET_DVR_DEVICEINFO_V30 dinfo = {0};
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    m_iLogID = NET_DVR_Login_V30((char*)[ip UTF8String], port, (char*)[user cStringUsingEncoding:enc], (char*)[psd UTF8String], &dinfo);
    if(m_iLogID < 0){
        NSLog(@"login failed with[%d]", NET_DVR_GetLastError());
        @throw [[NSException alloc]
                    initWithName:@"err" reason:[NSString stringWithFormat:@"login failed with[%i]", NET_DVR_GetLastError()] userInfo:nil];
    }
    if(dinfo.byChanNum > 0){
        m_iStartChan = dinfo.byStartChan;
        m_iChanNum = dinfo.byChanNum;
    }else if(dinfo.byIPChanNum > 0){
        m_iStartChan = dinfo.byStartDChan;
        m_iChanNum = dinfo.byIPChanNum + dinfo.byHighDChanNum*256;
    }
    NSLog(@"Login success:%i,%i,%i,%i", dinfo.byChanNum,dinfo.byIPChanNum,m_iStartChan,m_iChanNum);
    return m_iLogID;
}

-(Boolean)logout{
    if(m_iLogID >= 0&& !NET_DVR_Logout_V30(m_iLogID)){
        return false;
    }
    m_iLogID = -1;
    return true;
}

-(NSDictionary *)getChans{
    NSLog(@"getChans begin");
    NSMutableDictionary *maps = [NSMutableDictionary dictionary];
    NET_DVR_PICCFG_V30 picc = NET_DVR_PICCFG_V30();
    DWORD dwRet = 0;
    for (int i = m_iStartChan; i<m_iStartChan+ m_iChanNum; i++) {
        if(NET_DVR_GetDVRConfig(m_iLogID, NET_DVR_GET_PICCFG_V30, i, &picc, sizeof(picc), &dwRet)){
            NSData *ndata = [[NSData alloc] initWithBytes:picc.sChanName length:sizeof(picc.sChanName)];
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *aname = [[NSString alloc] initWithData:ndata encoding:enc];
            [maps setObject:aname forKey:@(i)];
        }
    }
    NSLog(@"getChans success");
    return maps;
}

@end
