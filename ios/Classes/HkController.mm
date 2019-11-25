//
//  HkController.m
//  flutter_hk
//
//  Created by 金海星 on 2019/11/20.
//

#import "HkController.h"
#import "FlutterHkPlugin.h"
//#import "hcnetsdk.h"

@implementation HkController{
    NSString *_name;
    FlutterMethodChannel *channel;
    int m_iLogID, m_iStartChan, m_iChanNum;
}
- (instancetype)initWithName:(NSString *)name{
    if(self = [super init]){
        m_iLogID = -1;
        _name = name;
        channel = [FlutterMethodChannel methodChannelWithName:[@"flutter_hk/controller_" stringByAppendingString:name ] binaryMessenger:[FlutterHkPlugin registrar].messenger];
        [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            NSLog(@"controller_%@:%@", _name, call.method);
            if([@"login" isEqualToString:call.method]){
                NSDictionary *params = [call arguments];
                int port = [params[@"iUserID"]intValue];
                NSString *ip = params[@"ip"];
                NSString *user = params[@"user"];
                NSString *psd = params[@"psd"];
//                int uid = [self login:ip,port,user, psd];
                result(0);
            }else if([@"logout" isEqualToString:call.method]){
                [self logout];
                result(@YES);
            }else if([@"getChans" isEqualToString:call.method]){
                result([self getChans]);
            }else{
                result(FlutterMethodNotImplemented);
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

-(int)login{
//    NET_DVR_DEVICEINFO_V30 dinfo = [NET_DVR_DEVICEINFO_V30 new];
//    m_iLogID = NET_DVR_Login_V30(ip, port, user, dinfo);
//    if(m_iLogID < 0){
//
//    }
//    if(dinfo.byChanNum > 0){
//        m_iStartChan = dinfo.byStartChan;
//        m_iChanNum = dinfo.byChanNum;
//    }else if(dinfo.byIPChanNum > 0){
//        m_iStartChan = dinfo.byStartDChan;
//        m_iChanNum = dinfo.byIPChanNum + dinfo.byHighDChanNum*256;
//    }
//    return m_iLogID;
    return 0;
}

-(Boolean)logout{
//    if(m_iLogID >= 0&& !NET_DVR_Logout_V30(m_iLogID)){
//        return false;
//    }
//    m_iLogID = -1;
    return true;
}

-(NSDictionary *)getChans{
    NSMutableDictionary *maps = [NSMutableDictionary dictionary];
//    NET_DVR_PICCFG_V30 picc = [NET_DVR_PICCFG_V30 new];
//    for (int i = m_iStartChan; i<m_iStartChan+ m_iChanNum; i++) {
//        NET_DVR_GetDVRConfig(m_iLogID, NET_DVR_GET_PICCFG_V30, i, picc);
//        [maps setValue:picc.sChanName forKey:i];
//    }
    return maps;
}

@end
