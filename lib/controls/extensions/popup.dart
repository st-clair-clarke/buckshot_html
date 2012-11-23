library popup_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
 * A popup control that hovers over a given element.
 *
 * Popup ensures that only a single instance of it is visible at any given
 * time.  If another Popup is visible, it will be removed before displaying
 * the current Popup.
 *
 * Popup, much like [ModalDialog] is not meant to be declared directly in
 * templates, but instead initialized and handled in code.
 *
 * Aside from the above, it is up to the developer to manage the logic under
 * which the Popup will open and close.  The examples below demonstrate a basic
 * mechanism whereby clicking on the Popup will close it.
 *
 * See the Sandbox demo for an example of a more complex Popup implementation.
 *
 * ## Examples ##
 * ### A basic Popup ###
 *     // A Popup with no content.
 *     final p = new Popup().show();
 *     p.click(_,__) => p.hide();
 *
 * ### Offset from the window ###
 *     final p = new Popup()
 *        ..offsetX = 50
 *        ..offsetY = 50
 *        ..show();
 *     p.click(_,__) => p.hide();
 *
 * ### Offset relative to another element ###
 *     final p = new Popup()
 *        ..offsetX = 50
 *        ..offsetY = 50
 *        ..show(someOtherElement);
 *     p.click(_,__) => p.hide();
 *
 * ### Providing content to the popup ###
 *     final content = new
 *        View.fromTemplate("<textblock margin='10' text='hello world!' />");
 *
 *     content.ready((_){
 *        final p = new Popup.with(content)
 *           ..offsetX = 50
 *           ..offsetY = 50
 *           ..show(someOtherElement);
 *        p.click(_,__) => p.hide();
 *     });
 *
 */
class Popup extends Control
{
  FrameworkProperty<num> offsetX;
  FrameworkProperty<num> offsetY;
  FrameworkProperty<Brush> background;
  FrameworkProperty<Color> borderColor;
  FrameworkProperty<Thickness> borderThickness;
  FrameworkProperty<Thickness> cornerRadius;
  FrameworkProperty<dynamic> content;

  HtmlPlatformElement _target;
  EventHandlerReference _ref;
  SurfacePoint _currentPos;
  static Popup _currentPopup;

  Popup();
  Popup.with(HtmlPlatformElement popupContent){
    content.value = popupContent;
  }
  Popup.register() : super.register();
  @override makeMe() => new Popup();

  Future show([HtmlPlatformElement target = null]){
    if (_currentPopup != null) _currentPopup.hide();
    new Logger('buckshot.pal.html.$this').fine('showing popup');

    if (target == null || !target.isLoaded){
      new Logger('buckshot.pal.html.$this').fine('... with no target');
      rawElement.style.left = '${offsetX.value}px';
      rawElement.style.top = '${offsetY.value}px';
      onLoaded();
      document.body.elements.add(rawElement);
      _currentPopup = this;
      return new Future.immediate(true);
    }else{
      return htmlPlatform
        .measure(target)
        .chain((RectMeasurement r){
          new Logger('buckshot.pal.html.$this').fine('... with target $target');
          rawElement.style.left = '${offsetX.value + r.left}px';
          rawElement.style.top = '${offsetY.value + r.top}px';
          onLoaded();
          document.body.elements.add(rawElement);
          updateLayout();
          _currentPopup = this;
          return new Future.immediate(true);
        });
    }
  }

  void hide(){
    rawElement.remove();
    _currentPopup = null;
  }

  @override void initProperties(){
    super.initProperties();

    background = new FrameworkProperty(this, 'background',
        defaultValue: getResource('theme_popup_background_brush'),
        converter: const StringToSolidColorBrushConverter());

    borderColor = new FrameworkProperty(this, 'borderColor',
        defaultValue: getResource('theme_popup_border_color',
                                  converter: const StringToColorConverter()),
        converter: const StringToColorConverter());

    borderThickness = new FrameworkProperty(this, 'borderThickness',
        defaultValue: getResource('theme_popup_border_thickness',
                                 converter: const StringToThicknessConverter()),
        converter: const StringToThicknessConverter());

    cornerRadius= new FrameworkProperty(this, 'cornerRadius',
        defaultValue: getResource('theme_popup_corner_radius',
                                 converter: const StringToThicknessConverter()),
        converter: const StringToThicknessConverter());

    content = new FrameworkProperty(this, 'content');

    offsetX = new FrameworkProperty(this, 'offsetX',
        defaultValue: 0,
        converter: const StringToNumericConverter());

    offsetY = new FrameworkProperty(this, 'offsetY',
        defaultValue: 0,
        converter: const StringToNumericConverter());

    // Override the underlying DOM element so that it
    // is absolutely positioned int the window at 0,0
    cursor.value = Cursors.Arrow;
    rawElement.style.position = 'absolute';
    rawElement.style.top = '0px';
    rawElement.style.left = '0px';

  }

  String get defaultControlTemplate {
    return
'''
<controltemplate xmlns='http://buckshotui.org/platforms/html' controlType='${this.templateName}'>
    <border name='__borderRoot__'
            shadowx='{resource theme_popup_shadow_x}'
            shadowy='{resource theme_popup_shadow_y}'
            shadowblur='{resource theme_popup_shadow_blur}'
            zorder='32766'
            minwidth='20'
            minheight='20'
            padding='{resource theme_popup_padding}' 
            cornerRadius='{template cornerRadius}' 
            borderthickness='{template borderThickness}' 
            bordercolor='{template borderColor}' 
            background='{template background}'
            content='{template content}' />
</controltemplate>
''';
  }

}
