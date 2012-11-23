// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

library buckshot_html_browser;

import 'dart:html';
import 'package:xml/xml.dart';
import 'package:buckshot_html/web/web.dart';
import 'package:buckshot/pal/box_model_surface/box_model_surface.dart';
export 'package:buckshot/pal/box_model_surface/box_model_surface.dart';

//core html controls
import 'package:buckshot_html/controls/core/border.dart';
import 'package:buckshot_html/controls/core/text_block.dart';
import 'package:buckshot_html/controls/core/stack.dart';
import 'package:buckshot_html/controls/core/scroll_viewer.dart';
import 'package:buckshot_html/controls/core/image.dart';
import 'package:buckshot_html/controls/core/content_presenter.dart';
import 'package:buckshot_html/controls/core/collection_presenter.dart';
import 'package:buckshot_html/controls/core/slider.dart';
import 'package:buckshot_html/controls/core/button.dart';
import 'package:buckshot_html/controls/core/control.dart';
import 'package:buckshot_html/controls/core/check_box.dart';
import 'package:buckshot_html/controls/core/radio_button.dart';
import 'package:buckshot_html/controls/core/text_box.dart';
import 'package:buckshot_html/controls/core/text_area.dart';
import 'package:buckshot_html/controls/core/hyperlink.dart';
import 'package:buckshot_html/controls/core/drop_down_list.dart';
import 'package:buckshot_html/controls/core/grid/grid.dart';
import 'package:buckshot_html/controls/core/layout_canvas.dart';
import 'package:buckshot_html/controls/core/raw_html.dart';

export 'dart:html';
export 'package:buckshot_html/controls/core/border.dart';
export 'package:buckshot_html/controls/core/text_block.dart';
export 'package:buckshot_html/controls/core/stack.dart';
export 'package:buckshot_html/controls/core/scroll_viewer.dart';
export 'package:buckshot_html/controls/core/image.dart';
export 'package:buckshot_html/controls/core/content_presenter.dart';
export 'package:buckshot_html/controls/core/collection_presenter.dart';
export 'package:buckshot_html/controls/core/slider.dart';
export 'package:buckshot_html/controls/core/button.dart';
export 'package:buckshot_html/controls/core/control.dart';
export 'package:buckshot_html/controls/core/check_box.dart';
export 'package:buckshot_html/controls/core/radio_button.dart';
export 'package:buckshot_html/controls/core/text_box.dart';
export 'package:buckshot_html/controls/core/text_area.dart';
export 'package:buckshot_html/controls/core/hyperlink.dart';
export 'package:buckshot_html/controls/core/drop_down_list.dart';
export 'package:buckshot_html/controls/core/grid/grid.dart';
export 'package:buckshot_html/controls/core/layout_canvas.dart';
export 'package:buckshot_html/controls/core/raw_html.dart';

part 'src/html_platform_element.dart';
part 'src/html_platform.dart';

bool _platformInitialized = false;

/**
 * Initializes the Buckshot framework to use the [HtmlPlatform] presenter.
 *
 * Optional argument [hostID] may also be specified (e.g. '#myhostdiv')
 *
 * IMPORTANT:  This should be called first before making any other calls
 * to the Buckshot API.
 */
void initPlatform({String hostID : '#BuckshotHost'}){
  if (_platformInitialized) return;
  _htmlPlatform = new HtmlPlatform.host(hostID);
  registerElement(new ControlTemplate.register());
  registerElement(new Border.register());
  registerElement(new TextBlock.register());
  registerElement(new Stack.register());
  registerElement(new ScrollViewer.register());
  registerElement(new Image.register());
  registerElement(new ContentPresenter.register());
  registerElement(new CollectionPresenter.register());
  registerElement(new Slider.register());
  registerElement(new Button.register());
  registerElement(new RadioButton.register());
  registerElement(new CheckBox.register());
  registerElement(new TextBox.register());
  registerElement(new TextArea.register());
  registerElement(new Hyperlink.register());
  registerElement(new DropDownList.register());
  registerElement(new Grid.register());
  registerElement(new ColumnDefinition.register());
  registerElement(new RowDefinition.register());
  registerElement(new LayoutCanvas.register());
  registerElement(new RawHtml.register());
  htmlPlatform._loadResources();
  _platformInitialized = true;
}

/**
 * Gets the [HtmlPlatform] context for this [Platform].
 */
HtmlPlatform get htmlPlatform => platform as HtmlPlatform;
set _htmlPlatform(HtmlPlatform p) {
  assert(platform == null);
  platform = p;
}
