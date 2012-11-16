library todo_apps_buckshot;

import 'package:buckshot_html/buckshot_html_browser.dart';
part 'view.dart';
part 'viewmodel.dart';


void main() {
  initPlatform();
  htmlPlatform.render(new Main());
}