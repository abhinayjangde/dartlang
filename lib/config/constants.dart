class Constants {
  static const String appName = 'ChatApp';
  static const String codespaceName = 'reimagined-waffle-46j66x5w4jrhv77';
  static const String graphqlEndpoint = 'http://$codespaceName-8080.preview.app.github.dev/v1/graphql';
  static const String authEndpoint = 'http://$codespaceName-4000.preview.app.github.dev';
  static const String hasuraAdminSecret = 'myadminsecretkey';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  static const Duration messageSendDebounce = Duration(milliseconds: 300);
}
