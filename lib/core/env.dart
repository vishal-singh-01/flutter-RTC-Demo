class Env {
  static const String agoraAppId = String.fromEnvironment('AGORA_APP_ID', defaultValue: 'fa29c67c582547e497740ea065965f85');
  static const String agoraTempToken = String.fromEnvironment('AGORA_TEMP_TOKEN', defaultValue: '73ca99a185584dfaa54cfcaa8ff94e80');
  static const String channelName = 'demo-channel-001';
  static const String defaultChannelId = 'demo-meeting-1234';

  static const String baseUrl = 'https://reqres.in/api';
}
