// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library hulu_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
 * A Hulu player control for [HtmlSurface].
 */
class Hulu extends Control
{
  Element embed;
  Element param1;
  FrameworkProperty<String> videoID;

  Hulu();
  Hulu.register() : super.register();
  makeMe() => new Hulu();

  @override void initProperties(){
    super.initProperties();

    videoID = new FrameworkProperty(this, "videoID",
      propertyChangedCallback: (String value){
        param1.attributes["src"] = 'http://www.hulu.com/embed/${value}';
        embed.attributes["src"] = 'http://www.hulu.com/embed/${value}';
      });
  }

  @override void onLoaded(){
    super.onLoaded();

    htmlPlatform
      .measure(this)
      .then((RectMeasurement r){
        rawElement.attributes["width"] = '${r.width}px';
        rawElement.attributes["height"] = '${r.height}px';
        embed.attributes["width"] = '${r.width}px';
        embed.attributes["height"] = '${r.height}px';
      });
  }

//  <object width="512" height="288">
//  <param name="movie" value="http://www.hulu.com/embed/QRNTv9APf02C6J_xFpY0Dg"></param>
//  <param name="allowFullScreen" value="true"></param>
//  <embed src="http://www.hulu.com/embed/QRNTv9APf02C6J_xFpY0Dg" type="application/x-shockwave-flash"  width="512" height="288" allowFullScreen="true"></embed>
//  </object>

  @override void createPrimitive(){

    rawElement = new Element.tag("object");
    param1 = new Element.html("<param name='movie' />");
    final param2 = new Element.html("<param allowFullScreen='true' />");
    embed = new Element.html("<embed type='application/x-shockwave-flash' allowFullScreen='true' />");
    rawElement.elements.add(param1);
    rawElement.elements.add(param2);
    rawElement.elements.add(embed);
  }
}
