library text_box_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* A basic single line TextBox.  Supports most forms of Html5 textual input type (see [InputTypes]) */
class TextBox extends Control
{
  FrameworkProperty<String> text;
  FrameworkProperty<InputTypes> inputType;
  FrameworkProperty<String> placeholder;
  FrameworkProperty<Color> borderColor;
  FrameworkProperty<Brush> background;
  FrameworkProperty<Thickness> borderThickness;
  FrameworkProperty<Thickness> cornerRadius;
  FrameworkProperty<BorderStyle> borderStyle;
  FrameworkProperty<num> padding;
  FrameworkProperty<Color> foreground;
  FrameworkProperty<num> fontSize;
  FrameworkProperty<String> fontFamily;

  final FrameworkEvent<TextChangedEventArgs> textChanged =
      new FrameworkEvent<TextChangedEventArgs>();

  TextBox()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = text;
    userSelect.value = true;
  }
  TextBox.register() : super.register();
  makeMe() => new TextBox();

  @override void initProperties(){
    super.initProperties();

    final _ie = rawElement as InputElement;

    placeholder = new FrameworkProperty(
      this,
      "placeholder",
      propertyChangedCallback: (String value){
        rawElement.attributes["placeholder"] = '$value';
      });

    text = new FrameworkProperty(this, "text",
      propertyChangedCallback: (value){
        _ie.value = '$value';
      },
      defaultValue: '');

    inputType = new FrameworkProperty(this, "inputType",
      propertyChangedCallback:
        (InputTypes value){
          if (InputTypes.isValidInputType(value)){
            rawElement.attributes["type"] = value.toString();
          }else{
            throw new BuckshotException("Invalid input '${value}' type passed to"
            " TextBox.inputType. Use InputTypes.{type} for safe assignment.");
          }
        },
      defaultValue: InputTypes.text,
      converter:const StringToInputTypesConverter());

    background = new AnimatingFrameworkProperty(
      this,
      "background",
      'background',
      propertyChangedCallback:(Brush value){
        HtmlPlatformElement.setBackgroundBrush(this, value);
      },
      defaultValue: getResource('theme_textbox_background'),
      converter:const StringToSolidColorBrushConverter());

    borderStyle = new FrameworkProperty(this, 'borderStyle',
        propertyChangedCallback: (BorderStyle value){
          rawElement.style.borderStyle = '$value';
        },
        defaultValue:
          getResource('theme_textbox_border_style',
                      converter: const StringToBorderStyleConverter()),
        converter: const StringToBorderStyleConverter());

    cornerRadius= new AnimatingFrameworkProperty(
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
      defaultValue: getResource('theme_textbox_corner_radius',
                                converter: const StringToThicknessConverter()),
      converter:const StringToThicknessConverter());

    borderColor = new AnimatingFrameworkProperty(
      this,
      "borderColor",
      'border',
      propertyChangedCallback: (Color c){
        rawElement.style.borderColor = c.toColorString();
      },
      defaultValue: getResource('theme_textbox_border_color'),
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
      defaultValue: getResource('theme_textbox_border_thickness',
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
        defaultValue: getResource('theme_textbox_padding',
                                  converter: const StringToThicknessConverter())
        , converter:const StringToThicknessConverter());

    foreground = new FrameworkProperty(
        this,
        "foreground",
        propertyChangedCallback: (Color c){
          rawElement.style.color = c.toColorString();
        },
        defaultValue: getResource('theme_textbox_foreground'),
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
      }, defaultValue:getResource('theme_text_font_family'));
  }


  @override void initEvents(){
    super.initEvents();

    registerEvent('textchanged', textChanged);

    final _ie = rawElement as InputElement;
    _ie.on.keyUp.add((e){
      if (text.value == _ie.value) return; //no change from previous keystroke

      String oldValue = text.value;
      text.value = _ie.value;

      if (!textChanged.hasHandlers) return;
      textChanged.invokeAsync(this,
          new TextChangedEventArgs.with(oldValue, text.value));

      if (e.cancelable) e.cancelBubble = true;
    });

    _ie.on.change.add((e){
      if (text.value == _ie.value) return; //no change from previous keystroke

      String oldValue = text.value;
      text.value = _ie.value;

      if (!textChanged.hasHandlers) return;
      textChanged.invokeAsync(this,
          new TextChangedEventArgs.with(oldValue, text.value));

      if (e.cancelable) e.cancelBubble = true;
    });

  }

  @override void createPrimitive(){
    rawElement = new InputElement();
    rawElement.attributes["type"] = "text";
  }
}

class TextChangedEventArgs extends EventArgs {
  String newText;
  String oldText;

  TextChangedEventArgs(){}

  TextChangedEventArgs.with(this.oldText, this.newText);
}
