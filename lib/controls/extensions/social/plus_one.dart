// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library plusone_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
* Implements a Google+ +1 button element for [HtmlSurface].
*/
class PlusOne extends Control
{
  final String _plusOneJS =
'''
(function() {
  var po = document.createElement('script'); 
  po.type = 'text/javascript'; 
  po.async = true;
  po.src = 'https://apis.google.com/js/plusone.js';
  var s = document.getElementsByTagName('script')[0]; 
  s.parentNode.insertBefore(po, s);
})();
''';

  FrameworkProperty<PlusOneAnnotationTypes> annotation;
  FrameworkProperty<PlusOneButtonSizes> size;

  PlusOne();
  PlusOne.register() : super.register();
  makeMe() => new PlusOne();

  void onFirstLoad(){
    _inject(_plusOneJS);
  }

  @override void initProperties(){
    super.initProperties();

    annotation = new FrameworkProperty(this, "annotation",
    propertyChangedCallback: (PlusOneAnnotationTypes value){
      rawElement.attributes["annotation"] = value.toString();
    },
    defaultValue:PlusOneAnnotationTypes.none,
    converter:const StringToPlusOneAnnotationTypeConverter());

    size = new FrameworkProperty(this, "size",
    propertyChangedCallback: (PlusOneButtonSizes value){
      rawElement.attributes["size"] = value.toString();
    },
    defaultValue:PlusOneButtonSizes.standard,
    converter:const StringToPlusOneButtonSizeConverter());
  }

  /**
  * Injects javascript into the DOM, and optionally removes it after the script has run. */
  static void _inject(String javascript, {bool removeAfter: false}){
    var s = new Element.tag("script");
    s.attributes["type"] = "text/javascript";
    s.text = javascript;

    document.body.nodes.add(s);

    if (removeAfter != null && removeAfter) {
      s.remove();
    }
  }

  @override void createPrimitive(){
    rawElement = new Element.tag("g:plusone");
    rawElement.attributes["annotation"] = "none";
    rawElement.attributes["size"] = "standard";
  }
}

class PlusOneButtonSizes{
  final String _str;
  const PlusOneButtonSizes(this._str);

  static const small = const PlusOneButtonSizes("small");
  static const medium = const PlusOneButtonSizes("medium");
  static const large = const PlusOneButtonSizes("large");
  static const standard = const PlusOneButtonSizes("standard");

  String toString() => _str;
}

class PlusOneAnnotationTypes{
  final String _str;
  const PlusOneAnnotationTypes(this._str);

  static const inline = const PlusOneAnnotationTypes("inline");
  static const bubble = const PlusOneAnnotationTypes("bubble");
  static const none = const PlusOneAnnotationTypes("none");

  String toString() => _str;
}


class StringToPlusOneButtonSizeConverter implements ValueConverter
{
  const StringToPlusOneButtonSizeConverter();

  @override dynamic convert(dynamic value, {dynamic parameter}){
    if (!(value is String)) return value;

    switch(value){
      case "small":
        return PlusOneButtonSizes.small;
      case "medium":
        return PlusOneButtonSizes.medium;
      case "large":
        return PlusOneButtonSizes.large;
      case "standard":
        return PlusOneButtonSizes.standard;
      default:
        return PlusOneButtonSizes.standard;
    }
  }
}

class StringToPlusOneAnnotationTypeConverter implements ValueConverter
{
  const StringToPlusOneAnnotationTypeConverter();

  @override dynamic convert(dynamic value, {dynamic parameter}){
    if (!(value is String)) return value;

    switch(value){
      case "inline":
        return PlusOneAnnotationTypes.inline;
      case "bubble":
        return PlusOneAnnotationTypes.bubble;
      case "none":
        return PlusOneAnnotationTypes.none;
      default:
        return PlusOneAnnotationTypes.none;
    }
  }
}
