library hyperlink_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* An element that renders a browser link.
*/
class Hyperlink extends Control implements FrameworkContainer
{
  dynamic _content;

  /// Represents the content of the hyperlink.
  FrameworkProperty<dynamic> content;
  /// Represents the html 'target' value of the hyperlink.
  FrameworkProperty<String> targetName;
  /// Represents the url navigation target of the hyperlink.
  FrameworkProperty<String> navigateTo;
  /// Represents the foreground [Color] of a textual hyperlink.
  FrameworkProperty<Color> foreground;
  /// Represents the font size of a textual hyperlink.
  FrameworkProperty<num> fontSize;
  /// Represents the font family value of a textual hyperlink.
  FrameworkProperty<String> fontFamily;

  Hyperlink()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = content;
  }

  Hyperlink.register() : super.register();
  makeMe() => new Hyperlink();

  get containerContent => content.value;

  @override void initProperties(){
    super.initProperties();

    // Initialize FrameworkProperty declarations.
    content = new FrameworkProperty(
      this,
      "content",
      propertyChangedCallback: (value) {
        //if the content is previously a textblock and the value is a String then just
        //replace the text property with the new string
        if (_content is TextBlock && value is String){
          _content.text = value;
          return;
        }

        rawElement.style.textDecoration = "none";

        //accomodate strings by converting them silently to TextBlock
        if (value is String){
            var tempStr = value;
            rawElement.style.textDecoration = "underline";
            value = new TextBlock();
            (value as TextBlock).text.value = tempStr;
        }

        if (_content != null){
          _content.rawElement.remove();
          _content.parent = null;
        }

        if (value != null){
          _content = value;
          _content.parent = this;
          rawElement.nodes.add(_content.rawElement);
        }else{
          _content = null;
        }
      });

    targetName = new FrameworkProperty(this, "targetName",
      propertyChangedCallback: (String value){
        rawElement.attributes["target"] = value.toString();
      },
      defaultValue: "_self");

    navigateTo = new FrameworkProperty(this, "navigateTo",
      propertyChangedCallback: (String value){
        rawElement.attributes["href"] = value.toString();
      });

    foreground = new FrameworkProperty(
      this,
      "foreground",
      propertyChangedCallback: (Color value){
        rawElement.style.color = '$value';
      },
      defaultValue: getResource('theme_text_foreground'),
      converter:const StringToColorConverter());

    fontSize = new FrameworkProperty(
      this,
      "fontSize",
      propertyChangedCallback: (value){
        rawElement.style.fontSize = '${value.toString()}px';
      },
      converter:const StringToNumericConverter());

    fontFamily = new FrameworkProperty(
      this,
      "fontFamily",
      propertyChangedCallback: (value){
        rawElement.style.fontFamily = value.toString();
      });
  }

  /// Overridden [FrameworkObject] method.
  @override void createPrimitive()
  {
    //TODO find correct constructor for 'a'.
    rawElement = new Element.tag('a');
  }
}
