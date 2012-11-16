part of treeview_control_extensions_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

/**
 * Represents a node in a [TreeView] structure.
 */
class TreeNode extends Control implements FrameworkContainer
{
  bool _mouseStylesSet = false;
  TreeView _parentTreeView;
  TreeNode _parentNode = null;

  FrameworkProperty<dynamic> header;
  FrameworkProperty<HtmlPlatformElement> icon;
  FrameworkProperty<HtmlPlatformElement> folderIcon;
  FrameworkProperty<HtmlPlatformElement> fileIcon;
  FrameworkProperty<ObservableList<TreeNode>> childNodes;
  FrameworkProperty<dynamic> indicator;
  FrameworkProperty<Visibility> childVisibility;
  FrameworkProperty<StyleTemplate> _mouseEventStyles;

  TreeNode()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = childNodes.value;
  }
  TreeNode.register() : super.register();
  @override makeMe() => new TreeNode();

  void onFirstLoad(){
    super.onFirstLoad();
    _parentTreeView = Template.findParentByType(this, 'TreeView') as TreeView;
    assert(_parentTreeView != null);
    new Logger('buckshot.pal.html.$this')
      ..fine('Finding parent tree view');
    updateIndicator();
  }

  var _lastWasEmpty = false;

  void updateIndicator(){
    new Logger('buckshot.pal.html.$this')
    ..fine('Update Node Indicator');

    if (childNodes.value.isEmpty){
      if (_lastWasEmpty) return;
      indicator.value = '';
      icon.value = fileIcon.value;
      _lastWasEmpty = true;
      new Logger('buckshot.pal.html.$this')
        ..fine('child nodes now empty.');
    }else{
      indicator.value = childVisibility.value == Visibility.visible
          ? TreeView.INDICATOR_EXPANDED
          : TreeView.INDICATOR_COLLAPSED;
      icon.value = folderIcon.value;
      _lastWasEmpty = false;
      new Logger('buckshot.pal.html.$this')
        ..fine('toggling expand/collapse indicator');
    }
  }

  @override void initEvents(){
    super.initEvents();

    new Logger('buckshot.pal.html.$this')
      ..fine('Initializing control.');
    // Toggle visibility of child nodes when clicked.
    (Template
      .findByName('__tree_node_indicator__', template) as ContentPresenter)
      .click + (_, __){
        new Logger('buckshot.pal.html.$this')
          ..fine('Toggling visibility of child nodes for $this');
        childVisibility.value = childVisibility.value == Visibility.visible
            ? Visibility.collapsed
            : Visibility.visible;
        updateIndicator();
      };

    final rowElement = Template.findByName('__tree_node_header__', template);
    assert(rowElement is Border);

    rowElement.mouseEnter + (_, __){
      if (_parentTreeView.selectedNode.value == this) return;
      new Logger('buckshot.pal.html.$this')
      ..fine('firing mouse enter event');
      _mouseEventStyles.value = _parentTreeView.mouseEnterBorderStyle;
    };

    rowElement.mouseLeave + (_, __){
      if (_parentTreeView.selectedNode.value == this) return;
      new Logger('buckshot.pal.html.$this')
      ..fine('firing mouse leave event');
      _mouseEventStyles.value = _parentTreeView.mouseLeaveBorderStyle;
    };

    rowElement.mouseDown + (_, __){
      if (_parentTreeView.selectedNode.value == this) return;
      new Logger('buckshot.pal.html.$this')
      ..fine('firing mouse down event');
      _mouseEventStyles.value = _parentTreeView.mouseDownBorderStyle;
    };

    rowElement.mouseUp + (_, __){
      if (_parentTreeView.selectedNode.value == this) return;
      new Logger('buckshot.pal.html.$this')
      ..fine('firing mouse up event');
      _parentTreeView._onTreeNodeSelected(this);
    };
  }

  @override void initProperties(){
    super.initProperties();

    childNodes = new FrameworkProperty(this, 'childNodes',
        defaultValue:new ObservableList<TreeNode>());

    childNodes.value.listChanged + _childrenChanged;

    icon = new FrameworkProperty(this, 'icon');

    folderIcon= new FrameworkProperty(this, 'folderIcon');

    fileIcon = new FrameworkProperty(this, 'fileIcon');


    Futures
      .wait(
      [
       Template.deserialize(TreeView.FOLDER_DEFAULT_TEMPLATE),
       Template.deserialize(TreeView.FILE_DEFAULT_TEMPLATE)
       ]
      ).then((results){
        folderIcon.value = results[0];
        fileIcon.value = results[1];
      });

    indicator = new FrameworkProperty(this, 'indicator',
        defaultValue:TreeView.INDICATOR_COLLAPSED);

    header = new FrameworkProperty(this, 'header', defaultValue:'');

    childVisibility = new FrameworkProperty(
      this,
      'childVisibility',
      defaultValue: Visibility.collapsed,
      converter: const StringToVisibilityConverter());

    _mouseEventStyles = new FrameworkProperty(this, '_mouseEventStyles',
        defaultValue: getResource('__TreeView_mouse_leave_style_template__'));
  }

  void _childrenChanged(_, ListChangedEventArgs args){
    for (final child in args.oldItems){
      child._parentNode = null;
    }
    for (final child in args.newItems){
      child._parentNode = this;
    }
    if (!isLoaded) return;
    updateIndicator();
  }

  // IFrameworkContainer interface
  @override get containerContent => template;

  TreeNode get parentNode => _parentNode;

  @override String get defaultControlTemplate {
    return
    '''<controltemplate controlType="${this.templateName}">
          <template>
            <stack>
              <stack orientation='horizontal'>
                <contentpresenter name='__tree_node_indicator__' margin='2' minwidth='15' content='{template indicator}' />
                <border style='{template _mouseEventStyles}' padding='0,5,0,0' borderThickness='1' cornerRadius='4' name='__tree_node_header__'>
                  <stack orientation='horizontal'>
                    <contentpresenter name='icon' valign='center' margin='2' minwidth='20' content='{template icon}' />
                    <contentpresenter name='header' valign='center' content='{template header}' />
                  </stack>
                </border>
              </stack>
              <collectionpresenter name='__tree_node_cp__' visibility='{template childVisibility}' items='{template childNodes}'>
                <itemstemplate>
                  <contentpresenter margin='0,0,0,20' content='{data}' />
                </itemstemplate>
              </collectionpresenter>
            </stack>
          </template>
        </controltemplate>
    ''';
  }
}