part of tabcontrol_control_extensions_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

class TabItem extends Control implements FrameworkContainer
{
  FrameworkProperty<HtmlPlatformElement> header;
  FrameworkProperty<HtmlPlatformElement> icon;
  FrameworkProperty<bool> closeEnabled;
  FrameworkProperty<Visibility> _closeButtonVisiblity;
  FrameworkProperty<dynamic> content;

  HtmlPlatformElement _visualTemplate;

  TabItem(){
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = content;
  }
  TabItem.register() : super.register();
  @override makeMe() => new TabItem();

  @override get containerContent => content.value;

  @override void initProperties(){
    super.initProperties();

    header = new FrameworkProperty(this, 'header');

    icon = new FrameworkProperty(this, 'icon');

    content = new FrameworkProperty(this, 'content',
        propertyChangedCallback:(value){
          assert(value is HtmlPlatformElement);
          assert(value.parent == null);
          value.parent = this;
    });

    _closeButtonVisiblity = new FrameworkProperty(this,
        'closeButtonVisibility',
        propertyChangedCallback: (Visibility value){
          if (value == Visibility.visible
              && closeEnabled.value == false){
            _closeButtonVisiblity.value = Visibility.collapsed;
          }
        },
        defaultValue: Visibility.collapsed,
        converter: const StringToVisibilityConverter());

    closeEnabled = new FrameworkProperty(this, 'closeEnabled',
        propertyChangedCallback: (bool value){
          if (value == false){
            _closeButtonVisiblity.value = Visibility.collapsed;
          }
        },
        defaultValue: true,
        converter: const StringToBooleanConverter());
  }

  @override void createPrimitive(){
    rawElement = new DivElement();
  }

}
