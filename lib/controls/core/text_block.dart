library textblock_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

class TextBlock extends SurfaceText implements HtmlPlatformElement
{
  final Element rawElement = new ParagraphElement();

  TextBlock(){
    // This setting helps with wrapping in flexbox containers.
    rawElement.style.minWidth = '0px';
    rawElement.style.margin = '0px';
  }

  TextBlock.register() : super.register();
  makeMe() => new TextBlock();

  @override String get namespace => 'http://buckshotui.org/platforms/html';

  @override void initEvents(){
    HtmlPlatformElement.initializeBaseEvents(this);
    super.initEvents();
  }

  /*
   * SurfaceText Overrides
   */
  @override void onFontWeightChanged(String value){
    rawElement.style.fontWeight = '$value';
  }

  @override void onDecorationChanged(String decoration){
    rawElement.style.textDecoration = '$decoration';
  }

  @override void onBackgroundChanged(Brush brush){
    HtmlPlatformElement.setBackgroundBrush(this, brush);
  }

  @override void onForegroundChanged(Color color){
    rawElement.style.color = color.toColorString();
  }

  @override void onTextChanged(text){
    rawElement.text = '$text';
  }

  @override void onFontSizeChanged(num value){
    rawElement.style.fontSize = '${value}px';
  }

  @override void onFontFamilyChanged(String family){
    rawElement.style.fontFamily = '$family';
  }

  /*
   * SurfaceElement Overrides
   */
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
    throw new UnsupportedError('todo...');
  }
}
