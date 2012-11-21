library control_html_buckshot;
import 'package:xml/xml.dart';
import 'package:buckshot_html/buckshot_html_browser.dart';

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
* A base class for control-type elements (buttons, etc). */
abstract class Control
  extends BoxModelElement implements HtmlPlatformElement
{
  Element rawElement;
  FrameworkProperty<bool> isEnabled;
  HtmlPlatformElement template;

  /**
   * Required getter for all controls.  Can return one of three values:
   *
   * * Empty String: means the default createElement() method will be used.
   * * String: Expects the string to be a control template.
   * * ControlTemplate: A concrete control template.
   */
  get defaultControlTemplate => '';

  bool _visualTemplateApplied = false;    // flags if visual template applied
  bool _templateApplied = false;          // flags if a template was used during applyVisualTemplate();
  bool _templateBindingsApplied = false;  // flags if template bindings have been applied

  Control();
  Control.register() : super.register();
  @override makeMe() => null;

  @override void initProperties(){
    super.initProperties();

    isEnabled = new FrameworkProperty(this, "isEnabled",
      propertyChangedCallback: (bool value){
        if (value){
          if (rawElement.attributes.containsKey('disabled')) {
            rawElement.attributes.remove('disabled');
          }
        }else{
          rawElement.attributes['disabled'] = 'disabled';
        }
      },
      defaultValue: true,
      converter: const StringToBooleanConverter());
  }

  @override void initEvents(){
    HtmlPlatformElement.initializeBaseEvents(this);
    super.initEvents();
  }

  void applyVisualTemplate(){
    assert(!_visualTemplateApplied && !_templateApplied);
    new Logger('buckshot.pal.html.$this')
      ..fine('applying visual template.');
    _visualTemplateApplied = true;

    if (defaultControlTemplate is ControlTemplate){
      // this allows implementers to pull control templates from
      // resources.
      final tName =
          XML.parse(defaultControlTemplate.rawData).attributes['controlType'];
      assert(tName != null);
      assert(!tName.isEmpty);
      Templates
        .deserialize(defaultControlTemplate.rawData)
        .then((_) => _finishApplyVisualTemplate(tName));
    } else if (defaultControlTemplate is String &&
        !defaultControlTemplate.isEmpty){
      final tName = XML.parse(defaultControlTemplate).attributes['controlType'];
      assert(tName != null);
      assert(!tName.isEmpty);
      Templates
        .deserialize(defaultControlTemplate)
        .then((_) => _finishApplyVisualTemplate(tName));
    }else{
      assert(templateName != null);
      assert(!templateName.isEmpty);
      _finishApplyVisualTemplate('');
    }
  }

  void _finishApplyVisualTemplate(String t){
    if (t.isEmpty){
      template = this;
      super.applyVisualTemplate();
      return;
    }

    final controlTemplate = getResource(t) as ControlTemplate;
    assert(controlTemplate != null);

    _templateApplied = true;

    template = controlTemplate.template.value;

    //log('control template applied: $template', element: this);

    rawElement = template.rawElement;
    template.parent = this;
  }

  @override void onLoaded(){
    if (isLoaded) return;
    super.onLoaded();
    // Returning if we have already done this, or if no template was actually
    // used for this control
    if (_templateBindingsApplied || !_templateApplied) return;
    _templateBindingsApplied = true;
    _bindTemplateBindings();
    _onTemplateLoaded();
  }

  @override void onUnloaded(){
    if (!isLoaded) return;
    super.onUnloaded();
    // Returning if we have already done this, or if no template was actually
    // used for this control
    if (!_templateApplied) return;
    _onTemplateUnloaded();
  }

  // proxies the loaded behavior of a normal element into the template.
  void _onTemplateLoaded(){
    if (template.isLoaded) return;
    template.onLoaded();
    if (template is! FrameworkContainer) return;
    _loadChildren(template as FrameworkContainer);
  }

  // proxies the unloaded behavior of a normal element into the template.
  void _onTemplateUnloaded(){
    if (!template.isLoaded) return;
    template.onUnloaded();
    if (template is! FrameworkContainer) return;
    _unloadChildren(template as FrameworkContainer);
  }

  void _bindTemplateBindings(){
    new Logger('buckshot.pal.html.$this')
      ..fine('binding template bindings');
    var tb = new HashMap<FrameworkProperty, String>();
    _getAllTemplateBindings(tb, template);

    new Logger('buckshot.$this')..fine('*** template bindings: $tb');

    tb.forEach((FrameworkProperty k, String v){
      getPropertyByName(v)
        .then((prop){
          assert(prop != null);
          new Binding(prop, k);
        });
    });
  }

  void _getAllTemplateBindings(bindingMap, element){
    element
      .templateBindings
      .forEach((k, v){
        bindingMap[k] = v;
      });
    if (element is! FrameworkContainer) return;
    if (element.containerContent is List){
      element
        .containerContent
        .forEach((FrameworkObject child) =>
            _getAllTemplateBindings(bindingMap, child));
    }else if (element.containerContent is FrameworkObject){
      _getAllTemplateBindings(bindingMap, element.containerContent);
    }
  }

  /// Gets a standardized name for assignment to the [ControlTemplate] 'controlType' property.
  String get templateName => 'template_${hashCode}';

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

  void _unloadChildren(FrameworkContainer container){
    if (container.containerContent == null) return;

    if (container.containerContent is Collection){
      container.containerContent.forEach((content){
        assert(content is SurfaceElement);
        content.onUnloaded();

        if (content is FrameworkContainer){
          _unloadChildren(content);
        }

      });
    }else if (container.containerContent is SurfaceElement){
      container.containerContent.onUnloaded();
      if (container.containerContent is FrameworkContainer){
        _unloadChildren(container.containerContent);
      }
    }else if (container.containerContent is String){
      // do nothing
    }else{
      new Logger('buckshot.pal.html.control')
        ..warning('Invalid container type found: $container'
            ' ${container.containerContent}');
    }
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
    }else if (container.containerContent is String){
      // do nothing
    }else{
      new Logger('buckshot.pal.html.control')
        ..warning('Invalid container type found: $container'
            ' ${container.containerContent}');
    }
  }
}


/**
* A [FrameworkResource] which represents the initial visual representation of
* a [Control].
*/
class ControlTemplate extends FrameworkResource implements FrameworkContainer
{
  FrameworkProperty<String> controlType;
  FrameworkProperty<FrameworkObject> template;

  ControlTemplate(){
    _initializeControlTemplateProperties();

    //redirect the resource finder to the template property
    //otherwise the ControlTemplate itself would be retrieved as the resource
    this.stateBag[FrameworkObject.CONTAINER_CONTEXT] = template;
  }

  ControlTemplate.register() : super.register();
  makeMe() => new ControlTemplate();

  get containerContent => template.value;

  void _initializeControlTemplateProperties(){
    controlType = new FrameworkProperty(this, "controlType",
        defaultValue:"");

    template = new FrameworkProperty(this, "template");

    //key is not needed, so just shadow copy whatever the controlType is.
    bind(controlType, key);
  }
}

