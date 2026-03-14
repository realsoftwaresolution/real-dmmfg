import 'dart:html' as html;

void disableRightClick() {
  html.document.onContextMenu.listen((event) {
    event.preventDefault();
  });
}