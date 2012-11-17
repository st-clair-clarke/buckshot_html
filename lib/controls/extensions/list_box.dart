// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

//TODO add mouse state template properties

library plusone_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
* A control that provides a scrollable list of selectable items.
*/
class ListBox extends Control implements FrameworkContainer
{
  FrameworkProperty<ScrollSetting> hScroll;
  FrameworkProperty<ScrollSetting> vScroll;
  FrameworkProperty<dynamic> selectedItem;
  /// Represents the [Panel] element which will contain the generated UI for
  /// each element of the collection.
  FrameworkProperty<HtmlPlatformElement> presentationPanel;

  /// Represents the UI that will display for each item in the collection.
  FrameworkProperty<String> itemsTemplate;

  FrameworkProperty<Brush> highlightBrush;
  FrameworkProperty<Brush> selectBrush;

  CollectionPresenter _presenter;
  Border _border;

  int _selectedIndex = -1;

  final FrameworkEvent<SelectedItemChangedEventArgs> selectionChanged =
      new FrameworkEvent<SelectedItemChangedEventArgs>();

  int get selectedIndex => _selectedIndex;

  ListBox()
  {
    _presenter = Template
      .findByName("__buckshot_listbox_presenter__", template)
        as CollectionPresenter;

    _border = Template.findByName("__buckshot_listbox_border__", template);

    assert(_presenter != null);
    assert(_border != null);

    _presenter.itemCreated + _OnItemCreated;
  }

  ListBox.register() : super.register();
  makeMe() => new ListBox();

  @override void initEvents(){
    super.initEvents();

    registerEvent('selectionchanged', selectionChanged);
  }

  String get defaultControlTemplate {
    return
    '''<controltemplate controlType="${this.templateName}">
          <template>
            <border bordercolor='{resource theme_border_color}'
                    background='{resource theme_light_brush}'
                    borderthickness='{resource theme_border_thickness}' 
                    name="__buckshot_listbox_border__"
                    cursor="Arrow">
              <scrollviewer hscroll='{template hScroll}' 
                            vscroll='{template vScroll}'
                            halign='stretch'
                            valign='stretch'>
                <collectionPresenter halign='stretch' name='__buckshot_listbox_presenter__' />
              </scrollviewer>
            </border>
          </template>
        </controltemplate>
    ''';
  }

  void _OnItemCreated(sender, ItemCreatedEventArgs args){
    HtmlPlatformElement item = args.itemCreated;

    item.click + (_, __) {
      _selectedIndex =
          (_presenter.presentationPanel.value as Stack).children.indexOf(item);

      selectedItem.value = _presenter.objectReference[item];

      selectionChanged.invoke(this,
          new SelectedItemChangedEventArgs(_presenter.objectReference[item]));
    };

    item.mouseEnter + (_, __) => onItemMouseEnter(item);

    item.mouseLeave + (_, __) => onItemMouseLeave(item);

    item.mouseDown + (_, __) => onItemMouseDown(item);

    item.mouseUp + (_, __) => onItemMouseUp(item);
  }

  @override get containerContent => template;

  /// Override this method to implement your own mouse over behavior for items in
  /// the ListBox.
  void onItemMouseDown(item){
    if (item.hasProperty("background")){
      item.background.value = selectBrush.value;
    }
  }

  /// Override this method to implement your own mouse over behavior for items in
  /// the ListBox.
  void onItemMouseUp(item){
    if (item.hasProperty("background")){
      item.background.value = highlightBrush.value;
    }
  }

  /// Override this method to implement your own mouse over behavior for items in
  /// the ListBox.
  void onItemMouseEnter(item){
    if (item.hasProperty("background")){
      if (item.background.value == null){
        item.stateBag["__lb_item_bg_brush__"] =
            new SolidColorBrush.fromPredefined(Colors.White);
      }else{
        item.stateBag["__lb_item_bg_brush__"] = item.background.value;
      }
      item.background.value = highlightBrush.value;
    }
  }

  /// Override this method to implement your own mouse out behavior for items in
  /// the ListBox.
  void onItemMouseLeave(item){
    if (item.stateBag.containsKey("__lb_item_bg_brush__")){
      item.background.value = item.stateBag["__lb_item_bg_brush__"];
    }
  }


  @override void initProperties(){
    super.initProperties();

    highlightBrush = new FrameworkProperty(this, "highlightColor",
      defaultValue: new SolidColorBrush.fromPredefined(Colors.PowderBlue),
      converter:const StringToSolidColorBrushConverter());

    selectBrush = new FrameworkProperty(this, "selectColor",
      defaultValue: new SolidColorBrush.fromPredefined(Colors.SkyBlue),
      converter:const StringToSolidColorBrushConverter());

    selectedItem = new FrameworkProperty(this, "selectedItem");

    presentationPanel = new FrameworkProperty(this, "presentationPanel",
      propertyChangedCallback: (HtmlPlatformElement p){
        assert(p is FrameworkContainer);
        assert(p.containerContent is List);
        if (_presenter == null) return;
        _presenter.presentationPanel.value = p;
      });

    itemsTemplate = new FrameworkProperty(this, "itemsTemplate",
      propertyChangedCallback: (value){
        if (_presenter == null) return;
        _presenter.itemsTemplate.value = value;
      });

    hScroll = new FrameworkProperty(this, 'hScroll',
          defaultValue: ScrollSetting.hidden,
          converter: const StringToScrollSettingConverter());

    vScroll = new FrameworkProperty(this, 'vScroll',
          //TODO: should be ScrollSetting.auto but that doesn't work in
          // some cases.
          defaultValue: ScrollSetting.auto,
          converter: const StringToScrollSettingConverter());
  }
}
