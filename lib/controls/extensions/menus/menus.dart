// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library menus_control_extensions_buckshot;
import 'package:buckshot_html/buckshot_html_browser.dart';
part 'src/menu.dart';
part 'src/menu_item.dart';
part 'src/menu_strip.dart';
part 'src/menu_item_selected_event_args.dart';

/**
 * Registers [MenuStrip], [Menu], and [MenuItem] controls to the framework if
 * reflection is not enabled.
 */
void registerMenuControls(){
  if (reflectionEnabled) return;

  registerElement(new Menu.register());
  registerElement(new MenuItem.register());
  registerElement(new MenuStrip.register());
}

