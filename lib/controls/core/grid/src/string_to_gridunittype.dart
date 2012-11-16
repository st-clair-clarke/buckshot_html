part of grid_html_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* Provides a conversion between [String] values and [GridUnitType].
*/
class StringToGridUnitTypeConverter implements ValueConverter{
  dynamic convert(dynamic value, {dynamic parameter}){
    if (!(value is String)) return value;

    switch(value){
    case "star":
      return GridUnitType.star;
    case "pixel":
      return GridUnitType.pixel;
    case "auto":
      return GridUnitType.auto;
    default:
      throw const BuckshotException("Invalid GridUnitType value.");
    }
  }
}
