import 'package:buckshot_html/buckshot_html_browser.dart';

void main() {
  // This function initializes the current platform.  In this case, since
  // we imported buckshot_browser.dart, the platform is HTML DOM by default.
  //
  // You can also specify your own ID for the host DIV by passing it like so:
  //     initPlatform(hostID : '#myhostdiv');
  //
  // otherwise the platform will default to '#BuckshotHost'.
  initPlatform();

  // platform.render() renders a View into the web page at the host DIV.
  platform.render(
    new View.fromTemplate('<textblock text="Hello World!" />')
  );
}
