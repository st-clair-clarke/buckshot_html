part of buckshot_html_browser;

abstract class HtmlPlatformElement implements BoxModelElement
{
  Element rawElement;

  @override String get namespace => 'http://buckshotui.org/platforms/html';

  static final Expando<RectMeasurement> _previousPosition =
      new Expando<RectMeasurement>();
  static final Expando<RectMeasurement> _previousMeasurement =
      new Expando<RectMeasurement>();

  static void _startWatchMeasurement(HtmlPlatformElement element){
    void watchIt(num _){
      htmlPlatform.measure(element).then((RectMeasurement m){
        if (_previousMeasurement[element] == null){
          element.measurementChanged.invoke(element,
            new MeasurementChangedEventArgs(m, m));
        }else{
          if (_previousMeasurement[element].width != m.width ||
                _previousMeasurement[element].height != m.height){
            element.measurementChanged.invoke(element,
              new MeasurementChangedEventArgs(_previousMeasurement[element], m));
          }
        }
        _previousMeasurement[element] = m;
      });
    }
    htmlPlatform.workers['${element.safeName}_watch_measurement'] = watchIt;
  }

  static void _stopWatchMeasurement(HtmlPlatformElement element){
    if (htmlPlatform.workers.containsKey('${element.safeName}_watch_measurement')){
      htmlPlatform.workers.remove('${element.safeName}_watch_measurement');
    }

    _previousMeasurement[element] = null;
  }

  static void _startWatchPosition(HtmlPlatformElement element){
    void watchIt(num _){
      htmlPlatform.measure(element).then((RectMeasurement m){
        if (_previousPosition[element] == null){
          element.positionChanged.invoke(element,
            new MeasurementChangedEventArgs(m, m));
        }else{
          if (_previousPosition[element].left != m.left ||
              _previousPosition[element].top != m.top){
            element.positionChanged.invoke(element,
              new MeasurementChangedEventArgs(_previousPosition[element], m));
          }
        }
        _previousPosition[element] = m;
      });
    }
    htmlPlatform.workers['${element.safeName}_watch_position'] = watchIt;
  }

  static void _stopWatchPosition(HtmlPlatformElement element){
    if (htmlPlatform.workers.containsKey('${element.safeName}_watch_position')){
      htmlPlatform.workers.remove('${element.safeName}_watch_position');
    }

    _previousPosition[element] = null;
  }

  /**
   * Sets event handlers for base HtmlPlatformElement events.
   */
  static void initializeBaseEvents(HtmlPlatformElement element){
    element.measurementChanged = new BuckshotEvent.watchFirstAndLast(
      () => _startWatchMeasurement(element),
      () =>  _stopWatchMeasurement(element)
    );

    element.positionChanged = new BuckshotEvent.watchFirstAndLast(
      () => _startWatchPosition(element),
      () =>  _stopWatchPosition(element)
    );

    void mouseUpHandler(e){
      if (!element.mouseUp.hasHandlers) return;
      e.stopPropagation();

      localMouseCoordinate(element, e.pageX, e.pageY)
      .then((p){
        element
          .mouseUp
          .invoke(element, new MouseEventArgs(p.x, p.y, e.pageX, e.pageY));
      });
    }

    element.mouseUp = new BuckshotEvent<MouseEventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.mouseUp.add(mouseUpHandler),
      () => element.rawElement.on.mouseUp.remove(mouseUpHandler)
    );

    void mouseDownHandler(e){
      element.rawElement.focus();
      if (!element.mouseDown.hasHandlers) return;

      e.stopPropagation();

      localMouseCoordinate(element, e.pageX, e.pageY)
      .then((p){
        element
          .mouseDown
          .invoke(element, new MouseEventArgs(p.x, p.y, e.pageX, e.pageY));
      });
    }

    element.mouseDown = new BuckshotEvent<MouseEventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.mouseDown.add(mouseDownHandler),
      () => element.rawElement.on.mouseDown.remove(mouseDownHandler)
    );


    void mouseMoveHandler(e){
      if (!element.mouseMove.hasHandlers) return;
      e.stopPropagation();

      localMouseCoordinate(element, e.pageX, e.pageY)
      .then((p){
        element
          .mouseMove
          .invoke(element, new MouseEventArgs(p.x, p.y, e.pageX, e.pageY));
      });
    }

    element.mouseMove = new BuckshotEvent<MouseEventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.mouseMove.add(mouseMoveHandler),
      () => element.rawElement.on.mouseMove.remove(mouseMoveHandler)
    );

    void clickHandler(e){
      element.rawElement.focus();

      if (!element.click.hasHandlers) return;

      e.stopPropagation();

      localMouseCoordinate(element, e.pageX, e.pageY)
      .then((p){
        element
          .click
          .invoke(element, new MouseEventArgs(p.x, p.y, e.pageX, e.pageY));
      });
    }

    element.click = new BuckshotEvent<MouseEventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.click.add(clickHandler),
      () => element.rawElement.on.click.remove(clickHandler)
    );


    void gotFocusHandler(e){
      if (!element.gotFocus.hasHandlers) return;

      e.stopPropagation();

      element.gotFocus.invoke(element, new EventArgs());
    }

    element.gotFocus = new BuckshotEvent<EventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.focus.add(gotFocusHandler),
      () => element.rawElement.on.focus.remove(gotFocusHandler)
    );

    void lostFocusHandler(e){
      if (!element.lostFocus.hasHandlers) return;

      e.stopPropagation();

      element.lostFocus.invoke(element, new EventArgs());
    }

    element.lostFocus = new BuckshotEvent<EventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.blur.add(lostFocusHandler),
      () => element.rawElement.on.blur.remove(lostFocusHandler)
    );

    bool isMouseReallyOut = true;

    void mouseEnterHandler(e){
      if (!element.mouseEnter.hasHandlers) return;

      e.stopPropagation();

     if (isMouseReallyOut && element.mouseLeave.hasHandlers){
       isMouseReallyOut = false;
       element.mouseEnter.invoke(element, new EventArgs());
     }else if(!element.mouseLeave.hasHandlers){
       //TODO add a temp handler for mouse out so the
       //logic works correctly when only the mouseenter
       //event is subscribed to (corner case).
       element.mouseEnter.invoke(element, new EventArgs());
     }
    }

    element.mouseEnter = new BuckshotEvent<EventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.mouseOver.add(mouseEnterHandler),
      () => element.rawElement.on.mouseOver.remove(mouseEnterHandler)
    );

    void mouseLeaveHandler(e){
      if (!element.mouseLeave.hasHandlers) return;

      e.stopPropagation();

      htmlPlatform
        .measure(element)
        .then((RectMeasurement r){
          localMouseCoordinate(element, e.pageX, e.pageY)
            .then((p){
              if (p.x > -1 && p.y > -1 && p.x < r.width
                  && p.y < r.height){
                isMouseReallyOut = false;
                return;
              }

              isMouseReallyOut = true;
              element.mouseLeave.invoke(element, new EventArgs());
          });
      });
    }

    element.mouseLeave = new BuckshotEvent<EventArgs>
    .watchFirstAndLast(
      () => element.rawElement.on.mouseOut.add(mouseLeaveHandler),
      () => element.rawElement.on.mouseOut.remove(mouseLeaveHandler)
    );
  }

  /**
   * Helper function which updates the alignment of a single child element
   * within a given [element].
   */
  static void updateChildAlignment(FrameworkContainer element){
    assert(element != null);
    assert(element is HtmlPlatformElement);
    assert(element.containerContent is HtmlPlatformElement);

    final rawChild = element.containerContent.rawElement;

    // Resets horizontal alignment settings and restores minWidth value.
    void resetHorizontalSettings(){
      rawChild.style.setProperty('-webkit-flex', 'none');
      rawChild.style.minWidth =
          element.containerContent.minWidth.value == null
            ? ''
            : '${element.containerContent.minWidth.value}px';
    }


    if (element.containerContent.hAlign.value != null){
      switch(element.containerContent.hAlign.value){
        case HorizontalAlignment.left:
          element.rawElement.style.setProperty('-webkit-justify-content',
              'flex-start');
          resetHorizontalSettings();
          break;
        case HorizontalAlignment.right:
          element.rawElement.style.setProperty('-webkit-justify-content',
              'flex-end');
          rawChild.style.setProperty('-webkit-flex', 'none');
          resetHorizontalSettings();
          break;
        case HorizontalAlignment.center:
          element.rawElement.style.setProperty('-webkit-justify-content',
              'center');
          rawChild.style.setProperty('-webkit-flex', 'none');
          resetHorizontalSettings();
          break;
        case HorizontalAlignment.stretch:
          element.rawElement.style.setProperty('-webkit-justify-content',
              'flex-start');
          // this setting prevents the flex box from overflowing if it's child
          // content is bigger than it's parent.
          // Flexbox spec 7.2
          rawChild.style.minWidth = '0px';
          rawChild.style.setProperty('-webkit-flex', '1 1 auto');
          break;
      }
    }

    if (element.containerContent.vAlign.value == null) return;
    switch(element.containerContent.vAlign.value){
      case VerticalAlignment.top:
        element.rawElement.style.setProperty('-webkit-align-items',
            'flex-start');
        break;
      case VerticalAlignment.bottom:
        element.rawElement.style.setProperty('-webkit-align-items', 'flex-end');
        break;
      case VerticalAlignment.center:
        element.rawElement.style.setProperty('-webkit-align-items', 'center');
        break;
      case VerticalAlignment.stretch:
        element.rawElement.style.setProperty('-webkit-align-items', 'stretch');
        break;
    }
  }

  /**
   * Helper which sets the css background property of an [element] to the
   * given [brush].
   */
  static void setBackgroundBrush(HtmlPlatformElement element, Brush brush){
    final rawElement = element.rawElement;

    if (brush is SolidColorBrush){
      rawElement.style.background =
          '${brush.color.value.toColorString()}';
    }else if (brush is LinearGradientBrush){
      rawElement.style.background =
          brush.fallbackColor.value.toColorString();

      final colorString = new StringBuffer();

      //create the string of stop colors
      brush.stops.value.forEach((GradientStop stop){
        colorString.add(stop.color.value.toColorString());

        if (stop.percent.value != -1) {
          colorString.add(" ${stop.percent.value}%");
        }

        if (stop != brush.stops.value.last) {
          colorString.add(", ");
        }
      });

      //set the background for all browser types
      rawElement.style.background =
          "-webkit-linear-gradient(${brush.direction.value}, ${colorString})";
          rawElement.style.background =
              "-moz-linear-gradient(${brush.direction.value}, ${colorString})";
              rawElement.style.background =
                  "-ms-linear-gradient(${brush.direction.value}, ${colorString})";
                  rawElement.style.background =
                      "-o-linear-gradient(${brush.direction.value}, ${colorString})";
                      rawElement.style.background =
                          "linear-gradient(${brush.direction.value}, ${colorString})";
    }else if (brush is RadialGradientBrush){
      //set the fallback
      rawElement.style.background = brush.fallbackColor.value.toColorString();

      final colorString = new StringBuffer();

      //create the string of stop colors
      brush.stops.value.forEach((GradientStop stop){
        colorString.add(stop.color.value.toColorString());

        if (stop.percent.value != -1) {
          colorString.add(" ${stop.percent.value}%");
        }

        if (stop != brush.stops.value.last) {
          colorString.add(", ");
        }
      });

      //set the background for all browser types
      rawElement.style.background =
          "-webkit-radial-gradient(50% 50%, ${brush.drawMode.value}, ${colorString})";
          rawElement.style.background =
              "-moz-radial-gradient(50% 50%, ${brush.drawMode.value}, ${colorString})";
              rawElement.style.background =
                  "-ms-radial-gradient(50% 50%, ${brush.drawMode.value}, ${colorString})";
                  rawElement.style.background =
                      "-o-radial-gradient(50% 50%, ${brush.drawMode.value}, ${colorString})";
                      rawElement.style.background =
                          "radial-gradient(50% 50%, ${brush.drawMode.value}, ${colorString})";
    }else{
      new Logger('buckshot.pal.html.HtmlPlatformElement')
        ..warning('Unrecognized brush "$brush" assignment. Default to White.');
      rawElement.style.background = '${Colors.White}';
    }
  }

  /**
   * Returns a future containing the mouse coordinates within a give [element]
   * coordinate space.
   */
  static Future<SurfacePoint> localMouseCoordinate(HtmlPlatformElement element,
      num pageX, num pageY){

    final c = new Completer();

    if (Browser.getBrowserInfo().browser != Browser.CHROME){
      htmlPlatform.measure(element).then((RectMeasurement r){
        c.complete(new SurfacePoint(pageX - r.left,
            pageY - r.top));
      });
    }else{
      final wkitPoint =
          window
          .webkitConvertPointFromPageToNode(element.rawElement,
            new Point(pageX, pageY));
      c.complete(new SurfacePoint(wkitPoint.x, wkitPoint.y));
    }

    return c.future;
  }

  /**
   * Helper method which performs a transform on the given element based
   * on current transform values.  Tolerates null values.
   */
  static void doTransform(HtmlPlatformElement e){

    var tx = e.translateX.value;
    var ty = e.translateY.value;
    var tz = e.translateZ.value;
    var sx = e.scaleX.value;
    var sy = e.scaleY.value;
    var sz = e.scaleZ.value;
    var rx = e.rotateX.value;
    var ry = e.rotateY.value;
    var rz = e.rotateZ.value;

    // set to identity if null
    if (tx == null) tx = 0;
    if (ty == null) ty = 0;
    if (tz == null) tz = 0;
    if (sx == null) sx = 1;
    if (sy == null) sy = 1;
    if (sz == null) sz = 1;
    if (rx == null) rx = 0;
    if (ry == null) ry = 0;
    if (rz == null) rz = 0;

    e.rawElement.style.transform =
        '''
        translateX(${tx}px) translateY(${ty}px) translateZ(${tz}px)
        scaleX(${sx}) scaleY(${sy}) scaleZ(${sz})
        rotateX(${rx}deg) rotateY(${ry}deg) rotateZ(${rz}deg)
        ''';
  }

  /**
   * Helper method that updates shadow settings on a given element
   * based on the current shadow property values.  Tolerates null values.
   */
  static void drawShadow(HtmlPlatformElement e){
    var sx = e.shadowX.value;
    var sy = e.shadowY.value;
    var b = e.shadowBlur.value;
    var s = e.shadowSize.value;
    var c = e.shadowColor.value;

    // set nulls
    sx = (sx == null) ? '' : '${sx}px';
    sy = (sy == null) ? '' : '${sy}px';
    b = (b == null) ? '' : '${b}px';
    s = (s == null) ? '' : '${s}px';

    if (c != null){
      c = '${c.toColorString()}';
    }else{
      c = new Color.predefined(Colors.Black).toColorString();
    }
//    if (inset == null) inset = '';
//    if (inset is bool){
//      inset = (inset) ? 'inset' : '';
//    }

    e.rawElement.style.boxShadow = '$sx $sy $b $s $c'.trim();
  }

  /**
   * Helper method that sets the transform origin on a given element based on
   * the current origin value.  Tolerates null values.
   */
  static void setTransformOrigin(HtmlPlatformElement e){
    var tx = e.originX.value;
    var ty = e.originY.value;
    var tz = e.originZ.value;

    if (tx == null) tx = 0;
    if (ty == null) ty = 0;
    if (tz == null) tz = 0;

    e.rawElement.style.transformOrigin = '${tx}px ${ty}px ${tz}px';
  }
}
