part of sandbox_buckshot;

class Calculator extends View
{

  Calculator() : super.fromResource('web/views/templates/calculator.xml')
  {
    ready.then((t){
      rootVisual.dataContext.value = new CalculatorViewModel();
    });
  }
}
