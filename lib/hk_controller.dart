import 'package:flutter/services.dart';

class HkController {
  static const MethodChannel _ctrl_channel =
      const MethodChannel('flutter_hk/controller');
  int iUserId = -1;
  final String name;
  MethodChannel _channel = null;
  bool isInit = false;

  HkController(this.name);

  Future init() async {
    if (!isInit) {
      await _ctrl_channel.invokeMapMethod("createController", {
        "name": name,
      });
      _channel = MethodChannel('flutter_hk/controller_$name');
      isInit = true;
    }
  }

  static Future<String> get platformVersion async {
    final String version =
        await _ctrl_channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<int> login(String ip, int port, String user, String psd) async {
    var result = await _channel.invokeMapMethod("login", {
      "ip": ip,
      "port": port,
      "user": user,
      "psd": psd,
    });
    iUserId = result[0];
    return iUserId;
  }

  Future getChans() async {
    var result = await _channel.invokeMapMethod("getChans");
    return result;
  }

  Future logout() async {
    iUserId = -1;
    await _channel.invokeMapMethod("logout");
  }

  void dispose() {
    _ctrl_channel.invokeMapMethod("dispose", {
      "name": name,
    });
  }
}
