package jinhx.cn.flutter_hk;

import android.util.Log;

import com.hikvision.netsdk.ExceptionCallBack;
import com.hikvision.netsdk.HCNetSDK;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterHkPlugin */
public class FlutterHkPlugin implements MethodCallHandler {
  static BinaryMessenger messenger;
  Map<String, HkController> _channels = new HashMap<>();
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    messenger = registrar.messenger();
    final MethodChannel channel = new MethodChannel(messenger, "flutter_hk/controller");
    channel.setMethodCallHandler(new FlutterHkPlugin());

    registrar.platformViewRegistry().registerViewFactory("flutter_hk/player", new PlaySurfaceViewFactory(messenger));

    HCNetSDK.getInstance().NET_DVR_Init();
  }

  @Override
  protected void finalize(){
    Log.e("FlutterHkPlugin", "-FlutterHkPlugin finalize");
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {

    Map<Object,Object> ret = new HashMap<>();
    Log.e("Controller", call.method);
    switch (call.method){
      case "getPlatformVersion":
        Log.e("FP", String.valueOf(_channels.size()));
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "createController":
        String name = call.argument("name");
        if(!_channels.containsKey(name)) {
          _channels.put(name, new HkController(name, this.messenger));
        }
        ret.put(0, name);
        result.success(ret);
        break;
      case "dispose":
        name = call.argument("name");
        _channels.remove(name);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }
}
