# flutter_hk

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## 平台
Android, IOS

## 说明flutter_hk插件基于海康的原生SDK的二次封装，支持多路硬盘录像机的登录和多个视频窗口的播放。

## 依赖
在pubspec.yaml里加入
```
dependencies:
  flutter_hk: ^0.1.0
```

## 安装
你可以用下面的命令安装组件
```
$  flutter pub get
```

## 引用
在代码里
```
import 'package:flutter_hk/hk_controller.dart';
import 'package:flutter_hk/hk_player.dart';
import 'package:flutter_hk/hk_player_controller.dart';
```

