// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library tabcontrol_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
part 'src/accordion_item.dart';

class Accordion extends Control implements FrameworkContainer
{
  FrameworkProperty<ObservableList<AccordionItem>> accordionItems;
  FrameworkProperty<Brush> background;
  FrameworkProperty<SelectionMode> selectionMode;

  var _currentSelected;

  Accordion()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = accordionItems.value;
  }
  Accordion.register() : super.register(){
    registerElement(new AccordionItem.register());
  }
  @override makeMe() => new Accordion();

  @override void initProperties(){
    super.initProperties();

    accordionItems = new FrameworkProperty(this, 'accordionItems',
        defaultValue: new ObservableList<FrameworkObject>());

    background = new FrameworkProperty(this, 'background',
        defaultValue: new SolidColorBrush(new Color.predefined(Colors.White)),
        converter: const StringToSolidColorBrushConverter());

    selectionMode = new FrameworkProperty(this, 'selectionMode',
        propertyChangedCallback: (_){
          if (!isLoaded) return;
          _invalidate();
        },
        defaultValue: SelectionMode.single,
        converter: const StringToSelectionModeConverter());
  }

  @override get containerContent => accordionItems.value;

  @override void initEvents(){
    super.initEvents();

    // Invalidate on any changes to the list after first load.
    accordionItems.value.listChanged + (_, __) => _invalidate();
  }

  @override void onLoaded(){
    super.onLoaded();
    _invalidate();
  }

  void _invalidate(){
    if (accordionItems.value.isEmpty) return;

    Stack pc = (Template.findByName('__ac_presenter__', template)
        as CollectionPresenter)
        .presentationPanel
        .value;

    int i = 0;

    pc.children.forEach((e){
      final ai = accordionItems.value[i++];

      final header = Template.findByName('__accordion_header__', e);
      final body = Template.findByName('__accordion_body__', e);

      assert(header != null && body != null);

      //TODO Need a better way to handle the event cycle as this will clobber
      // any user hooked events.
      header.click.handlers.clear();

      if (selectionMode.value == SelectionMode.multi ||
          accordionItems.value.length == 1){
        body.visibility.value = ai.visibility.value;

        header.click + (_, __){
          body.visibility.value =
              (body.visibility.value != Visibility.collapsed)
              ? Visibility.collapsed
              : Visibility.visible;
          //BUG: Multi-mode not working...
          print('$body ${body.visibility.value}');
        };
      }else{
        // first item visible if nothing selected
        if (_currentSelected == null && pc.children.indexOf(e) == 0){
          _currentSelected = header;
          body.visibility.value = Visibility.visible;
        }else{
          if (header == _currentSelected){
            body.visibility.value = Visibility.visible;
          }else{
            body.visibility.value = Visibility.collapsed;
          }
        }

        header.click + (_, __){
          _currentSelected = header;
          _invalidate();
        };
      }
    });
  }

  String get defaultControlTemplate {
    return
'''
<controltemplate controlType='${this.templateName}'>
  <template>
    <border background='{template background}' cursor='Arrow'>
      <collectionpresenter halign='stretch' name='__ac_presenter__' items='{template accordionItems}'>
         <presentationpanel>
            <stack halign='stretch' />
         </presentationpanel>
         <itemstemplate>
            <stack halign='stretch'>
              ${headerTemplate}
              ${bodyTemplate}
            </stack>
         </itemstemplate>
      </collectionpresenter>
    </border>
  </template>
</controltemplate>
''';
  }

  /**
   * Override this template if you want to customize the look and feel of the
   * Accordion header.
   */
  String get headerTemplate =>
'''
 <border name='__accordion_header__' 
         padding='{resource theme_border_padding}' 
         borderthickness='{resource theme_accordion_header_border_thickness}' 
         bordercolor='{resource theme_border_color}' 
         background='{resource theme_accordion_header_background_brush}' 
         halign='stretch'>
    <actions>
      <setproperty event='mouseEnter' 
                   property='background' 
                   value='{resource theme_accordion_background_hover_brush}' />
      <setproperty event='mouseLeave' 
                   property='background' 
                   value='{resource theme_accordion_header_background_brush}' />
      <setproperty event='mouseDown' 
                   property='background' 
                   value='{resource theme_accordion_background_mouse_down_brush}' />
      <setproperty event='mouseUp' 
                   property='background' 
                   value='{resource theme_accordion_background_hover_brush}' />
    </actions>
    <contentpresenter halign='stretch' content='{data header}' />                   
 </border>
''';

  /**
   * Override this template if you want to customize the look and feel of the
   * Accordion body.
   */
  String get bodyTemplate =>
'''
 <border name='__accordion_body__' 
         halign='stretch' 
         background='{resource theme_accordion_body_background_brush}'>
   <contentpresenter halign='stretch' content='{data body}' />
 </border>
''';

}

class SelectionMode
{
  final _str;

  const SelectionMode(this._str);

  static const single = const SelectionMode('single');
  static const multi = const SelectionMode('multi');
}

class StringToSelectionModeConverter implements ValueConverter
{
  const StringToSelectionModeConverter();

  dynamic convert(dynamic value, {dynamic parameter}){
    if (!(value is String)) return value;

    switch(value){
      case "single":
        return SelectionMode.single;
      case "multi":
        return SelectionMode.multi;
      default:
        throw const BuckshotException("Invalid SelectionMode value.");
      }
  }
}

