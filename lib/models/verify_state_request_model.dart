class VerifyStateRequestModel {
  final List<int> bCodeArray;
  final int expectedMstId;
  final String expectedProcess;

  VerifyStateRequestModel({
    required this.bCodeArray,
    required this.expectedMstId,
    required this.expectedProcess,
  });

  Map<String, dynamic> toJson() {
    return {
      'bCodeArray': bCodeArray,
      'expectedMstId': expectedMstId,
      'expectedProcess': expectedProcess,
    };
  }
}