library all_html_controls_buckshot;
/**
 * Import this library to conveniently load all available html extensions.
 *
 * Once the library is imported.  Make a call to...
 *
 *     initHtmlControls();
 *
 * ...in your code.
 */
import 'package:buckshot_html/buckshot_html_browser.dart';
import 'package:buckshot_html/controls/extensions/social/plus_one.dart';
import 'package:buckshot_html/controls/extensions/list_box.dart';
import 'package:buckshot_html/controls/extensions/popup.dart';
import 'package:buckshot_html/controls/extensions/media/youtube.dart';
import 'package:buckshot_html/controls/extensions/media/hulu.dart';
import 'package:buckshot_html/controls/extensions/media/vimeo.dart';
import 'package:buckshot_html/controls/extensions/media/funny_or_die.dart';
import 'package:buckshot_html/controls/extensions/modal_dialog.dart';
import 'package:buckshot_html/controls/extensions/dock_panel.dart';
import 'package:buckshot_html/controls/extensions/treeview/tree_view.dart';
import 'package:buckshot_html/controls/extensions/tab_control/tab_control.dart';
import 'package:buckshot_html/controls/extensions/accordion/accordion.dart';
import 'package:buckshot_html/controls/extensions/menus/menus.dart';
import 'package:buckshot_html/controls/extensions/canvas/bitmap_canvas.dart';
import 'package:buckshot_html/controls/extensions/canvas/webgl_canvas.dart';

export 'package:buckshot_html/buckshot_html_browser.dart';
export 'package:buckshot_html/controls/extensions/social/plus_one.dart';
export 'package:buckshot_html/controls/extensions/list_box.dart';
export 'package:buckshot_html/controls/extensions/popup.dart';
export 'package:buckshot_html/controls/extensions/media/youtube.dart';
export 'package:buckshot_html/controls/extensions/media/hulu.dart';
export 'package:buckshot_html/controls/extensions/media/vimeo.dart';
export 'package:buckshot_html/controls/extensions/media/funny_or_die.dart';
export 'package:buckshot_html/controls/extensions/modal_dialog.dart';
export 'package:buckshot_html/controls/extensions/dock_panel.dart';
export 'package:buckshot_html/controls/extensions/treeview/tree_view.dart';
export 'package:buckshot_html/controls/extensions/tab_control/tab_control.dart';
export 'package:buckshot_html/controls/extensions/accordion/accordion.dart';
export 'package:buckshot_html/controls/extensions/menus/menus.dart';
export 'package:buckshot_html/controls/extensions/canvas/bitmap_canvas.dart';
export 'package:buckshot_html/controls/extensions/canvas/webgl_canvas.dart';

void initHtmlControls(){
  initPlatform();
  assert(htmlPlatform != null);
  registerElement(new PlusOne.register());
  registerElement(new ListBox.register());
  registerElement(new YouTube.register());
  registerElement(new Hulu.register());
  registerElement(new Vimeo.register());
  registerElement(new FunnyOrDie.register());
  registerElement(new DockPanel.register());
  registerElement(new TreeView.register());
  registerElement(new TabControl.register());
  registerElement(new Accordion.register());
  registerElement(new BitmapCanvas.register());
  registerElement(new WebGLCanvas.register());
  registerMenuControls();
}