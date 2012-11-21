library contentpresenter_html_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

class ContentPresenter
  extends SurfaceContentPresenter implements HtmlPlatformElement
{
  final Element rawElement = new DivElement();

  ContentPresenter.register() : super.register();
  ContentPresenter(){
    rawElement.style.overflow = 'hidden';
    rawElement.style.display = '-webkit-flex';
    rawElement.style.boxSizing = 'border-box';
    hitTest.value = HitTestVisibility.none;
  }

  @override makeMe() => new ContentPresenter();


  @override void updateLayout(){
    if (content.value == null) return;
    if (!isLoaded) return;

    HtmlPlatformElement.updateChildAlignment(this);
  }

  @override void initEvents(){
    HtmlPlatformElement.initializeBaseEvents(this);
    super.initEvents();
  }

  /*
   * SurfaceContentPresenter overrides.
   */

  @override void onContentChanged(dynamic newContent){
    assert(newContent == null ||
        newContent is HtmlPlatformElement ||
        newContent is String);

    if (newContent == null){
      rawElement.elements.clear();
      new Logger('buckshot.pal.html.$this')
      ..fine('setting content to null');
      return;
    }

//    if (newContent is HtmlPlatformElement && newContent.isLoaded){
//      throw 'Child already child of another element.';
//    }

    rawElement.elements.clear();

    if (newContent is String){
      new Logger('buckshot.pal.html.$this')
      ..fine('wrapping "$newContent" in TextBlock');
      content.value = new TextBlock()
                            ..text.value = newContent
                            ..hitTest.value = HitTestVisibility.all;
      updateLayout();
      return;
    }

    new Logger('buckshot.pal.html.$this')
    ..fine('setting content to "$newContent"');
    newContent.hitTest.value = HitTestVisibility.all;
    rawElement.elements.add(newContent.rawElement);
    newContent.parent = this;
    updateLayout();
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
