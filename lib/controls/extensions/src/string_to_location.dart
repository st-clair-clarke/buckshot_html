part of dockpanel_control_extensions_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* Converts from [String] to [Location] value.
*/
class StringToLocationConverter implements ValueConverter {
  const StringToLocationConverter();

  dynamic convert(dynamic value, {dynamic parameter}){
    if (value is! String) return value;

    switch(value.toLowerCase()){
      case 'left':
        return DockLocation.left;
      case 'right':
        return DockLocation.right;
      case 'top':
        return DockLocation.top;
      case 'bottom':
        return DockLocation.bottom;
      default:
        throw const BuckshotException("Invalid Location value given.");
    }
  }
}
