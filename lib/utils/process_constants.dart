class ProcessConstants {
  static const String deptIssue = 'DEPT ISSUE';

  static const String deptConfirmInward =
      'DEPT CONFIRM[INWARD]';

  static const String factoryIss = 'FACTORY ISS';

  static const String factoryRec = 'FACTORY REC';

  static const String packetCreate = 'PACKET CREATE';

  /// optional all list
  static const List<String> all = [
    deptIssue,
    deptConfirmInward,
    factoryIss,
    factoryRec,
    packetCreate,
  ];
}