//
//  PlaySurfaceView.h
//  flutter_hk
//
//  Created by 金海星 on 2019/11/20.
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

@interface PlaySurfaceView:NSObject<FlutterPlatformView>
-(instancetype)initWithFrame:(CGRect)frame
              viewIdentifier:(int64_t)viewId;
@end
