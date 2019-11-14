package jinhx.cn.flutter_hk;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class PlaySurfaceViewFactory extends PlatformViewFactory {
    BinaryMessenger messenger;

    public PlaySurfaceViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }
    @Override
    public PlatformView create(Context context, int i, Object o) {
        return new PlaySurfaceView(context, messenger, i);
    }
}
