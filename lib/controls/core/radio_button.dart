library radio_button_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* A button that only allows a single selection when part of the same group. */
class RadioButton extends Control
{
  /// Represents the value of the radio button.
  FrameworkProperty<String> value;
  /// Represents the groupName of the radio button.
  FrameworkProperty<String> groupName;

  /// Event which fires whenever a selection change occurs on this radio button.
  final FrameworkEvent selectionChanged = new FrameworkEvent<EventArgs>();

  RadioButton();
  RadioButton.register() : super.register();
  makeMe() => new RadioButton();

  @override void initProperties(){
    super.initProperties();

    value = new FrameworkProperty(this, 'value',
      propertyChangedCallback: (String v){
        rawElement.attributes['value'] = v;
      });

    groupName = new FrameworkProperty(this, 'groupName',
      propertyChangedCallback: (String v){
        rawElement.attributes['name'] =  v;
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

  /// Gets whether the check box is checked.
  bool get isChecked {
    InputElement inputElement = rawElement as InputElement;

    return inputElement.checked;
  }

  @override void createPrimitive(){
    rawElement = new InputElement();
    rawElement.attributes['type'] = 'radio';
  }

  /// Manually sets this radio button as the selected one of a group.
  void setAsSelected(){
    InputElement inputElement = rawElement as InputElement;

    inputElement.checked = true;
    selectionChanged.invoke(this, new EventArgs());
  }
}


/**
* A helper class for managing a group of [RadioButton]s.  Does not itself
* provide any rendering capability. */
class RadioButtonGroup
{
  final Map<RadioButton, EventHandlerReference> radioButtonList =
      new Map<RadioButton, EventHandlerReference>();
  final FrameworkEvent<RadioButtonSelectionChangedEventArgs> selectionChanged =
      new FrameworkEvent<RadioButtonSelectionChangedEventArgs>();

  RadioButton currentSelectedButton;

  /**
   * Add a RadioButton to the list.
   * Must be of same grouping as previously added buttons.
   * */
  void addRadioButton(RadioButton buttonToAdd){
    if (buttonToAdd == null) return;

    if (radioButtonList.containsKey(buttonToAdd)){
      throw const BuckshotException("RadioButton already exists in the"
          " RadioButtonGroup list.");
    }

    if (!radioButtonList.isEmpty){
      //do a check to ensure groupName is the same
      String gName = radioButtonList.keys.iterator().next().groupName.value;
      if (gName != buttonToAdd.groupName.value) {
        throw new BuckshotException("Attempted to add RadioButton with"
          " groupName='${buttonToAdd.groupName.value}' to RadioButtonGroup"
          " with groupName='$gName'");
      }
    }

    //register to the selection event of the button
    EventHandlerReference ref = buttonToAdd.selectionChanged + (button, __){
      currentSelectedButton = button;
      this.selectionChanged.invoke(this,
          new RadioButtonSelectionChangedEventArgs(button));
    };

    //add the button to the list
    radioButtonList[buttonToAdd] = ref;

  }

  /** Remove a RadioButton from the list. */
  void removeRadioButton(RadioButton buttonToRemove){
    if (buttonToRemove == null) return;

    if (radioButtonList.containsKey(buttonToRemove)){
      //remove the event reference
      buttonToRemove.selectionChanged - radioButtonList[buttonToRemove];

      //remove the button
      radioButtonList.remove(buttonToRemove);
    }
  }
}

class RadioButtonSelectionChangedEventArgs extends EventArgs{
  final RadioButton selectedRadioButton;

  RadioButtonSelectionChangedEventArgs(this.selectedRadioButton);

}
