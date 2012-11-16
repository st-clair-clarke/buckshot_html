part of menus_control_extensions_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

class MenuStrip extends Control implements FrameworkContainer
{
  FrameworkProperty<ObservableList<Menu>> menus;
  FrameworkProperty<Orientation> orientation;

  final FrameworkEvent<MenuItemSelectedEventArgs> menuItemSelected =
      new FrameworkEvent<MenuItemSelectedEventArgs>();

  Menu _previousMenu;

  MenuStrip()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = menus.value;
  }
  MenuStrip.register() : super.register();
  @override makeMe() => new MenuStrip();

  @override void initEvents(){
    super.initEvents();
    registerEvent('menuitemselected', menuItemSelected);
  }

  void onMenusChanging(_, ListChangedEventArgs args){
    args.newItems.forEach((item){
      item.parent = this;
    });

    args.oldItems.forEach((item){
      item.parent = null;
    });
  }

  @override void initProperties(){
    super.initProperties();

    menus = new FrameworkProperty(this, 'menus',
        defaultValue: new ObservableList<Menu>());

    orientation = new FrameworkProperty(this, 'orientation',
        defaultValue: Orientation.horizontal,
        converter: const StringToOrientationConverter());

    menus.value.listChanged + onMenusChanging;
  }

  @override get containerContent => menus.value;

  @override void onLoaded(){
    super.onLoaded();
    if (menus.value.isEmpty) return;

    final cp = Template.findByName('__menu_strip_cp__', template);
    assert(cp != null);
    assert(cp is CollectionPresenter);

    menus.value.forEach((Menu m){
      if (!m.menuItems.value.isEmpty){
        m.menuItemSelected + (sender, MenuItemSelectedEventArgs args){
          //just bubble the event
          menuItemSelected.invoke(sender, args);
        };
      }

      if (m.header == null) return;

      final cpTemplate = cp.templateReference[m] as Stack;

      // gets the border surrounding the menu header content
      final b = cpTemplate.children[0] as Border;

      b.click + (_, __){
        if (m.visibility.value == Visibility.visible){
          m.hide();
          return;
        }
        hideAllMenus();
        if (m.menuItems.value.isEmpty){
            // item-less menu, so just send the menu in the sender of the
            // event..
            menuItemSelected.invoke(m, new MenuItemSelectedEventArgs(null));
        }else{
          m.show();
        }
      };
    });
  }

  /**
   * Hides any currently open menus attached to the MenuStrip.
   */
  void hideAllMenus(){
    if (menus.value.isEmpty) return;

    menus.value.forEach((Menu m){
      if (!m.menuItems.value.isEmpty){
        m.hide();
      }
    });
  }

  @override get defaultControlTemplate {
    return '''
<controltemplate controlType='${this.templateName}'>
  <template>
    <border cursor='Arrow' background='{resource theme_menu_background_brush}'>
      <collectionpresenter name='__menu_strip_cp__' halign='stretch' items='{template menus}'>
         <presentationpanel>
            <stack orientation='{template orientation}'></stack>
         </presentationpanel>
         <itemstemplate>
           <stack>
              <border padding='{resource theme_border_padding}' background='{resource theme_menu_background_brush}' halign='stretch'>
                <actions>
                   <setproperty event='mouseEnter' property='background' value='{resource theme_menu_background_hover_brush}' />
                   <setproperty event='mouseLeave' property='background' value='{resource theme_menu_background_brush}' />
                   <setproperty event='mouseDown' property='background' value='{resource theme_menu_background_mouse_down_brush}' />
                   <setproperty event='mouseUp' property='background' value='{resource theme_menu_background_hover_brush}' />
                </actions>
                <contentpresenter content='{data header}' />
              </border>
              <contentpresenter content='{data}' />
           </stack>
         </itemstemplate>
      </collectionpresenter>
    </border>
  </template>
</controltemplate>
''';
  }
}
