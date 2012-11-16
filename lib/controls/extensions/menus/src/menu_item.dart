part of menus_control_extensions_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/** Represents an item in a [Menu] control */
class MenuItem extends Control
{
  FrameworkProperty<HtmlPlatformElement> icon;
  FrameworkProperty<HtmlPlatformElement> header;

  MenuItem();
  MenuItem.register() : super.register();
  @override makeMe() => new MenuItem();

  @override void initProperties()
  {
    super.initProperties();
    icon = new FrameworkProperty(this, 'icon');
    header = new FrameworkProperty(this, 'header');
  }

  @override get defaultControlTemplate {
    return '''
<controltemplate controlType='${this.templateName}'>
  <template>
    <stack orientation='horizontal' halign='stretch' maxheight='50'>
       <contentpresenter valign='center' minwidth='25' maxwidth='25' content='{template icon}' />
       <contentpresenter valign='center' maxwidth='300' margin='0,0,0,5' content='{template header}' />
    </stack>
  </template>
</controltemplate>
''';
  }
}
