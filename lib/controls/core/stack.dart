library stack_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

class Stack extends SurfaceStack implements HtmlPlatformElement
{
  final Element rawElement = new DivElement();

  Stack.register() : super.register();
  Stack(){
    rawElement.style.overflow = 'hidden';
    rawElement.style.display = '-webkit-flex';
    children.listChanged + onListChanged;
  }

  @override makeMe() => new Stack();

  @override void initEvents(){
    HtmlPlatformElement.initializeBaseEvents(this);
    super.initEvents();
  }

  void onListChanged(_, ListChangedEventArgs args){
    args.oldItems.forEach((child){
      child.rawElement.remove();
      child.parent = null;
    });

    args.newItems.forEach((child){
      rawElement.elements.add(child.rawElement);
      child.parent = this;
      _setChildCrossAxisAlignment(child);
    });
  }

  /**
   * Updates the cross-axis alignments for all children. */
  void _updateChildAlignments(){
    children.forEach((child){
      _setChildCrossAxisAlignment(child);
    });
  }

  void _setChildCrossAxisAlignment(HtmlPlatformElement child){
    final rawChild = child.rawElement as Element;

    if (orientation.value == Orientation.horizontal){
      if (child.vAlign.value == null) return;
      switch(child.vAlign.value){
        case VerticalAlignment.top:
          rawChild.style.setProperty('-webkit-align-self', 'flex-start');
          break;
        case VerticalAlignment.bottom:
          rawChild.style.setProperty('-webkit-align-self', 'flex-end');
          break;
        case VerticalAlignment.center:
          rawChild.style.setProperty('-webkit-align-self', 'center');
          break;
        case VerticalAlignment.stretch:
          rawChild.style.setProperty('-webkit-align-self', 'stretch');
          break;
      }
    }else{
      if (child.hAlign.value == null) return;
      switch(child.hAlign.value){
        case HorizontalAlignment.left:
          rawChild.style.setProperty('-webkit-align-self', 'flex-start');
          break;
        case HorizontalAlignment.right:
          rawChild.style.setProperty('-webkit-align-self', 'flex-end');
          break;
        case HorizontalAlignment.center:
          rawChild.style.setProperty('-webkit-align-self', 'center');
          break;
        case HorizontalAlignment.stretch:
          rawChild.style.setProperty('-webkit-align-self', 'stretch');
          break;
      }
    }
  }

  /*
   * SurfaceStack Overrides
   */

  @override void onOrientationChanged(Orientation value){
    rawElement.style.flexFlow =
      (value == Orientation.vertical) ? 'column' : 'row';

    _updateChildAlignments();
  }

  @override void onBackgroundChanged(Brush brush){
    HtmlPlatformElement.setBackgroundBrush(this, brush);
  }

  /*
   * SurfaceElement Overrides
   */
  @override void onUserSelectChanged(bool value){
      rawElement.style.userSelect = value ? 'all' : 'none';
  }

  @override void onMarginChanged(Thickness value){
    rawElement.style.margin =
        '${value.top}px ${value.right}px ${value.bottom}px ${value.left}px';
  }

  @override void onWidthChanged(num value){
    rawElement.style.width = '${value}px';
  }

  @override void onHeightChanged(num value){
    rawElement.style.height = '${value}px';
  }

  @override void onMaxWidthChanged(num value){
    rawElement.style.maxWidth = '${value}px';
  }

  @override void onMaxHeightChanged(num value){
    rawElement.style.maxHeight = '${value}px';
  }

  @override void onMinWidthChanged(num value){
    rawElement.style.minWidth = '${value}px';
  }

  @override void onMinHeightChanged(num value){
    rawElement.style.minHeight = '${value}px';
  }

  @override void onCursorChanged(Cursors value){
    rawElement.style.cursor = '$value';
  }

  @override void onHAlignChanged(HorizontalAlignment value){
    if (!isLoaded) return;
    parent.updateLayout();
  }

  @override void onVAlignChanged(VerticalAlignment value){
    if (!isLoaded) return;
    parent.updateLayout();
  }

  @override void onZOrderChanged(num value){
    rawElement.style.zIndex = '$value';
  }

  @override void onOpacityChanged(num value){
    rawElement.style.opacity = '$value';
  }

  @override void onVisibilityChanged(Visibility value){
    if (value == Visibility.visible){
      rawElement.style.visibility = '$value';
      rawElement.style.display =
          stateBag["display"] == null ? "inherit" : stateBag["display"];
    }else{
      //preserve in case some element is using "inline"
      //or some other fancy display value
      stateBag["display"] = rawElement.style.display;
      rawElement.style.visibility = '$value';
      rawElement.style.display = "none";
    }
  }

  @override void onDraggableChanged(bool draggable){
    throw new NotImplementedException('todo...');
  }
}
