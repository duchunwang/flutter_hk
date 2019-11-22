//
//  PlaySurfaceView.m
//  flutter_hk
//
//  Created by 金海星 on 2019/11/20.
//

#import "PlaySurfaceView.h"
#import "FlutterHkPlugin.h"
//#import "hcnetsdk.h"

@implementation PlaySurfaceView{
    FlutterMethodChannel *channel;
    Boolean isPlaying;
    int m_iPreviewHandle;
    int64_t _viewId;
    CGRect _frame;
    UIView *playView;
}

-(instancetype)initWithFrame:(CGRect)frame
              viewIdentifier:(int64_t)viewId{
    if(self == [super init]){
        _frame = frame;
        _viewId = viewId;
        
        playView = [[UIView alloc]initWithFrame:frame];
        playView.contentMode = UIViewContentModeScaleAspectFit;
        playView.backgroundColor = [UIColor blackColor];
        playView.clipsToBounds = YES;
        playView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        channel = [FlutterMethodChannel methodChannelWithName:[NSString stringWithFormat:@"flutter_hk/player_%11d", viewId] binaryMessenger:[FlutterHkPlugin registrar].messenger];
        [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            NSLog(@"player:%@", call.method);
                if([@"play" isEqualToString:call.method]){
                    NSDictionary *params = [call arguments];
                    int iUserId = [params[@"iUserID"]intValue];
                    int ichan = [params[@"iChan"]intValue];
            //        self.startPreview(iUserId, ichan);
                    result(@YES);
                }else if([@"stop" isEqualToString:call.method]){
                    [self stopPreview];
                    result(@YES);
                }else{
                    result(FlutterMethodNotImplemented);
                }
        }];
    }
    
    return self;
}

-(nonnull UIView *)view{
    return playView;
}

-(void)dispose{
    [self stopPreview];
}

-(void)startPreview{
    NSLog(@"startPreview");
//    NET_DVR_PREVIEWINFO previewInfo = {0};
//    previewInfo.lChannel = 0;
//    previewInfo.dwStreamType = 1;
//    previewInfo.bBlocked = 1;
//    previewInfo.hPlayWnd = [self getHolder];
//
//    m_iPreviewHandle = NET_DVR_RealPlay_V40(iUserID, &previewInfo, nil, nil);
//    if(m_iPreviewHandle < 0){
//        //
//    }
    isPlaying = true;
}

-(void)stopPreview{
    NSLog(@"stopPreview");
//    NET_DEV_StopRealPlay(m_iPreviewHandle);
    isPlaying = false;
}

//-(void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
//    NSLog(@"player:%@", call.method);
//    if([@"play" isEqualToString:call.method]){
//        NSDictionary *params = [call arguments];
//        int iUserId = [params[@"iUserID"]intValue];
//        int ichan = [params[@"iChan"]intValue];
////        self.startPreview(iUserId, ichan);
//        result(@YES);
//    }else if([@"stop" isEqualToString:call.method]){
//        [self stopPreview];
//        result(@YES);
//    }else{
//        result(FlutterMethodNotImplemented);
//    }
//}

@end
