library slider_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/*
 * TODO:
 * custom slider that works horizontal and vertical.
 */

/**
* A slider control.
* NOTE: This may not render on some browsers. */
class Slider extends Control
{

  FrameworkProperty<num> min;
  FrameworkProperty<num> max;
  FrameworkProperty<num> step;
  FrameworkProperty<num> value;

  Slider();
  Slider.register() : super.register();
  makeMe() => new Slider();

  @override void initEvents(){
    super.initEvents();

    rawElement.on.change.add((e){
      final ie = rawElement as InputElement;
      if (value.value == ie.value) return; //no change
      value.value = double.parse(ie.value);
      e.stopPropagation();
    });
  }

  @override void initProperties(){
    super.initProperties();

    min = new FrameworkProperty(this, "min",
      propertyChangedCallback: (num v){
        rawElement.attributes["min"] = '$v';
      },
      defaultValue: 0,
      converter:const StringToNumericConverter());

    max= new FrameworkProperty(this, "max",
      propertyChangedCallback: (num v){
        rawElement.attributes["max"] = v.toInt().toString();
      },
      defaultValue: 100,
      converter:const StringToNumericConverter());

    step = new FrameworkProperty(this, "step",
      propertyChangedCallback: (num v){
        rawElement.attributes["step"] = v.toString();
      },
      converter:const StringToNumericConverter());

    value = new FrameworkProperty(this, "value",
      propertyChangedCallback: (num v){
        (rawElement as InputElement).value = v.toString();
      },
      converter:const StringToNumericConverter());
  }

  @override void createPrimitive(){
    rawElement = new InputElement();
    rawElement.attributes["type"] = "range";
  }
}
