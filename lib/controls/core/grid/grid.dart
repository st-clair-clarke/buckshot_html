library grid_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
part 'src/column_definition.dart';
part 'src/row_definition.dart';
part 'src/grid_length.dart';
part 'src/grid_layout_definition.dart';
part 'src/_grid_cell.dart';
part 'src/string_to_gridlength.dart';
part 'src/string_to_gridunittype.dart';
part 'src/grid_unit_type.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* A flexible layout container element supporting column/row positioning for child elements.
*
*
* ## Template Example Usage ##
*     <grid>
*         <columndefinitions>
*             <columndefinition width="35"></columndefinition> <!-- A fixed column in pixels -->
*             <columndefinition width="auto"></columndefinition> <!-- Column auto sizes to widest element -->
*             <columndefinition width="*1"></columndefinition> <!-- A weighted portion of available space -->
*             <columndefinition width="*2"></columndefinition> <!-- A weighted portion of available space -->
*         </columndefinitions>
*         <rowdefinitions>
*             <rowdefinition height="35"></rowdefinition> <!-- A fixed row in pixels -->
*             <rowdefinition height="auto"></rowdefinition> <!-- Row auto sizes to widest element -->
*             <rowdefinition height="*1"></rowdefinition> <!-- A weighted portion of available space -->
*             <rowdefinition height="*2"></rowdefinition> <!-- A weighted portion of available space -->
*         </rowdefinitions>
*         <textblock grid.row="2" grid.column="1" text="hello world!"></textblock>
*     </grid>
*
* ## See Also ##
* * [RowDefinition]
* * [ColumnDefinition]
* * [GridUnitType]
* * [GridLength]
*/
class Grid extends Control implements FrameworkContainer
{
  static const String noDirectGridCellExceptionMessage = "GridCell cannot be"
    " added directly to Grid.";

  final ObservableList<HtmlPlatformElement> children =
    new ObservableList<HtmlPlatformElement>();

  final List<_GridCell> _internalChildren = new List<_GridCell>();

  /// Represents a collection of [ColumnDefinition]s.
  FrameworkProperty<ObservableList<ColumnDefinition>> columnDefinitions;
  /// Represents a collection of [RowDefinitions]s.
  FrameworkProperty<ObservableList<RowDefinition>> rowDefinitions;

  FrameworkProperty<Brush> background;

  /// Represents the column assignment of an element within the grid.
  static AttachedFrameworkProperty columnProperty;
  /// Represents the row assignment of an element within the grid.
  static AttachedFrameworkProperty rowProperty;
  /// Represents the column span of an element within the grid.
  static AttachedFrameworkProperty columnSpanProperty;
  /// Represents the row span of an element within the grid.
  static AttachedFrameworkProperty rowSpanProperty;

  Grid()
  {
    if (!reflectionEnabled){
      registerAttachedProperty('grid.column', Grid.setColumn);
      registerAttachedProperty('grid.row', Grid.setRow);
      registerAttachedProperty('grid.columnspan', Grid.setColumnSpan);
      registerAttachedProperty('grid.rowspan', Grid.setRowSpan);
    }

    stateBag[FrameworkObject.CONTAINER_CONTEXT] = children;
  }
  Grid.register() : super.register();
  makeMe() => new Grid();

  // using _internalChildren here keeps tree linkage preserved while
  // we are wrapping virtual containers around the child elements.
  get containerContent => _internalChildren;

  @override initProperties(){
    super.initProperties();

    columnDefinitions = new FrameworkProperty(this, "columnDefinitions",
      propertyChangedCallback: (ObservableList<ColumnDefinition> list){
        _updateColumnLayout(rawElement.getBoundingClientRect().width);
      },
      defaultValue: new ObservableList<ColumnDefinition>());

    rowDefinitions = new FrameworkProperty(this, "rowDefinitions",
      propertyChangedCallback: (ObservableList<RowDefinition> list){
        _updateRowLayout(rawElement.getBoundingClientRect().height);
      },
      defaultValue: new ObservableList<RowDefinition>());

    background = new FrameworkProperty(this, 'background',
      propertyChangedCallback: (Brush brush){
        HtmlPlatformElement.setBackgroundBrush(this, brush);
      },
      converter: const StringToSolidColorBrushConverter());
  }

  @override void createPrimitive(){
    rawElement = new DivElement();
  }

  @override void initEvents(){
    super.initEvents();

    children.listChanged + _onChildrenChanging;

    columnDefinitions.value.listChanged + (_,__) =>
        _updateColumnLayout(rawElement.getBoundingClientRect().width);

    rowDefinitions.value.listChanged + (_,__) =>
        _updateRowLayout(rawElement.getBoundingClientRect().height);

    measurementChanged + (_, MeasurementChangedEventArgs args){
      window.requestAnimationFrame((__) {
        updateLayout();
      });
    };
  }

  void _onChildrenChanging(Object _, ListChangedEventArgs args){
    args.oldItems.forEach((HtmlPlatformElement item){
      final p = item.parent;
      assert(p is _GridCell);
      p.content.value.rawElement.remove();
      p.parent = null;
      p.rawElement.remove();
    });

    args.newItems.forEach((HtmlPlatformElement item){
      final gridCell = new _GridCell();
      gridCell.content.value = item;
      _internalChildren.add(gridCell);
      gridCell.parent = this;
      rawElement.elements.add(gridCell.rawElement);
    });

    updateLayout();
  }

  num _totalLengthOf(List<GridLayoutDefinition> definitions){
    num total = 0;

    definitions.forEach((item){
      total += item._adjustedLength;
    });

    return total;
  }

  /// Overidden [FrameworkObject] method.
  @override void updateLayout(){
    super.updateLayout();
    if (!isLoaded) return;

    htmlPlatform
      .measure(this)
      .then((RectMeasurement r){
        _updateRowLayout(r.height);
        _updateColumnLayout(r.width);
      });
  }

  // Updates the column layout of the Grid based on given [gridWidth]
  void _updateColumnLayout(num gridWidth){
    if (!isLoaded) return;
    if (columnDefinitions.value.length == 0){
      //handle case where no columnDefinitions are set
      //assign all elements to a ghost column that is the same width as the grid
      _internalChildren.forEach((_GridCell child){
        child.margin.value =
            new Thickness.specified(child.margin.value.top, 0, 0, 0);
        child.rawElement.style.width = '${gridWidth}px';
      //  db('width: ${child.rawElement.style.width}', this);
      });

      return;
    }

    num totalPixelValue = 0;
    num totalStarValue = 0;
    ColumnDefinition lastStar = null;

    //initialize values for column types
    columnDefinitions.value.forEach((ColumnDefinition c){
      if (c.width.value.gridUnitType.value == GridUnitType.pixel){
        c._adjustedLength = c.width.value.length.value;
        //summing the total pixels used by fixed column values
        totalPixelValue += c.width.value.length.value;
      }
      else if (c.width.value.gridUnitType.value == GridUnitType.star){
        totalStarValue += c.width.value.length.value; //generating a denominator for later actual width calculation
        lastStar = c;
      }
      else if (c.width.value.gridUnitType.value == GridUnitType.auto){
        num widestAuto = 0;

        //measure the largest child for the current column
        _internalChildren
          .filter((child){
            //children that span outside the column are excluded
            return
                Grid.getColumn(child.content.value) ==
                columnDefinitions.value.indexOf(c, 0) &&
                Grid.getColumnSpan(child.content.value) < 2;
          })
          .forEach((_GridCell child){
            num childWidth =
                child.content.value.rawElement.getBoundingClientRect().width;
            num mOffset = child.content.value.margin.value.left +
                child.content.value.margin.value.right;
            if (childWidth + mOffset > widestAuto) {
              widestAuto = childWidth + mOffset;
            }
          });

        c._adjustedLength = widestAuto;
        totalPixelValue += widestAuto;
      }
    });

    num availColWidth = gridWidth - totalPixelValue;

    //now determine the offsets for each column
    num ii = 0;
    num totalStarLength = 0;
    columnDefinitions.value.forEach((ColumnDefinition c){

      // if star type calculate adjusted length
      if (c.width.value.gridUnitType.value == GridUnitType.star){
        if (identical(c, lastStar)){
          c._adjustedLength = (availColWidth - totalStarLength);
        }
        else{
          c._adjustedLength = ((availColWidth * (c.width.value.length.value / totalStarValue)).round());
          totalStarLength += c._adjustedLength;
        }
      }

      //calculate the offset for each column
      num id = ii - 1;
      c._adjustedOffset = ii == 0
          ? 0
          : columnDefinitions.value[id]._adjustedOffset +
            columnDefinitions.value[id]._adjustedLength;

      ii++;
    });

    //set child wrappers to column offsets
    _internalChildren.forEach((child){
      num colIndex = Grid.getColumn(child.content.value).toInt();

      num childColumnSpan = Grid.getColumnSpan(child.content.value).toInt();

      //child.rawElement.style.left = '${columnDefinitions[colIndex]._adjustedOffset}px';
      child.margin.value =
          new Thickness.specified(child.margin.value.top, 0, 0, columnDefinitions.value[colIndex]._adjustedOffset);

      if (childColumnSpan > 1){
        if (childColumnSpan > columnDefinitions.value.length - colIndex) {
          childColumnSpan = columnDefinitions.value.length - colIndex;
        }
        child.rawElement.style.width = '${_totalLengthOf(columnDefinitions.value.getRange(colIndex, childColumnSpan))}px';
      }else{
        child.rawElement.style.width = '${columnDefinitions.value[colIndex]._adjustedLength}px';
      }
      child.updateLayout();
    });
  }

  // Updates the row layout of the Grid based on the given [gridHeight]
  void _updateRowLayout(num gridHeight){
    if (!isLoaded) return;

    //TODO handle with binding
    if (rowDefinitions.value.length == 0){
      //handle case where no rowDefinitions are set
      //assign all elements to a ghost row that is the same height as the grid

      _internalChildren.forEach((child){
        child.margin.value = new Thickness.specified(0, 0, 0, child.margin.value.left);
        child.rawElement.style.height = '${gridHeight}px';
       // db('height: ${child.rawElement.style.height}', this);
      });

      return;
    }

    num totalPixelValue = 0;
    num totalStarValue = 0;
    RowDefinition lastStar = null;

    //initialize values for rows
    rowDefinitions.value.forEach((RowDefinition c){
      if (c.height.value.gridUnitType.value == GridUnitType.pixel){
        c._adjustedLength = c.height.value.length.value;
        totalPixelValue += c.height.value.length.value;
      }
      else if (c.height.value.gridUnitType.value == GridUnitType.star){
        totalStarValue += c.height.value.length.value;
        lastStar = c;
      }
      else if (c.height.value.gridUnitType.value == GridUnitType.auto){
        num widestAuto = 0;

        //measure the largest child for the current column
        _internalChildren
          .filter((_GridCell child){
            //children that span outside the row are excluded
            return Grid.getRow(child.content.value) == rowDefinitions.value.indexOf(c, 0)
                  && Grid.getRowSpan(child.content.value) < 2;
          })
          .forEach((_GridCell child){
            num childHeight =
              child.content.value.rawElement.getBoundingClientRect().height;
            num mOffset = child.content.value.margin.value.top +
                child.content.value.margin.value.bottom;
            if (childHeight + mOffset > widestAuto) {
              widestAuto = childHeight + mOffset;
            }
          });

        c._adjustedLength = widestAuto;
        totalPixelValue += widestAuto;
      }
    });

    num availRowHeight = gridHeight - totalPixelValue;
    num ii = 0;
    num totalStarLength = 0;
    rowDefinitions.value.forEach((RowDefinition c){

      if (c.height.value.gridUnitType.value == GridUnitType.star){
        if (identical(c, lastStar)){
          c._adjustedLength = (availRowHeight - totalStarLength);
        }else{
          c._adjustedLength = ((availRowHeight * (c.height.value.length.value / totalStarValue)).round());
          totalStarLength += c._adjustedLength;
        }
      }

      //calculate the offset
      num id = ii - 1;
      c._adjustedOffset = ii == 0
          ? 0
          : (rowDefinitions.value[id]._adjustedOffset +
              rowDefinitions.value[id]._adjustedLength);
      ii++;
    });

    //assign child wrappers to row offsets
    _internalChildren.forEach((_GridCell child){
      num rowIndex = Grid.getRow(child.content.value).toInt();
      num childRowSpan = Grid.getRowSpan(child.content.value).toInt();

      //child.rawElement.style.top = '${rowDefinitions[rowIndex]._adjustedOffset}px';
      child.margin.value =
          new Thickness.specified(rowDefinitions.value[rowIndex]._adjustedOffset, 0, 0, child.margin.value.left);

      if (childRowSpan > 1){
        if (childRowSpan > rowDefinitions.value.length - rowIndex) {
          childRowSpan = rowDefinitions.value.length - rowIndex;
        }

        child.rawElement.style.height = '${_totalLengthOf(rowDefinitions.value.getRange(rowIndex, childRowSpan))}px';
      }else{
        child.rawElement.style.height = '${rowDefinitions.value[rowIndex]._adjustedLength}px';
      }

      child.updateLayout();
    });

    //db("row build time: ${_sw.elapsedInMs()}", this);

  }


//attached properties

  /**
  * Attaches a [column] value to the given [element].
  * This will be used later by Grid to layout the element at the correct location. */
  static void setColumn(HtmlPlatformElement element, column){
    if (element == null) return;

    column = const StringToNumericConverter().convert(column);

    if (column < 0) column = 0;

    if (Grid.columnProperty == null){
      Grid.columnProperty = new AttachedFrameworkProperty("column", (HtmlPlatformElement e, num value){
      });
    }

    AttachedFrameworkProperty.setValue(element, columnProperty, column);
  }


  static num getColumn(HtmlPlatformElement element){
    if (element == null) return 0;

    var value = AttachedFrameworkProperty.getValue(element, Grid.columnProperty);

    if (Grid.columnProperty == null || value == null) {
      Grid.setColumn(element, 0);
    }

    return AttachedFrameworkProperty.getValue(element, columnProperty);
  }

  static void setRow(HtmlPlatformElement element, row){
    if (element == null) return;

    assert(row is String || row is num);

    row = const StringToNumericConverter().convert(row);

    if (row < 0) row = 0;

    if (Grid.rowProperty == null){
      Grid.rowProperty = new AttachedFrameworkProperty("row", (HtmlPlatformElement e, num value){

      });
    }

    AttachedFrameworkProperty.setValue(element, rowProperty, row);
  }

  static num getRow(HtmlPlatformElement element){
    if (element == null) return 0;

    var value = AttachedFrameworkProperty.getValue(element, Grid.rowProperty);

    if (Grid.rowProperty == null || value == null) {
      Grid.setRow(element, 0);
    }

    return AttachedFrameworkProperty.getValue(element, rowProperty);
  }

  static void setColumnSpan(HtmlPlatformElement element, columnSpan){
    if (element == null) return;

    assert(columnSpan is String || columnSpan is num);

    columnSpan = const StringToNumericConverter().convert(columnSpan);

    if (columnSpan < 0) columnSpan = 0;

    if (Grid.columnSpanProperty == null){
      Grid.columnSpanProperty = new AttachedFrameworkProperty("columnSpan", (HtmlPlatformElement e, num value){

      });
    }

    AttachedFrameworkProperty.setValue(element, columnSpanProperty, columnSpan);
  }

  static num getColumnSpan(HtmlPlatformElement element){
    if (element == null) return 0;

    var value = AttachedFrameworkProperty.getValue(element, Grid.columnSpanProperty);

    if (Grid.columnSpanProperty == null || value == null) {
      Grid.setColumnSpan(element, 0);
    }

    return AttachedFrameworkProperty.getValue(element, Grid.columnSpanProperty);
  }

  static void setRowSpan(HtmlPlatformElement element, rowSpan){
    if (element == null) return;

    assert(rowSpan is String || rowSpan is num);

    rowSpan = const StringToNumericConverter().convert(rowSpan);

    if (rowSpan < 0) rowSpan = 0;

    if (Grid.rowSpanProperty == null){
      Grid.rowSpanProperty = new AttachedFrameworkProperty("rowSpan", (HtmlPlatformElement e, num value){

      });
    }

    AttachedFrameworkProperty.setValue(element, rowSpanProperty, rowSpan);
  }

  static num getRowSpan(HtmlPlatformElement element){
    if (element == null) return 0;

    var value = AttachedFrameworkProperty.getValue(element, Grid.rowSpanProperty);

    if (Grid.rowSpanProperty == null || value == null) {
      Grid.setRowSpan(element, 0);
    }

    return AttachedFrameworkProperty.getValue(element, rowSpanProperty);
  }
}