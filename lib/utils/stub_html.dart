// Stub so the app compiles on mobile/desktop too.
// The _openInNewTab button is only meaningful on web.
// ignore_for_file: avoid_classes_with_only_static_members
class Blob {
  Blob(List<dynamic> parts, [String? type]);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class Window {
  void open(String url, String target) {}
}

final window = Window();