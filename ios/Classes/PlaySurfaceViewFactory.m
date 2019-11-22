#import "PlaySurfaceViewFactory.h"
#import "PlaySurfaceView.h"

@implementation PlaySurfaceViewFactory

-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

-(NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args{
    PlaySurfaceView *view = [[PlaySurfaceView alloc] initWithFrame:frame
                                                    viewIdentifier:viewId];
    return view;
}

@end
