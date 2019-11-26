//
//  PlaySurfaceView.m
//  flutter_hk
//
//  Created by 金海星 on 2019/11/20.
//
#import <Foundation/Foundation.h>
#import "PlaySurfaceView.h"
#import "FlutterHkPlugin.h"
#import "hcnetsdk.h"

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
        
        NSString *chanName = [NSString stringWithFormat:@"flutter_hk/player_%lli", viewId];
        NSLog(@"name:%@:name", chanName);
        channel = [FlutterMethodChannel methodChannelWithName:chanName binaryMessenger:[FlutterHkPlugin registrar].messenger];
        [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            NSLog(@"player:%@", call.method);
            if([@"play" isEqualToString:call.method]){
                NSDictionary *params = [call arguments];
                int iUserId = [params[@"iUserID"]intValue];
                int ichan = [params[@"iChan"]intValue];
                [self startPreview:iUserId iChan:ichan];
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

-(void)startPreview:(int)iUserID iChan:(int)iChan{
    NSLog(@"startPreview");
    NET_DVR_PREVIEWINFO previewInfo = {0};
    previewInfo.lChannel = iChan;
    previewInfo.dwStreamType = 1;
    previewInfo.bBlocked = 1;
    previewInfo.hPlayWnd = (__bridge HWND)playView;

    m_iPreviewHandle = NET_DVR_RealPlay_V40(iUserID, &previewInfo, nil, nil);
    if(m_iPreviewHandle < 0){
        NSLog(@"NET_DVR_RealPlay_V40 is failed!Err:[@i]", NET_DVR_GetLastError());
        return;
    }
    isPlaying = true;
    NSLog(@"NET_DVR_RealPlay_V40 is success");
}

-(void)stopPreview{
    NSLog(@"stopPreview");
    NET_DVR_StopRealPlay(m_iPreviewHandle);
    isPlaying = false;
}

@end
