// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library youtube_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
import 'package:buckshot_html/web/web.dart';

class YouTube extends Control
{
  FrameworkProperty<String> videoID;

  YouTube();
  YouTube.register() : super.register();
  makeMe() => new YouTube();

  @override void initProperties(){
    super.initProperties();

    videoID = new FrameworkProperty(this, "videoID",
      propertyChangedCallback: (String value){
        rawElement.attributes["src"] =
          'http://www.youtube.com/embed/${value}?wmode=transparent';
      });
  }

  @override void createPrimitive(){
    rawElement = new Element.tag("iframe");
    Browser.appendClass(rawElement, 'youtube-player');
    rawElement.attributes["type"] = "text/html";
    rawElement.attributes["frameborder"] = "0";
  }
}
