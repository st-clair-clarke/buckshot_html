library text_area_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* A multi-line text box input element.
*
* ## See Also ##
* * [TextBox]
* * [TextBlock]
*/
class TextArea extends Control
{
  final FrameworkEvent<TextChangedEventArgs> textChanged =
      new FrameworkEvent<TextChangedEventArgs>();

  FrameworkProperty<String> text;
  FrameworkProperty<String> placeholder;
  FrameworkProperty<bool> spellcheck;
  FrameworkProperty<Color> borderColor;
  FrameworkProperty<Brush> background;
  FrameworkProperty<Thickness> borderThickness;
  FrameworkProperty<Thickness> cornerRadius;
  FrameworkProperty<BorderStyle> borderStyle;
  FrameworkProperty<num> padding;
  FrameworkProperty<Color> foreground;
  FrameworkProperty<num> fontSize;
  FrameworkProperty<String> fontFamily;

  TextArea(){
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = text;
    userSelect.value = true;
  }

  TextArea.register() : super.register();
  makeMe() => new TextArea();

  @override initProperties(){
    super.initProperties();

    placeholder = new FrameworkProperty(
      this,
      "placeholder",
      propertyChangedCallback: (String value){
        (rawElement as TextAreaElement).attributes["placeholder"] = '$value';
      });


    text = new FrameworkProperty(this, "text",
      propertyChangedCallback: (String value){
        (rawElement as TextAreaElement).value = value;
      },
      defaultValue: "");

    spellcheck= new FrameworkProperty(this, "spellcheck",
      propertyChangedCallback: (bool value){
        (rawElement as TextAreaElement).attributes["spellcheck"] = '$value';
      },
      converter:const StringToBooleanConverter());

    background = new AnimatingFrameworkProperty(
        this,
        "background",
        'background',
        propertyChangedCallback:(Brush value){
          HtmlPlatformElement.setBackgroundBrush(this, value);
        },
        defaultValue: getResource('theme_textarea_background'),
        converter:const StringToSolidColorBrushConverter());

    borderStyle = new FrameworkProperty(this, 'borderStyle',
        propertyChangedCallback: (BorderStyle value){
          rawElement.style.borderStyle = '$value';
        },
        defaultValue:
          getResource('theme_textarea_border_style',
                      converter: const StringToBorderStyleConverter()),
        converter: const StringToBorderStyleConverter());

    cornerRadius = new AnimatingFrameworkProperty(
      this,
      "cornerRadius",
      'border-radius',
      propertyChangedCallback:(Thickness value){
        // TODO (John) this is a temprorary fix until value converters are working in
        // templates...
        if (value is num){
          value = new Thickness(value);
        }

        rawElement.style.borderRadius = '${value.top}px ${value.right}px'
          ' ${value.bottom}px ${value.left}px';
      },
      defaultValue: getResource('theme_textarea_corner_radius',
                                converter: const StringToThicknessConverter()),
      converter:const StringToThicknessConverter());

    borderColor= new AnimatingFrameworkProperty(
      this,
      "borderColor",
      'border',
      propertyChangedCallback: (Color c){
        rawElement.style.borderColor = c.toColorString();
      },
      defaultValue: getResource('theme_textarea_border_color'),
      converter:const StringToColorConverter());


    borderThickness = new FrameworkProperty(
      this,
      "borderThickness",
      propertyChangedCallback: (value){

        String color = borderColor != null
            ? rawElement.style.borderColor
            : getResource('theme_textbox_border_color').toColorString();

        rawElement.style.borderTop = '${borderStyle} ${value.top}px $color';
        rawElement.style.borderRight = '${borderStyle} ${value.right}px $color';
        rawElement.style.borderLeft = '${borderStyle} ${value.left}px $color';
        rawElement.style.borderBottom = '${borderStyle} ${value.bottom}px $color';

      },
      defaultValue: getResource('theme_textarea_border_thickness',
                                converter:const StringToThicknessConverter()),
      converter:const StringToThicknessConverter());

    padding = new FrameworkProperty(
        this,
        "padding",
        propertyChangedCallback: (Thickness value){
          rawElement.style.padding = '${value.top}px ${value.right}px'
            ' ${value.bottom}px ${value.left}px';
          updateLayout();
        },
        defaultValue: getResource('theme_textarea_padding',
                                  converter: const StringToThicknessConverter())
        , converter:const StringToThicknessConverter());

    foreground = new FrameworkProperty(
        this,
        "foreground",
        propertyChangedCallback: (Color c){
          rawElement.style.color = c.toColorString();
        },
        defaultValue: getResource('theme_textarea_foreground'),
        converter:const StringToColorConverter());

    fontSize = new FrameworkProperty(
      this,
      "fontSize",
      propertyChangedCallback: (value){
        rawElement.style.fontSize = '${value}px';
      });

    fontFamily = new FrameworkProperty(
      this,
      "fontFamily",
      propertyChangedCallback: (value){
        rawElement.style.fontFamily = '$value';
      },
      defaultValue:getResource('theme_textarea_font_family'));
  }


  @override void initEvents(){
    super.initEvents();

    registerEvent('textchanged', textChanged);

    (rawElement as TextAreaElement).on.keyUp.add((e){
      if (text == (rawElement as TextAreaElement).value) return; //no change from previous keystroke

      String oldValue = text.value;
      text.value = (rawElement as TextAreaElement).value;

      if (!textChanged.hasHandlers) return;
      textChanged.invoke(this, new TextChangedEventArgs.with(oldValue, text.value));

      if (e.cancelable) e.cancelBubble = true;
    });

    (rawElement as TextAreaElement).on.change.add((e){
      if (text.value == (rawElement as TextAreaElement).value) return; //no change from previous keystroke

      String oldValue = text.value;
      text.value = (rawElement as TextAreaElement).value;

      if (!textChanged.hasHandlers) return;
      textChanged.invoke(this, new TextChangedEventArgs.with(oldValue, text.value));

      if (e.cancelable) e.cancelBubble = true;
    });

  }

  @override void createPrimitive(){
    rawElement = new TextAreaElement();
  }
}
