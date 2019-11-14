import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'hk_player_controller.dart';

class HkPlayer extends StatefulWidget {
//  final int defaultHeight;
//  final int defaultWidth;
//  final String url = "";
  int chan = -1;
  HkPlayerController controller;
  HkPlayer({
    Key key,
    @required this.chan,
    @required this.controller,
  });

  @override
  HkPlayerState createState() => HkPlayerState();
}

class HkPlayerState extends State<HkPlayer> {
  HkPlayerController _controller;
  bool readyToShow = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: _createPlatformView(),
      ),
      onDoubleTap: () {
        if (this._controller.isPlaying)
          this._controller.stop();
        else
          this._controller.replay();
      },
    );
  }

  Widget _createPlatformView() {
    if (Platform.isIOS) {
      return UiKitView(
          viewType: "flutter_hk/player",
          onPlatformViewCreated: _onPlatformViewCreated);
    } else if (Platform.isAndroid) {
      return AndroidView(
          viewType: "flutter_hk/player",
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
          onPlatformViewCreated: _onPlatformViewCreated);
    }
    return Container();
  }

  void _onPlatformViewCreated(int id) async {
    _controller = widget.controller;
    _controller.initView(id);
    setState(() {
      readyToShow = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
