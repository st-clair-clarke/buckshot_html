part of switchy_buckshot;

class Clock extends View
{
  Clock() : super.fromResource('web/views/templates/clock.xml'){
    ready.then((t){
      t.dataContext.value = new ClockViewModel();
    });
  }
}
