part of tabcontrol_control_extensions_buckshot;


class AccordionItem extends Control implements FrameworkContainer
{
  FrameworkProperty<HtmlPlatformElement> header;
  FrameworkProperty<HtmlPlatformElement> body;

  AccordionItem()
  {
    stateBag[FrameworkObject.CONTAINER_CONTEXT] = body;
  }
  AccordionItem.register() : super.register();
  @override makeMe() => new AccordionItem();

  @override get containerContent => body.value;

  @override initProperties(){
    super.initProperties();
    header = new FrameworkProperty(this, 'header');
    body = new FrameworkProperty(this, 'body');
  }

  @override createPrimitive(){
    rawElement = new DivElement();
  }
}
