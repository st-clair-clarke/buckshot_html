import 'package:buckshot_html/buckshot_html_browser.dart';
import 'package:buckshot_html/web/web.dart';
import 'package:xml/xml.dart';
import 'package:dartnet_event_model/dartnet_event_model.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'string_to_grid_length_converter_tests.dart' as stringtogridlength;

void main() {
  initPlatform();
  useHtmlEnhancedConfiguration();

  stringtogridlength.run();
}
