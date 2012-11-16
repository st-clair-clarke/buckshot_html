// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

part of sandbox_buckshot;

class DemoModel {
  // This list of data is build statically using data templates, but image how easy it would be
  // to query some data source and build up a list just like this...
  final List<DataTemplate> videoList = [
    new DataTemplate.fromMap({"Title":"Buckshot Templates",  "Description":"The Buckshot Template System.", "Hash":"LOacOkmd9FI"}),
    new DataTemplate.fromMap({"Title":"Buckshot Resources",          "Description":"An overview of Buckshot Resource Binding.",   "Hash":"cFxf3OBIj8Q"}),
    new DataTemplate.fromMap({"Title":"Buckshot Element Binding",    "Description":"An overview of Buckshot Element Binding.",    "Hash":"WC25C5AHYAI"}),
    new DataTemplate.fromMap({"Title":"Buckshot Control Templates",  "Description":"An overview of Buckshot Control Templates and Template Binding","Hash":"KRGvdID4rPE"})
    ];

  final List<DataTemplate> iconList = [
    new DataTemplate.fromMap({'Name':'Certificate', 'Description':'Image of a certificate document.',         'Uri':'http://www.lucastudios.com/Content/images/Certificate64.png'}),
    new DataTemplate.fromMap({'Name':'Chart',       'Description':'Represents a chart of information.',       'Uri':'http://www.lucastudios.com/Content/images/ChartGantt64.png'}),
    new DataTemplate.fromMap({'Name':'Connected',   'Description':'Represents an active connection.',         'Uri':'http://www.lucastudios.com/Content/images/Connected64.png'}),
    new DataTemplate.fromMap({'Name':'Mail Box',    'Description':'Snail Mail!',                              'Uri':'http://www.lucastudios.com/Content/images/MailBox64.png'}),
    new DataTemplate.fromMap({'Name':'Node',        'Description':'Represents a node object.',                'Uri':'http://www.lucastudios.com/Content/images/Node24.png'}),
    new DataTemplate.fromMap({'Name':'Telephone',   'Description':'Image of an old school telephone.',        'Uri':'http://www.lucastudios.com/Content/images/Telephone64.png'}),
    new DataTemplate.fromMap({'Name':'Windows',     'Description':'Represents windows in a user interface.',  'Uri':'http://www.lucastudios.com/Content/images/WindowTriPaneSearch64.png'})
    ];

  final List<String> fruitList = const ["apple","pear","grape","orange","tomato"];

  final SomeColors colorClass = new SomeColors();
}


/**
 * A demo Buckshot object to demonstrate the dot notation resolver for
 * properties.
 */
class SomeColors extends FrameworkObject
{
  FrameworkProperty<String> redProperty;
  FrameworkProperty<String> orangeProperty;
  FrameworkProperty<String> blueProperty;

  @override makeMe() => null;

  @override initProperties(){
    super.initProperties();
    redProperty = new FrameworkProperty(this, "red", defaultValue:"Red");
    orangeProperty = new FrameworkProperty(this, "orange", defaultValue:"Orange");
    blueProperty = new FrameworkProperty(this, "blue", defaultValue:"Blue");
  }
}