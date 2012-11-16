library checkbox_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* Represents a control that allows the user to select one or more of similar items.
*
* ## Lucaxml Usage Example:
*     <checkbox value="1" groupname="group1"></checkbox>
*/
class CheckBox extends Control
{
  /// Represents the value of the checkbox.
  FrameworkProperty<String> value;
  /// Represents the groupName of the checkbox.
  FrameworkProperty<String> groupName;

  /// Event which fires whenever a selection change occurs on this checkbox.
  final FrameworkEvent selectionChanged = new FrameworkEvent<EventArgs>();

  CheckBox();
  CheckBox.register() : super.register();
  makeMe() => new CheckBox();

  @override void initProperties(){
    super.initProperties();

    value = new FrameworkProperty(this, 'value',
      propertyChangedCallback: (String v){
        rawElement.attributes['value'] = v;
      });

    groupName = new FrameworkProperty(this, 'groupName',
      propertyChangedCallback: (String v){
        rawElement.attributes['name'] = v;
      },
      defaultValue: 'default');
  }

  @override void initEvents(){
    super.initEvents();
    registerEvent('selectionchanged', selectionChanged);
    click + (_, __){
      selectionChanged.invoke(this, new EventArgs());
    };
  }

  @override void createPrimitive(){
    rawElement = new InputElement();
    rawElement.attributes['type'] = 'checkbox';
  }

  /// Gets whether the check box is checked.
  bool get isChecked {
    InputElement inputElement = rawElement as InputElement;

    return inputElement.checked;
  }

  /// Manually sets this checkbox as the selected one of a group.
  void setAsSelected(){
    InputElement inputElement = rawElement as InputElement;

    inputElement.checked = true;
    selectionChanged.invoke(this, new EventArgs());
  }
}
