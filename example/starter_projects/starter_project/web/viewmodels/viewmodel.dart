part of start_project_buckshot;

class ViewModel extends ViewModelBase
{
  FrameworkProperty message;
  FrameworkProperty result;
  FrameworkProperty entry;

  final Model _model = new Model();

  @override void initEvents(){
    super.initEvents();

    registerEventHandler('click_handler', click_handler);
  }

  @override void initProperties(){
    super.initProperties();

    message = new FrameworkProperty(this, 'message',
        defaultValue:_model.title);

    result = new FrameworkProperty(this, 'result',
        defaultValue: '');

    entry = new FrameworkProperty(this, 'entry');
  }

  void click_handler(sender, args){
    final v = entry.value;

    result.value = v.isEmpty ? '' : 'You entered: "${entry.value}".';
  }
}
