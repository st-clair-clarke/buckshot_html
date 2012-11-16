library start_project_buckshot;

import 'package:buckshot_html/buckshot_html_browser.dart';

part 'views/main_view.dart';
part 'viewmodels/viewmodel.dart';
part 'models/model.dart';


main(){
  initPlatform();

  htmlPlatform.render(new MainView())
     .then((rootVisual){
       // Since we want the app to take up the entire browser window,
       // we'll setup some manual bindings to the implicit Border
       // that our view is contained within.

       htmlPlatform.bindToBrowserDimensions(rootVisual.parent);
     });
}