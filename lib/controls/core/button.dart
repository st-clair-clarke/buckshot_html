// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library button_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
* A button control element.
*/
class Button extends Control implements FrameworkContainer
{
  /// Represents the content inside the button.
  FrameworkProperty<dynamic> content;

  Button()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = content;
  }

  @override void initProperties(){
    super.initProperties();

    // Initialize FrameworkProperty declarations.
    content = new FrameworkProperty(this, 'content');

    margin.value = new Thickness.specified(0, 3, 3, 0);
    zOrder.value = 0;
  }

  Button.register() : super.register();
  makeMe() => new Button();

  get containerContent => content.value;

  String get defaultControlTemplate {
    return
'''
<controltemplate controlType='${this.templateName}'>
  <template>
    <border zorder='32766'
            minwidth='20'
            minheight='20'
            background='{resource theme_button_background}'
            borderthickness='{resource theme_button_border_thickness}'
            bordercolor='{resource theme_button_border_color}'
            padding='{resource theme_border_padding}'
            cursor='Arrow'
            hittest='all'>
        <actions>
          <setproperty event='mouseEnter' property='background' value='{resource theme_button_background_hover}' />
          <setproperty event='mouseLeave' property='background' value='{resource theme_button_background}' />
        </actions>
        <contentpresenter hittest='none' halign='center' valign='center' content='{template content}' />
    </border>
  </template>
</controltemplate>
''';
  }
}
