// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library sandbox_buckshot;
import 'package:dartnet_event_model/dartnet_event_model.dart';
import 'package:buckshot_html/controls/extensions/all_html_controls.dart';
import 'apps/todo/todo.dart' as todo;
import 'viewmodels/calculator_viewmodel.dart';
part 'viewmodels/clock_viewmodel.dart';
part 'viewmodels/master_viewmodel.dart';
part 'models/demo_model.dart';
part 'views/main.dart';
part 'views/error_view.dart';
part 'views/calculator/calculator.dart';
part 'views/clock.dart';

void main() {
  initHtmlControls();

  htmlPlatform
    .render(new Main())
    .then((rootVisual){
      htmlPlatform.bindToBrowserDimensions(rootVisual.parent);
      (rootVisual.parent as Border).background.value =
          getResource('theme_dark_brush');

      final demo = queryString['demo'];

      if (demo != null){
        rootVisual.dataContext.value.setTemplate('${demo}');
      }else{
        rootVisual.dataContext.value.setTemplate('welcome');
        rootVisual.dataContext.value.setQueryStringTo('welcome');
      }
    });
}

Map<String, String> get queryString {
  var results = {};
  var qs;
  qs = window.location.search.isEmpty ? ''
      : window.location.search.substring(1);
  var pairs = qs.split('&');

  for(final pair in pairs){
    var kv = pair.split('=');
    if (kv.length != 2) continue;
    results[kv[0]] = kv[1];
  }

  return results;
}