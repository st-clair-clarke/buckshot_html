// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library treeview_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';

part 'src/tree_node.dart';

/**
* Displays a heirachical list of [TreeNode] elements.
*/
class TreeView extends Control implements FrameworkContainer
{
  static const String INDICATOR_COLLAPSED = '\u{25b7}';
  static const String INDICATOR_EXPANDED = '\u{25e2}';

  static const String FILE_DEFAULT_TEMPLATE =
      '''
<border hittest='none' width='16' height='16' cornerradius='2' borderthickness='1' bordercolor='{resource theme_border_color_dark}' background='{resource theme_dark_brush}'>
  <stack halign='stretch' valign='center'>
    <border margin='2,1' borderthickness='1' bordercolor='LightGray' halign='stretch' />
    <border margin='3,1' borderthickness='1' bordercolor='LightGray' halign='stretch' />
    <border margin='2,1' borderthickness='1' bordercolor='LightGray' halign='stretch' />
  </stack>
</border>
''';

  static const String FOLDER_DEFAULT_TEMPLATE =
      '''
<layoutcanvas hitest='none' width='16' height='16'>
  <border width='16' height='14' layoutcanvas.top='1' cornerradius='2' borderthickness='1' bordercolor='{resource theme_border_color_dark}' background='{resource theme_dark_brush}' />
  <border layoutcanvas.left='10' width='6' height='14' cornerradius='2' borderthickness='1' bordercolor='{resource theme_border_color_dark}' background='{resource theme_dark_brush}' />
  <border layoutcanvas.top='5' height='10' width='16' cornerradius='2' borderthickness='1' bordercolor='{resource theme_border_color_dark}' background='{resource theme_dark_brush}' />
</layoutcanvas>
''';

  StyleTemplate mouseEnterBorderStyle;
  StyleTemplate mouseLeaveBorderStyle;
  StyleTemplate mouseDownBorderStyle;
  StyleTemplate mouseUpBorderStyle;

  FrameworkProperty<num> indent;
  FrameworkProperty<Thickness> borderThickness;
  FrameworkProperty<Color> borderColor;
  FrameworkProperty<TreeNode> selectedNode;
  FrameworkProperty<Brush> background;

  /// Event which fires when a node is selected in the TreeView.
  final FrameworkEvent<TreeNodeSelectedEventArgs> treeNodeSelected =
      new FrameworkEvent<TreeNodeSelectedEventArgs>();

  final ObservableList<TreeNode> children =
      new ObservableList<TreeNode>();

  TreeView()
  {
    _initStyleTemplates();
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = children;
//    background.value = getResource('theme_light_brush');
    children.listChanged + onChildrenChanging;
  }
  TreeView.register() : super.register(){
    registerElement(new TreeNode.register());
  }
  @override makeMe() => new TreeView();

  @override get containerContent => children;

  /** Selects a [node] as the active node. */
  void selectNode(TreeNode node) => _onTreeNodeSelected(node);

  /** Clears the selected node. */
  void clearSelectedNode(){
    if (selectedNode.value == null) return;
    new Logger('buckshot.pal.html.$this')
    ..fine('clearing selected node ${selectedNode.value}');
    selectedNode.value._mouseEventStyles.value = mouseLeaveBorderStyle;
    selectedNode.value == null;
  }

  @override void initEvents(){
    super.initEvents();
    registerEvent('treenodeselected', treeNodeSelected);
  }

  @override void initProperties(){
    super.initProperties();

    cursor.value = Cursors.Arrow;

    selectedNode = new FrameworkProperty(this, 'selectedNode');

    indent = new FrameworkProperty(this, 'indent',
      propertyChangedCallback: (_) => updateLayout(),
      defaultValue: 10,
      converter:const StringToNumericConverter());

    borderColor = new AnimatingFrameworkProperty(
      this,
      "borderColor",
      'border',
      propertyChangedCallback: (Color value){
        rawElement.style.borderColor = '$value';
      },
      defaultValue: getResource('theme_background_light'),
      converter:const StringToColorConverter());

    borderThickness = new FrameworkProperty(
      this,
      "borderThickness",
      propertyChangedCallback:
        (value){

        String color = borderColor.value != null
            ? rawElement.style.borderColor
            : '${getResource('theme_background_light')}';

        //TODO support border hatch styles
        rawElement.style.borderTop = 'solid ${value.top}px $color';
        rawElement.style.borderRight = 'solid ${value.right}px $color';
        rawElement.style.borderLeft = 'solid ${value.left}px $color';
        rawElement.style.borderBottom = 'solid ${value.bottom}px $color';

      },
      defaultValue:new Thickness(0),
      converter:const StringToThicknessConverter());
  }

  void onChildrenChanging(sender, ListChangedEventArgs args){
    args.newItems.forEach((TreeNode node){
      assert(node is TreeNode);
      node.parent = this;
      node._parentTreeView = this;
      rawElement.elements.add(node.rawElement);
    });

    args.oldItems.forEach((TreeNode node){
      node.parent = null;
    });
  }

  @override void createPrimitive(){
    rawElement = new DivElement();
    rawElement.style.overflowX = "auto";
    rawElement.style.overflowY = "auto";
  }

  void _onTreeNodeSelected(TreeNode node){
    clearSelectedNode();

    selectedNode.value = node;
    selectedNode.value._mouseEventStyles.value = mouseUpBorderStyle;
    treeNodeSelected.invokeAsync(this, new TreeNodeSelectedEventArgs(node));
    new Logger('buckshot.pal.html.$this')
    ..fine('node selected: ${selectedNode.value}');
  }

  void _initStyleTemplates(){
    Template
      .deserialize('''
<resourcecollection>
  <styletemplate key="__TreeView_mouse_enter_style_template__">
    <setters>
      <setter property="background" value="{resource theme_dark_brush}" />
      <setter property="borderColor" value="{resource theme_border_color}" />
    </setters>
  </styletemplate>

  <styletemplate key="__TreeView_mouse_leave_style_template__">
    <setters>
      <setter property="background" value="{resource theme_light_brush}" />
      <setter property="borderColor" value="{resource theme_background_light}" />
    </setters>
  </styletemplate>

  <styletemplate key="__TreeView_mouse_down_style_template__">
    <setters>
      <setter property="background" value="{resource theme_dark_brush}" />
      <setter property="borderColor" value="{resource theme_border_color}" />
    </setters>
  </styletemplate>

  <styletemplate key="__TreeView_mouse_up_style_template__">
    <setters>
      <setter property="background" value="{resource theme_dark_brush}" />
      <setter property="borderColor" value="{resource theme_border_color}" />
    </setters>
  </styletemplate>
</resourcecollection>
  ''')
      .then((_){
        mouseEnterBorderStyle = getResource('__TreeView_mouse_enter_style_template__');
        mouseLeaveBorderStyle = getResource('__TreeView_mouse_leave_style_template__');
        mouseDownBorderStyle = getResource('__TreeView_mouse_down_style_template__');
        mouseUpBorderStyle = getResource('__TreeView_mouse_up_style_template__');
      });
  }
}

class TreeNodeSelectedEventArgs extends EventArgs{
  final TreeNode node;

  TreeNodeSelectedEventArgs(this.node);
}

