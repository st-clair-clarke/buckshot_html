// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library vimeo_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
 * A Vimeo player for [HtmlSurface].
 */
class Vimeo extends Control
{
  FrameworkProperty<String> videoID;

  Vimeo();
  Vimeo.register() : super.register();
  makeMe() => new Vimeo();

  @override void initProperties(){
    super.initProperties();

    videoID= new FrameworkProperty(this, "videoID",
      propertyChangedCallback: (String value){
        rawElement.attributes["src"] =
            'http://player.vimeo.com/video/${value}';
      });
  }

  @override void createPrimitive(){
    rawElement = new Element.tag("iframe");
    rawElement.attributes["frameborder"] = "0";
  }
}
