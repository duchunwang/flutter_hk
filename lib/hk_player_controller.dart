import 'dart:io';

import 'package:flutter/services.dart';

import 'hk_controller.dart';

class HkPlayerController {
  MethodChannel _channel;
  bool hasClients = false;
  HkController hkController;
  int iChan = -1;
  bool isPlaying = false;

  HkPlayerController(this.hkController);

  initView(int id) {
    _channel = MethodChannel("flutter_hk/player_$id");
    hasClients = true;
  }

  Future play(int iChan) async {
    this.iChan = iChan;
    if (hkController.iUserId < 0) {
      Future.error("请先登录");
      return;
    }
    var result = await _channel.invokeMapMethod(
        "play", {"iUserID": this.hkController.iUserId, "iChan": iChan});
    print("playend");
    isPlaying = true;
  }

  Future replay() {
    if (this.iChan != -1) {
      play(this.iChan);
    }
  }

  Future stop() async {
    var result = await _channel.invokeMapMethod("stop");
    isPlaying = false;
    return result;
  }

  void dispose() {
    if (Platform.isIOS) {
//      _channel.invokeMethod("dispose");
    }
  }
}
