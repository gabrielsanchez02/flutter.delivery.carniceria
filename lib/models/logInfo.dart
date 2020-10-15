class LoginInfoModel {
  String qrString;
  String error;
  bool isError;
  String qrDecripter;
  String device;
  LoginInfoModel(
      {this.qrString, this.error, this.isError, this.qrDecripter, this.device});
}

class DeviceIdentifierModel {
  final String deviceName;
  final String deviceVersion;
  final String identifier;
  String sessionId;
  String url;
  DeviceIdentifierModel(
      {this.deviceName,
      this.deviceVersion,
      this.identifier,
      this.sessionId,
      this.url});
}
