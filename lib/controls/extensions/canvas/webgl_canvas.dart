// Copyright (c) 2012, the Buckshot project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// Apache-style license that can be found in the LICENSE file.

library webglcanvas_canvas_controls_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
import 'package:dartnet_event_model/events.dart';
import 'package:buckshot_html/controls/extensions/canvas/canvas_base.dart';

/**
 * A 3D canvas to draw to.
 */
class WebGLCanvas extends CanvasBase
{
  WebGLRenderingContext _context;

  WebGLRenderingContext get context => _context;

  WebGLCanvas();
  WebGLCanvas.register() : super.register();
  makeMe() => new WebGLCanvas();

  @override void onLoaded() {
    super.onLoaded();
    CanvasElement canvas = rawElement as CanvasElement;
    _context = canvas.getContext('experimental-webgl');
  }

  @override void onUnloaded() {
    super.onUnloaded();
    _context = null;
  }
}
