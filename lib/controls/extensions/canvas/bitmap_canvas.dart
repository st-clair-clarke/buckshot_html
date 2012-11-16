// Copyright (c) 2012, the Buckshot project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// Apache-style license that can be found in the LICENSE file.

library webglcanvas_canvas_controls_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
import 'package:buckshot_html/controls/extensions/canvas/canvas_base.dart';

/**
 * A 2D Canvas to draw to.
 */
class BitmapCanvas extends CanvasBase
{
  CanvasRenderingContext2D _context;

  CanvasRenderingContext2D get context => _context;

  BitmapCanvas();
  BitmapCanvas.register() : super.register();
  makeMe() => new BitmapCanvas();

  @override void onLoaded() {
    super.onLoaded();
    CanvasElement canvas = rawElement as CanvasElement;
    _context = canvas.getContext('2d');
  }

  @override void onUnloaded() {
    super.onUnloaded();
    _context = null;
  }
}
