// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library tabcontrol_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

part 'src/tab_item.dart';
part 'src/tab_selected_event_args.dart';

class TabControl extends Control implements FrameworkContainer
{
  FrameworkProperty<dynamic> currentContent;
  FrameworkProperty<ObservableList<TabItem>> tabItems;
  FrameworkProperty<HorizontalAlignment> tabAlignment;
  FrameworkProperty<Brush> tabBackground;
  FrameworkProperty<Brush> tabSelectedBrush;
  FrameworkProperty<Brush> background;

  final FrameworkEvent<TabSelectedEventArgs> tabSelected =
      new FrameworkEvent<TabSelectedEventArgs>();
  final FrameworkEvent<TabSelectedEventArgs> tabClosing =
      new FrameworkEvent<TabSelectedEventArgs>();

  TabItem currentTab;
  Brush _tabBackground;

  TabControl()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = tabItems.value;
    tabItems.value.listChanged + tabItemsChanged;
  }
  TabControl.register() : super.register(){
    registerElement(new TabItem.register());
  }
  @override makeMe() => new TabControl();

  @override get containerContent => tabItems.value;

  void tabItemsChanged(_, ListChangedEventArgs args){
    args.newItems.forEach((item){
      assert(item is TabItem);
      item.parent = this;
    });
  }

  void switchToTab(TabItem tab){
    if (currentTab == tab) return;

    assert(tab._visualTemplate != null);

    if (currentTab != null){
      final b = currentTab._visualTemplate as Border;

      //remove active markings on this tab.
      currentTab._closeButtonVisiblity.value = Visibility.collapsed;
      b.background.value = _tabBackground;

      b.borderThickness.value = new Thickness.specified(1, 1, 0, 1);
    }

    currentTab = tab;

    final t = currentTab._visualTemplate as Border;
      //set active markings on the tab.

    _tabBackground = t.background.value;

    currentTab._closeButtonVisiblity.value = Visibility.visible;

    (currentTab._visualTemplate as Border).borderThickness.value =
        new Thickness.specified(2, 2, 0, 2);

    t.background.value = tabSelectedBrush.value;

    currentContent.value =
        currentTab.content.value is String
          ? (new TextBlock()..text.value = '${currentTab.content.value}')
          : currentTab.content.value;
  }

  void closeTab(TabItem tab){
    //TODO add handling for last tab closed.
    if (tabItems.value.length == 1) return;

    tab._visualTemplate.rawElement.remove();

    tabItems.value.removeRange(tabItems.value.indexOf(tab), 1);

    currentTab = null;

    switchToTab(tabItems.value[0]);
  }

  @override void onLoaded(){
    super.onLoaded();

    if (tabItems.value.isEmpty) return;

    // this is the collection of the visual elements representing each
    // tab
    Stack pc = (Template.findByName('__tc_presenter__', template)
        as CollectionPresenter)
        .presentationPanel
        .value;

    int i = 0;
    pc.children.forEach((e){
      final ti = tabItems.value[i++] as TabItem;
      ti.parent = this;
      ti._visualTemplate = e;
      e.mouseUp + (_, __){
        tabSelected.invokeAsync(this, new TabSelectedEventArgs(ti));
      };

      final b = Template.findByName('__close_button__', e);
      assert(b != null);

      b.mouseUp + (_, __){
        tabClosing.invokeAsync(this, new TabSelectedEventArgs(ti));
      };
    });

    tabSelected + (_, args){
      switchToTab(args.tab);
    };

    tabClosing + (_, args){
      closeTab(args.tab);
    };

    switchToTab(tabItems.value[0]);
  }

  @override void initProperties(){
    super.initProperties();

    currentContent = new FrameworkProperty(this, 'currentContent');

    tabItems = new FrameworkProperty(this, 'tabItems',
        defaultValue: new ObservableList<TabItem>());

    tabAlignment = new FrameworkProperty(this, 'tabAlignment',
        defaultValue: HorizontalAlignment.left,
        converter: const StringToHorizontalAlignmentConverter());

    tabSelectedBrush = new FrameworkProperty(this, 'tabSelectedBrush',
        defaultValue: new SolidColorBrush(getResource('theme_background_light')),
        converter: const StringToSolidColorBrushConverter());

    background = new FrameworkProperty(this, 'background',
        defaultValue: new SolidColorBrush(getResource('theme_background_light')),
        converter: const StringToSolidColorBrushConverter());

  }

  @override get defaultControlTemplate {
    return
'''
<controltemplate controlType='${this.templateName}'>
  <template>
     <grid hittest='none' valign='{template vAlign}' halign='{template hAlign}' height='{template height}' width='{template width}'>
        <rowdefinitions>
           <rowdefinition height='auto' />
           <rowdefinition height='*' />
        </rowdefinitions>
        <collectionpresenter name='__tc_presenter__' halign='{template tabAlignment}' items='{template tabItems}'>
           <presentationpanel>
              <stack orientation='horizontal' />
           </presentationpanel>
           <itemstemplate>
              <border hittest='all' name='tab_border' valign='stretch' cursor='Arrow' background='{resource theme_dark_brush}' margin='0,1,0,0' borderthickness='1,1,0,1' bordercolor='{resource theme_border_color}' padding='2'>
                 <stack orientation='horizontal'>
                    <contentpresenter hittest='none' content='{data icon}' margin='0,2,0,0' />
                    <contentpresenter hittest='none' content='{data header}' margin='0,3,0,0' />
                    <border hittest='none' margin='0,2,0,3' valign='top' width='13' height='13' padding='0,0,2,0'>
                      <border hittest='all' name='__close_button__' borderColor='{resource theme_border_color}' borderthickness='{resource theme_border_thickness}' halign='stretch' valign='stretch' visibility='{data closeButtonVisibility}'>
                          <actions>
                             <setproperty event='mouseEnter' property='background' value='Orange' />
                             <setproperty event='mouseLeave' property='background' value='White' />
                             <setproperty event='mouseDown' property='background' value='#CCCCCC' />
                             <setproperty event='mouseUp' property='background' value='Orange' />
                          </actions>
                          <textblock text='X' foreground='Gray' valign='center' halign='center' fontfamily='Arial' fontsize='10' />
                      </border>
                    </border>
                 </stack>
              </border>
           </itemstemplate>
        </collectionpresenter>
        <border name='__content_border__' 
                content='{template currentContent}' 
                grid.row='1' 
                halign='stretch' 
                valign='stretch'
                bordercolor='{resource theme_border_color}' 
                borderthickness='{resource theme_border_thickness}' 
                background='{template background}' 
                padding='{resource theme_border_padding}'
                hittest='all' />
     </grid>
  </template>
</controltemplate>
''';
  }
}

