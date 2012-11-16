part of grid_html_buckshot;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

// Internal class that provides virtual containers for the
// Grid control.
class _GridCell extends Control implements FrameworkContainer
{
  EventHandlerReference _ref;
  FrameworkProperty<HtmlPlatformElement> content;

  _GridCell()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = content;
  }
  _GridCell.register() : super.register();
  makeMe() => null;

  get containerContent => content.value;

  @override void onLoaded(){
    super.onLoaded();
  }

  @override void initProperties(){
    super.initProperties();

    content = new FrameworkProperty(this, 'content',
      propertyChangedCallback: (HtmlPlatformElement newContent)
        {
          rawElement.elements.clear();
          assert(newContent != null);
          newContent.parent = this;
          rawElement.elements.add(newContent.rawElement);
        });
  }

  @override void createPrimitive(){
    rawElement = new DivElement()
                    ..style.overflow = "hidden"
                    ..style.position = "absolute"
//                    ..style.background = 'Blue'
                    ..style.display ='table';

    rawElement.style.display = '-webkit-flex';
    rawElement.style.boxSizing = 'border-box';
  }

  @override void updateLayout(){
    super.updateLayout();
    if (!isLoaded) return;
    if (content.value == null) return;
    HtmlPlatformElement.updateChildAlignment(this);
  }
}
