part of grid_html_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.
/**
* Base class for Grid row/column definition types.
*
* ## See Also
* * [ColumnDefinition]
* * [RowDefinition]
*/
class GridLayoutDefinition extends FrameworkObject
{

  num _adjustedLengthInternal = 0;
  Node _htmlNode;

  GridLength _gridLength;
  num _adjustedOffset = 0;

  GridLayoutDefinition();
  GridLayoutDefinition.register() : super.register();
  makeMe() => null;

  set _adjustedLength(num value){
    if (value < minLength) value = minLength;
    if (value > maxLength) value = maxLength;

    _adjustedLengthInternal = value;
  }
  num get _adjustedLength => _adjustedLengthInternal;

  num maxLength = 32767; //why not? ;)
  num minLength = 0;
}