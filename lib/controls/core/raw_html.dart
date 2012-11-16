// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library rawhtml_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
 * ## Experimental ##
 * Renders raw html to the browser.
 *
 * In xml, the [htmlString] property must be assigned to directly,
 * not in node form:
 *
 * ### Good ###
 *     <rawhtml htmlstring='<div style="width:100px"></div>'></rawhtml>
 *
 * ### Bad ###
 *     <rawhtml>
 *         <htmlstring>
 *             <!-- won't render -->
 *             <div></div>
 *         </htmlstring>
 *     </rawhtml>
 */
class RawHtml extends Control
{
  /// A framework property representing the raw html string.
  FrameworkProperty<String> htmlString;

  RawHtml();
  RawHtml.register() : super.register();
  makeMe() => new RawHtml();

  @override void initProperties(){
    super.initProperties();

    htmlString = new FrameworkProperty(
      this,
      "htmlString",
      propertyChangedCallback: (String value){
        rawElement.innerHTML = '$value';
      });
  }

  @override void createPrimitive(){
    rawElement = new DivElement();
  }
}
