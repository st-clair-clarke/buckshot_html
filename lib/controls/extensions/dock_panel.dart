// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library dockpanel_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
part 'src/dock_location.dart';
part 'src/string_to_location.dart';

/**
 * A panel element that supports docking of child elements within it.
 */
class DockPanel extends Control implements FrameworkContainer
{
  static AttachedFrameworkProperty dockProperty;

  FrameworkProperty<bool> fillLast;
  FrameworkProperty<Brush> background;

  final ObservableList<HtmlPlatformElement> children =
      new ObservableList<HtmlPlatformElement>();

  DockPanel()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = children;
  }

  DockPanel.register() : super.register()
  {
    registerAttachedProperty('dockpanel.dock', DockPanel.setDock);
  }
  makeMe() => new DockPanel();

  @override void initEvents(){
    super.initEvents();

    children.listChanged + onChildrenChanging;
  }

  @override void initProperties(){
    super.initProperties();

    fillLast = new FrameworkProperty(this, 'fillLast',
      defaultValue: true,
      converter:const StringToBooleanConverter());

    background = new FrameworkProperty(this, 'background',
        propertyChangedCallback: (Brush brush) {
          HtmlPlatformElement.setBackgroundBrush(this, brush);
        },
        converter: const StringToSolidColorBrushConverter());
  }

  get containerContent => children;

  void onChildrenChanging(sender, ListChangedEventArgs args){
    args.newItems.forEach((item){
      item.parent = this;
    });
    args.oldItems.forEach((item){
      item.parent = null;
    });

    if (!isLoaded) return;
    invalidate();
  }

  @override void createPrimitive(){
    rawElement = new DivElement();
    rawElement.style.overflow = 'hidden';
    rawElement.style.display = '-webkit-flex';
    rawElement.style.boxSizing = 'border-box';
  }

  @override void updateLayout(){
    if (!isLoaded) return;
//    invalidate();
  }

  @override void onFirstLoad(){
    super.onFirstLoad();
    invalidate();
  }

  /**
  * Sets given [DockLocation] value to the Dockpanel.dockProperty
  * for the given [element]. */
  static void setDock(HtmlPlatformElement element, value){
    assert(value is String || value is DockLocation);

    if (element == null) return;

    value = const StringToLocationConverter().convert(value);

    if (DockPanel.dockProperty == null) {
      DockPanel.dockProperty = new AttachedFrameworkProperty("dock",
        (HtmlPlatformElement e, DockLocation l){});
    }

    AttachedFrameworkProperty.setValue(element, dockProperty, value);
  }

  /**
  * Returns the [DockLocation] value currently assigned to the
  * Dockpanel.dockProperty for the given element. */
  static DockLocation getDock(HtmlPlatformElement element){
    if (element == null) return DockLocation.left;

    final value = AttachedFrameworkProperty.getValue(element, dockProperty);

    if (DockPanel.dockProperty == null || value == null) {
      DockPanel.setDock(element, DockLocation.left);
    }

    return AttachedFrameworkProperty.getValue(element, dockProperty);
  }

  /** Invalidates the DockPanel layout and causes it to redraw. */
  void invalidate(){
    new Logger('buckshot.pal.html.$this')
      ..fine('invalidating $this');
    //TODO .removeLast() instead?
    rawElement.elements.clear();

    var currentContainer = rawElement;
    var lastLocation = DockLocation.left;

    children.forEach((child){
      child.parent = this;

      if (currentContainer == rawElement){
        lastLocation = DockPanel.getDock(child);
        final newContainer = _createContainer(lastLocation);
        _addChild(newContainer, child, lastLocation);
        currentContainer.elements.add(newContainer);
        currentContainer = newContainer;
      }else{
        final loc = DockPanel.getDock(child);
        if (loc == lastLocation){
          _addChild(currentContainer, child, lastLocation);
        }else{
          final newContainer = _createContainer(loc);
          _addChild(newContainer, child, loc);
          if ((lastLocation == DockLocation.right ||
              lastLocation == DockLocation.bottom)
              && (currentContainer.elements.length > 0)){
            currentContainer.insertBefore(newContainer,
              currentContainer.elements[0]);
          }else{
            currentContainer.elements.add(newContainer);
          }
          currentContainer = newContainer;
          lastLocation = loc;
        }
      }
    });

    //stretch the last item to fill the remaining space
    if (fillLast.value && !children.isEmpty){
      final child = children.last;
      //stretch the last item to fill the remaining space
      final p = child.rawElement.parent;

      assert(p is Element);
      child.rawElement.style.setProperty('-webkit-flex', '1 1 auto');
      child.rawElement.style.setProperty('-webkit-align-self', 'stretch');
    }
  }

  //makes a flexbox container with correct docking alignment
  Element _createContainer(DockLocation loc){
    final c = new DivElement();
    c.style.display = '-webkit-flex';
    c.style.boxSizing = 'border-box';
    c.style.flexFlow =
        (loc == DockLocation.left || loc == DockLocation.right)
          ? 'row'
          : 'column';

      //set the stretch
      c.style.setProperty('-webkit-flex', '1 1 auto');

      //make container-level adjustments based on the dock location.
      switch(loc.toString()){
        case 'right':
          c.style.setProperty('-webkit-justify-content', 'flex-end');
          break;
        case 'top':
          c.style.setProperty('-webkit-justify-content', 'flex-start');
          c.style.setProperty('-webkit-align-items', 'stretch');
          break;
        case 'bottom':
          c.style.setProperty('-webkit-justify-content', 'flex-end');
          c.style.setProperty('-webkit-align-items', 'stretch');
          break;
      }
      return c;
    }

  // Adds child to container with correct alignment and ordering.
  void _addChild(Element container, HtmlPlatformElement child, DockLocation loc){
    if (loc == DockLocation.top || loc == DockLocation.bottom){
      child.rawElement.style.setProperty('-webkit-flex', 'none');
    }

    if ((loc == DockLocation.right || loc == DockLocation.bottom)
        && (container.elements.length > 0)){
      container.insertBefore(child.rawElement, container.elements[0]);
    }else{
      container.elements.add(child.rawElement);
    }
  }
}
