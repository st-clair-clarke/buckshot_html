// Copyright (c) 2012, the Buckshot project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// Apache-style license that can be found in the LICENSE file.

library canvas_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
 * Event for when a frame changes.
 */
class FrameEventArgs extends EventArgs
{
  /// The current time of the frame
  int currentTime;

  FrameEventArgs(int this.currentTime);
}

/**
 * Base class for canvas drawing.
 */
class CanvasBase extends Control
{
  /// Next canvas identifier to hand out
  static int _nextCanvasId = 0;
  /**
   * Identifier for the canvas.
   *
   * Used to identify the [RequestAnimationFrameCallback]
   * within FrameworkAnimation.
   */
  int _canvasId;

  /// The width of the canvas surface
  FrameworkProperty<num> surfaceWidth;
  /// The height of the canvas surface
  FrameworkProperty<num> surfaceHeight;

  /// An event triggered on a change of frame
  FrameworkEvent<FrameEventArgs> frame;

  CanvasBase() {
    _canvasId = _nextCanvasId++;
  }
  CanvasBase.register() : super.register();

  @override void createPrimitive() {
    rawElement = new CanvasElement();
  }

  void onLoaded() {
    super.onLoaded();

    htmlPlatform.workers[_name] = _frameHandler;
  }

  void onUnloaded() {
    super.onUnloaded();

    htmlPlatform.workers.remove(_name);
  }

  String get _name => '__canvas_${_canvasId}__';

  @override void initProperties() {
    super.initProperties();

    surfaceWidth = new FrameworkProperty(this, 'surfaceWidth',
      propertyChangedCallback: (num v){
        rawElement.attributes['width'] = '$v';
      },
      defaultValue: 640,
      converter:const StringToNumericConverter());

    surfaceHeight = new FrameworkProperty(this, 'surfaceHeight',
      propertyChangedCallback: (num v){
        rawElement.attributes['height'] = '$v';
      },
      defaultValue: 480,
      converter:const StringToNumericConverter());
  }

  @override void initEvents() {
    super.initEvents();
    registerEvent('frame', frame);
    frame = new FrameworkEvent<FrameEventArgs>();
  }

  _frameHandler(e) {
    if (!frame.hasHandlers) return;

    frame.invoke(this, new FrameEventArgs(e));
    return;
  }
}
