// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library modaldialog_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

/**
* Displays a general purpose modal dialog and returns results.
*
* ## Not Used In Templates ##
* ModalDialog is a activated and handled in code.  It's title and body content
* areas can be templates or simple strings.
*
* ## Examples ##
* ### A very basic dialog with textual title and body. ###
*     new ModalDialog
*        .with('Title', 'body', ModalDialog.Ok)
*        .show();
*
* ### Determining Button Clicked ###
*     new ModalDialog
*        .with('Title', 'body', ModalDialog.OkCancel)
*        .show() // .show() returns a Future with the button clicked.
*        .then((DialogButtonType b){
*           print('You clicked the "$b" button.');
*        });
*
* ### Using Templates For Title and Body ###
*     // ModalDialog supports arbitrary content in the title and body.
*
*     final title = new View.fromTemplate('<textblock text="title" />');
*     final body = new View.fromTemplate('<border width="30" height="30"'
*        ' background="Orange" />');
*
*     Futures
*        .wait([title.ready, body.ready]) //make sure the views are ready
*        .then((views){
*           new ModalDialog
*              .with(title.rootVisual, body.rootVisual, ModalDialog.OKCancel)
*              .show();
*        });
*
*  ### Setting Other Properties ###
*      new ModalDialog
*         .with('Title', 'Body', ModalDialog.YesNo)
*         ..cornerRadius = 7
*         ..borderThickness = new Thickness(3)
*         ..maskOpacity = 0.5
*         ..maskColor = new SolidColorBrush(new Color.predefined(Colors.Blue))
*         ..background = new SolidColorBrush(new Color.predefined(Colors.Yellow))
*         ..show();
*/
class ModalDialog extends Control
{
  FrameworkProperty<Brush> background;
  FrameworkProperty<Color> borderColor;
  FrameworkProperty<Thickness> borderThickness;
  FrameworkProperty<Thickness> cornerRadius;
  FrameworkProperty<Brush> maskBrush;
  FrameworkProperty<num> maskOpacity;
  FrameworkProperty<dynamic> title;
  FrameworkProperty<dynamic> body;
  Binding b1, b2;
  Border bDialog;
  Grid cvRoot;

  static const List<DialogButtonType> Ok =
      const [DialogButtonType.OK];

  static const List<DialogButtonType> OkCancel =
      const [DialogButtonType.OK,
             DialogButtonType.CANCEL];

  static const List<DialogButtonType> YesNo =
      const [DialogButtonType.YES,
             DialogButtonType.NO];

  static const List<DialogButtonType> BackNext =
      const [DialogButtonType.BACK,
             DialogButtonType.NEXT];

  static const List<DialogButtonType> BackNextCancel =
      const [DialogButtonType.BACK,
             DialogButtonType.NEXT,
             DialogButtonType.CANCEL];

  static const List<DialogButtonType> BackNextFinished =
      const [DialogButtonType.BACK,
             DialogButtonType.NEXT,
             DialogButtonType.FINISHED];

  static const List<DialogButtonType> NextFinished =
      const [DialogButtonType.NEXT,
             DialogButtonType.FINISHED];

  static const List<DialogButtonType> Next =
      const [DialogButtonType.NEXT];

  static const List<DialogButtonType> Back =
      const [DialogButtonType.BACK];

  static const List<DialogButtonType> Cancel =
      const [DialogButtonType.CANCEL];

  Completer _dialogCompleter;

  ModalDialog();
  ModalDialog.register() : super.register();
  makeMe() => new ModalDialog();

  ModalDialog.with(titleContent, bodyContent, List<DialogButtonType> buttons)
      : super()
  {
    _initButtons(buttons);
    title.value = titleContent;
    body.value = bodyContent;
  }


  /**
   * Displays the [ModalDialog] and returns a Future that completes when
   * one of the dialog buttons is clicked.
   */
  Future<DialogButtonType> show(){
    new Logger('buckshot.pal.html')..info('Showing ModalDialog');
    _dialogCompleter = new Completer<DialogButtonType>();

    b1 = bind(htmlPlatform.viewportWidth, cvRoot.width);
    b2 = bind(htmlPlatform.viewportHeight, cvRoot.height);

    cvRoot.width.value = window.innerWidth;
    cvRoot.height.value = window.innerHeight;

    document.body.elements.add(cvRoot.rawElement);
    // manually trigger loaded state since we aren't adding this
    // to the visual tree using the API...
    onLoaded();
    cvRoot.onLoaded();
    assert(cvRoot.isLoaded);
    _loadChildren(cvRoot);

//    htmlPresenter.workers['__modal_watcher__'] = (_){
//      cvRoot.rawElement.style.top = '0px';
//      cvRoot.rawElement.style.left = '0px';
//    };

    return _dialogCompleter.future;
  }

  void setButtons(List<DialogButtonType> buttons){
    _initButtons(buttons);
  }

  void buttonClick_handler(sender, args){
    final b = sender as Button;
//    htmlPresenter.workers.remove('__modal_watcher__');
    b1.unregister();
    b2.unregister();
    this.rawElement.remove();
    onUnloaded();

    _dialogCompleter.complete(DialogButtonType.fromString(b.content.value));
  }

  void _initButtons(List buttons){
    final buttonsContainer =
        Templates.findByName('spButtonContainer', template) as Stack;

    for (final Button b in buttonsContainer.children){
      if (buttons.some((tb) => tb.toString() == b.content.value.toLowerCase())){
        b.visibility.value = Visibility.visible;
        b.tag.value = b.click + buttonClick_handler;
      }else{
        b.visibility.value = Visibility.collapsed;
        if (b.tag.value != null){
          b.click - (b.tag.value as EventHandlerReference);
          b.tag.value = null;
        }
      }
    }
  }

  @override void initProperties(){
    super.initProperties();

    title = new FrameworkProperty(this, 'title',
        defaultValue:'undefined');

    body = new FrameworkProperty(this, 'body',
        defaultValue:'undefined');

    background = new FrameworkProperty(this, 'background',
        defaultValue: getResource('theme_dark_brush'),
        converter: const StringToSolidColorBrushConverter());

    maskBrush = new FrameworkProperty(this, 'maskBrush',
        defaultValue: new SolidColorBrush.fromPredefined(Colors.Gray),
        converter: const StringToSolidColorBrushConverter());

    maskOpacity = new FrameworkProperty(this, 'maskOpacity',
        defaultValue: 0.5,
        converter: const StringToNumericConverter());

    borderColor = new FrameworkProperty(this, 'borderColor',
        defaultValue: getResource('theme_border_color_dark'),
        converter: const StringToColorConverter());

    borderThickness = new FrameworkProperty(this, 'borderThickness',
        defaultValue: getResource('theme_border_thickness',
                                converter: const StringToThicknessConverter()),
        converter: const StringToThicknessConverter());

    cornerRadius = new FrameworkProperty(this, 'cornerRadius',
        defaultValue: getResource('theme_border_corner_radius',
            converter: const StringToThicknessConverter()),
        converter: const StringToThicknessConverter());

    cvRoot = Templates.findByName('cvRoot', template);
    assert(cvRoot != null);
    assert(cvRoot is Grid);
    // Override the underlying DOM element on this canvas so that it
    // is absolutely positioned int the window at 0,0
    cvRoot.rawElement.style.position = 'absolute';
    cvRoot.rawElement.style.top = '0px';
    cvRoot.rawElement.style.left = '0px';
  }

  String get defaultControlTemplate {
    return
        '''
<controltemplate xmlns='http://buckshotui.org/platforms/html' controlType='${this.templateName}'>
 <template>
  <grid name='cvRoot' zorder='32766'>
    <rowdefinitions>
      <rowdefinition height='*' />
    </rowdefinitions>
    <columndefinitions>
      <columndefinition width='*' />
    </columndefinitions>
    <border halign='stretch'
            valign='stretch'
            background='{template maskBrush}'
            opacity='{template maskOpacity}' />
    <border shadowx='3'
            shadowy='3'
            shadowblur='6'
            minwidth='200'
            halign='center' 
            valign='center' 
            padding='5'
            cornerRadius='{template cornerRadius}'
            borderthickness='{template borderThickness}' 
            bordercolor='{template borderColor}' 
            background='{template background}'>
      <stack minwidth='200' maxwidth='500'>
        <contentpresenter content='{template title}' halign='center' />
        <contentpresenter halign='center' content='{template body}' />
        <stack name='spButtonContainer' halign='right' orientation='horizontal'>
          <button content='Ok' />
          <button content='Cancel' />
          <button content='Yes' />
          <button content='No'/>
          <button content='Back' />
          <button content='Next' />
          <button content='Finished' />
        </stack>
      </stack>
    </border>
  </grid>
 </template>
</controltemplate>
        ''';
  }

  void _loadChildren(FrameworkContainer container){
    if (container.containerContent == null) return;

    if (container.containerContent is Collection){
      container.containerContent.forEach((content){
        if(content is! SurfaceElement) {
          // likely a text node of a textblock.
          assert(content is String);
          return;
        }
        content.onLoaded();

        if (content is FrameworkContainer){
          _loadChildren(content);
        }

      });
    }else if (container.containerContent is SurfaceElement){
      container.containerContent.onLoaded();
      if (container.containerContent is FrameworkContainer){
        _loadChildren(container.containerContent);
      }
    }else{
//      log('Invalid container type found: $container'
//          ' ${container.containerContent}');
    }
  }
}


class DialogButtonType
{
  final String _str;

  const DialogButtonType(this._str);

  static const OK = const DialogButtonType('ok');
  static const CANCEL = const DialogButtonType('cancel');
  static const YES = const DialogButtonType('yes');
  static const NO = const DialogButtonType('no');
  static const NEXT = const DialogButtonType('next');
  static const BACK = const DialogButtonType('back');
  static const FINISHED = const DialogButtonType('finished');

  String toString() => _str;

  static DialogButtonType fromString(String name){
    switch(name.toLowerCase()){
      case 'ok':
        return DialogButtonType.OK;
      case 'cancel':
        return DialogButtonType.CANCEL;
      case 'yes':
        return DialogButtonType.YES;
      case 'no':
        return DialogButtonType.NO;
      case 'next':
        return DialogButtonType.NEXT;
      case 'back':
        return DialogButtonType.BACK;
      case 'finished':
        return DialogButtonType.FINISHED;
      default:
        throw new Exception('Unable to match $name to a DialogButtonType');
    }
  }

}