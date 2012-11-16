part of menus_control_extensions_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
 * Represents a floating vertical list of selectable items.
 *
 * The [headerProperty] will not be visible unless the [Menu] is
 * associated with a [MenuStrip].
 */
class Menu extends Control implements FrameworkContainer
{
  FrameworkProperty<ObservableList<MenuItem>> menuItems;
  FrameworkProperty<String> parentName;
  FrameworkProperty<dynamic> header;
  FrameworkProperty<HtmlPlatformElement> _menuParent;
  FrameworkProperty<num> offsetX;
  FrameworkProperty<num> offsetY;

  final FrameworkEvent<MenuItemSelectedEventArgs> menuItemSelected =
      new FrameworkEvent<MenuItemSelectedEventArgs>();

  Menu()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = menuItems.value;
  }
  Menu.register() : super.register();
  @override makeMe() => new Menu();

  @override void initEvents(){
    super.initEvents();
    registerEvent('menuitemselected', menuItemSelected);
  }

  void onItemsChanging(_, ListChangedEventArgs args){
    args.newItems.forEach((item){
      item.parent = this;
    });

    args.oldItems.forEach((item){
      item.parent = null;
    });
  }

  @override void onFirstLoad(){
    assert(parent != null);

    var mp = _menuParent.value;

    if (mp == null){
      _menuParent.value = parent;
    }

    _setPosition().then((_){
      if (menuItems.value.isEmpty) return;

      menuItems.value.forEach((MenuItem item){
        item.click + (_, __){
          menuItemSelected.invoke(this, new MenuItemSelectedEventArgs(item));
          hide();
        };
      });

      if (visibility.value == Visibility.visible){
        show();
      }
    });

    document.body.on.click.add((e){
      if (visibility.value == Visibility.visible){
        hide();

        if (parent is MenuStrip){
          (parent as MenuStrip).hideAllMenus();
        }
      }
    });
  }

  Future show(){
   return _setPosition()
             .chain((_){
              visibility.value = Visibility.visible;
              return new Future.immediate(true);
            });
  }

  void hide(){
    visibility.value = Visibility.collapsed;
  }

  Future _setPosition(){
    var mp = _menuParent.value;
    if (mp == null) new Future.immediate(null);

    return htmlPlatform
             .measure(mp)
             .chain((RectMeasurement r){
              rawElement.style.left = '${offsetX.value + r.left}px';
              rawElement.style.top = '${offsetY.value + r.top}px';
              return new Future.immediate(r);
            });
  }

  @override void initProperties(){
    super.initProperties();

    menuItems = new FrameworkProperty(this, 'menuItems',
        defaultValue: new ObservableList<MenuItem>());

    _menuParent = new FrameworkProperty(this, '_menuParent');

    offsetX = new FrameworkProperty(this, 'offsetX',
        defaultValue: 0,
        converter: const StringToNumericConverter());

    offsetY = new FrameworkProperty(this, 'offsetY',
        defaultValue: 0,
        converter: const StringToNumericConverter());

    header = new FrameworkProperty(this, 'header');

    rawElement.style.position = 'absolute';
    rawElement.style.top = '0px';
    rawElement.style.left = '0px';
    visibility.value = Visibility.collapsed;

    menuItems.value.listChanged + onItemsChanging;
  }

  @override get containerContent => menuItems.value;

  @override get defaultControlTemplate {
    return '''
<controltemplate controlType='${this.templateName}'>
  <template>
    <border zorder='32766'
            minwidth='20'
            minheight='20'
            borderthickness='{resource theme_border_thickness}'
            bordercolor='{resource theme_border_color}'
            cursor='Arrow'>
      <collectionpresenter halign='stretch' items='{template menuItems}'>
         <itemstemplate>
           <border padding='{resource theme_menu_padding}' background='{resource theme_dark_brush}' halign='stretch'>
              <actions>
                <setproperty event='mouseEnter' property='background' value='{resource theme_menu_background_hover_brush}' />
                <setproperty event='mouseLeave' property='background' value='{resource theme_menu_background_brush}' />
                <setproperty event='mouseDown' property='background' value='{resource theme_menu_background_mouse_down_brush}' />
                <setproperty event='mouseUp' property='background' value='{resource theme_menu_background_hover_brush}' />
              </actions>
              <contentpresenter content='{data}' />
           </border>
         </itemstemplate>
      </collectionpresenter>
    </border>
  </template>
</controltemplate>
''';
  }
}
