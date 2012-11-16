// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library funnyordie_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
 * A FunnyOrDie video player control for [HtmlSurface].
 */
class FunnyOrDie extends Control
{
  FrameworkProperty<String> videoID;

  FunnyOrDie();
  FunnyOrDie.register() : super.register();
  makeMe() => new FunnyOrDie();

  @override void initProperties(){
    super.initProperties();

    videoID = new FrameworkProperty(this, "videoID",
      propertyChangedCallback: (String value){
        rawElement.attributes["src"] =
          'http://www.funnyordie.com/embed/${value}';
      });
  }

  @override void createPrimitive(){
    rawElement = new Element.tag("iframe");
    rawElement.attributes["frameborder"] = "0";
  }
}
