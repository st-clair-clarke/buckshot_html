library drop_down_list_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.


/**
* A control for displaying a list of items (and corresponding values) in a drop down pick list.
*/
class DropDownList extends Control
{
  FrameworkProperty<ObservableList<DropDownItem>> items;
  FrameworkProperty<List<String>> itemsSource;
  FrameworkProperty<DropDownItem> selectedItem;
  FrameworkProperty<num> selectedIndex; //TODO implement this property

  FrameworkEvent<SelectedItemChangedEventArgs<DropDownItem>> selectionChanged =
      new FrameworkEvent<SelectedItemChangedEventArgs<DropDownItem>>();

  DropDownList(){
    registerElement(new DropDownItem.register());
  }
  DropDownList.register() : super.register();
  makeMe() => new DropDownList();

  @override void initEvents(){
    super.initEvents();

    registerEvent('selectionchanged', selectionChanged);

    rawElement.on.change.add((e) => doNotify());
  }

  @override void initProperties(){
    super.initProperties();

    items = new FrameworkProperty(this, "items",
        defaultValue:new ObservableList<DropDownItem>());

    itemsSource = new FrameworkProperty(this, "itemsSource",
      propertyChangedCallback:
        (List<String> v){
          _invalidate();
        });

    selectedItem = new FrameworkProperty(this, "selectedItem",
        defaultValue:new DropDownItem());
  }

  void doNotify(){
    DropDownItem selected;
    final el = rawElement as SelectElement;

    if (itemsSource.value != null && !itemsSource.value.isEmpty) {
      selectedItem.value.item.value = itemsSource.value[el.selectedIndex];
      selectedItem.value.value.value = itemsSource.value[el.selectedIndex];
      selected = selectedItem.value;
    }else if (!items.value.isEmpty){
      selected = items.value[el.selectedIndex];
      selectedItem.value.item.value = selected.item.value;
      selectedItem.value.value.value = selected.value.value;
    }

    if (selected != null){
      selectionChanged
      .invokeAsync(this,
          new SelectedItemChangedEventArgs<DropDownItem>(selected));
    }
  }

  @override void onFirstLoad(){
    super.onFirstLoad();

    items.value.listChanged + (_, __) {
      _invalidate();
    };
  }

  @override void onLoaded(){
    super.onLoaded();

    _invalidate();
    doNotify();
  }

  void _invalidate(){
    rawElement.elements.clear();

    if (itemsSource.value != null){
      itemsSource.value.forEach((i){
        var option = new OptionElement();
        option.attributes['value'] = '$i';
        option.text = '$i';
        rawElement.elements.add(option);
      });

    }else{
      items.value.forEach((DropDownItem i){
        var option = new OptionElement();
        option.attributes['value'] = i.value.value;
        option.text = '${i.item.value}';
        rawElement.elements.add(option);
      });
    }
  }

  /// Overridden [FrameworkObject] method for generating the html
  /// representation of the DDL.
  @override void createPrimitive(){
    rawElement = new Element.tag('select');
  }
}


class DropDownItem extends FrameworkObject
{
  FrameworkProperty<dynamic> value;
  FrameworkProperty<String> item;

  DropDownItem();
  DropDownItem.register() : super.register();
  makeMe() => new DropDownItem();

  @override void initProperties(){
    super.initProperties();

    item = new FrameworkProperty(this, 'item');
    value = new FrameworkProperty(this, 'value');
  }
}