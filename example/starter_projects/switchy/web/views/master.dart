part of switchy_buckshot;

/**
 * Represents the master view of the Switch application.
 */
class Master extends View
{
  Master() : super.fromResource('web/views/templates/master.xml'){
    ready.then((t){
      t.dataContext.value = new MasterViewModel();
    });
  }
}
