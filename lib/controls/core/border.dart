library border_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

class Border extends SurfaceBorder implements HtmlPlatformElement
{
  final Element rawElement = new DivElement();
  Border.register() : super.register();
  Border(){
    rawElement.style.overflow = 'hidden';
    rawElement.style.display = '-webkit-flex';
    rawElement.style.boxSizing = 'border-box';
  }

  @override makeMe() => new Border();

  get containerContent => content.value;

  @override void initEvents(){
    HtmlPlatformElement.initializeBaseEvents(this);
    super.initEvents();
  }

  @override void updateLayout(){
    if (content.value == null) return;
    if (!isLoaded) return;

    HtmlPlatformElement.updateChildAlignment(this);
  }

  @override void onBackgroundChanged(Brush brush){
    HtmlPlatformElement.setBackgroundBrush(this, brush);
  }

  @override void onCornerRadiusChanged(Thickness value){
    rawElement.style.borderRadius =
        '${value.top}px ${value.right}px ${value.bottom}px ${value.left}px';
  }

  @override void onPaddingChanged(Thickness value){
    rawElement.style.padding =
        '${value.top}px ${value.right}px ${value.bottom}px ${value.left}px';
  }

  @override void onBorderStyleChanged(BorderStyle style){
    rawElement.style.borderStyle = '$style';
  }

  @override void onContentChanged(dynamic newChild){
    assert(newChild is HtmlPlatformElement);

    if (newChild == null){
      rawElement.elements.clear();
      return;
    }
//    if (newChild.isLoaded){
//      throw 'Child already child of another element.';
//    }
    rawElement.elements.clear();
    newChild.parent = this;
    rawElement.elements.add(newChild.rawElement);
    updateLayout();
  }

  @override void onBorderThicknessChanged(Thickness value){
    rawElement.style.borderWidth =
        '${value.top}px ${value.right}px ${value.bottom}px ${value.left}px';
  }

  @override void onBorderColorChanged(Color color){
    rawElement.style.borderColor = color.toColorString();
  }

  @override void onHitTestVisibilityChanged(HitTestVisibility value){
    rawElement.style.pointerEvents = '$value';
  }

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
    new Logger('buckshot.pal.html.$this').fine('visibility changing $value');
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

