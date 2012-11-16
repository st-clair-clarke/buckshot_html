library layoutcanvas_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* Implements a layout container where elements can be arranged explicitly in
* left/top position within the container area.
*
* Element overlapping, and z-ordering is supported.
*
* This class is **not** related to the HTML5 <Canvas> element. */
class LayoutCanvas extends Control implements FrameworkContainer
{
  /// Represents the offset position of an element within the LayoutCanvas
  /// from the top of the LayoutCanvas container boundary.
  static AttachedFrameworkProperty topProperty;
  /// Represents the offset position of an element within the LayoutCanvas
  /// from the left of the LayoutCanvas container boundary.
  static AttachedFrameworkProperty leftProperty;

  FrameworkProperty<Brush> background;

  final ObservableList<HtmlPlatformElement> children =
      new ObservableList<HtmlPlatformElement>();

  EventHandlerReference _ref;

  LayoutCanvas(){
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = children;
  }
  LayoutCanvas.register() : super.register(){
    if (!reflectionEnabled){
      registerAttachedProperty('layoutcanvas.top', LayoutCanvas.setTop);
      registerAttachedProperty('layoutcanvas.left', LayoutCanvas.setLeft);
    }
  }
  makeMe() => new LayoutCanvas();

  get containerContent => children;

  @override void initProperties(){
    super.initProperties();

    background = new FrameworkProperty(this, 'background',
        propertyChangedCallback: (Brush brush){
          HtmlPlatformElement.setBackgroundBrush(this, brush);
        },
        converter: const StringToSolidColorBrushConverter());
  }

  @override void onFirstLoad(){
    super.onFirstLoad();

    children.forEach((child){
      LayoutCanvas._setPosition(child);
    });
  }

  @override void onLoaded(){
    super.onLoaded();
    //_ref = positionChanged + positionChanged_handler;
  }

  @override void onUnloaded(){
    super.onUnloaded();
    positionChanged - _ref;
  }

  @override void initEvents(){
    super.initEvents();

    children.listChanged + onChildrenChanging;
  }

  @override void updateLayout(){
    if (!isLoaded) return;

    children.forEach((child){
      _setPosition(child);
    });
  }

  void positionChanged_handler(sender, MeasurementChangedEventArgs args){
    children.forEach((child){
      _setPosition(child);
    });
  }

  void onChildrenChanging(_, ListChangedEventArgs args){
      args.oldItems.forEach((element){

        //restore the element's previous 'margin' state
        //element.margin = element.stateBag["margin"];
        //element.stateBag.remove("margin");

        //rawElement.removeChild(element.rawElement);
        element.rawElement.style.position = "inherit";
        element.rawElement.style.top = "0px";
        element.rawElement.style.left = "0px";

        element.attachedPropertyChanged - _onAttachedPropertyChanging;
        element.parent = null;
        element.rawElement.remove();
      });

      args.newItems.forEach((element){
        assert(element is HtmlPlatformElement);

        element.rawElement.style.position = "absolute";
        //var l = LayoutCanvas.getLeft(element);

        //var t = LayoutCanvas.getTop(element);

        //Since we are borrowing 'margin' to effect the canvas layout
        //preserve the element's original margin state.
        // (we can borrow margin because it has no place in a canvas layout anyway)
        //element.stateBag["margin"] = element.margin;

        // element.margin = new Thickness.specified(t, 0, 0, l);

        rawElement.elements.add(element.rawElement);

        element.attachedPropertyChanged + _onAttachedPropertyChanging;
        element.parent = this;
        _setPosition(element);
      });

  }

  void _onAttachedPropertyChanging(Object sender, AttachedPropertyChangedEventArgs args){
    //the attached property value changed so call it's callback to adjust the value
    args.property.propertyChangedCallback(sender, args.value);
  }

  static void _setPosition(HtmlPlatformElement el, {RectMeasurement mrm : null})
  {
    if (!el.parent.isLoaded) return;
    void doMeasurement(RectMeasurement m){
      final l = LayoutCanvas.getLeft(el);
      final t = LayoutCanvas.getTop(el);

      el.rawElement.style.left = '${m.left + l}px';
      el.rawElement.style.top = '${m.top + t}px';
    }

    if (mrm != null){
      doMeasurement(mrm);
    }else{
      htmlPlatform
        .measure(el.parent)
        .then((RectMeasurement r) => doMeasurement(r));
    }
  }

  /**
  * Sets the top value of the element relative to a parent LayoutCanvas container */
  static void setTop(HtmlPlatformElement element, value){
    if (element == null) return;

    assert(value is String || value is num);

    value = const StringToNumericConverter().convert(value);

    if (value < 0) value = 0;

    if (LayoutCanvas.topProperty == null) {
      LayoutCanvas.topProperty = new AttachedFrameworkProperty("top",
        (HtmlPlatformElement e, int v){
        _setPosition(e);
//        e.margin = new Thickness.specified(v, 0, 0, LayoutCanvas.getLeft(e));
      });
    }

    AttachedFrameworkProperty.setValue(element, topProperty, value);

  }

  /**
  * Returns the value currently assigned to the LayoutCanvas.topProperty for the given element. */
  static num getTop(HtmlPlatformElement element){
    if (element == null) return 0;

    var value = AttachedFrameworkProperty.getValue(element, topProperty);

    if (LayoutCanvas.topProperty == null || value == null) {
      LayoutCanvas.setTop(element, 0);
    }

    return AttachedFrameworkProperty.getValue(element, topProperty);
  }

  /**
  * Sets the left value of the element relative to a parent LayoutCanvas container */
  static void setLeft(HtmlPlatformElement element, value){
    if (element == null) return;

    assert(value is String || value is num);

    value = const StringToNumericConverter().convert(value);

    if (value < 0) value = 0;

    if (LayoutCanvas.leftProperty == null) {
      LayoutCanvas.leftProperty = new AttachedFrameworkProperty("left",
        (HtmlPlatformElement e, int v){
          _setPosition(e);
//          e.margin = new Thickness.specified(LayoutCanvas.getTop(e), 0, 0, v);
      });
    }

    AttachedFrameworkProperty.setValue(element, leftProperty, value);
  }

  /**
  * Returns the value currently assigned to the LayoutCanvas.leftProperty for the given element */
  static num getLeft(HtmlPlatformElement element){
    if (element == null) return 0;

    var value = AttachedFrameworkProperty.getValue(element, leftProperty);

    if (LayoutCanvas.leftProperty == null || value == null) {
      LayoutCanvas.setLeft(element, 0);
    }

    return AttachedFrameworkProperty.getValue(element, leftProperty);
  }

  @override void createPrimitive(){
    rawElement = new DivElement();
    rawElement.style.overflow = "hidden";
  }
}

