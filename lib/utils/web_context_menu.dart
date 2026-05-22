import 'package:universal_html/html.dart' as html;


void disableRightClick() {
  html.document.onContextMenu.listen((event) {
    event.preventDefault();
  });
}