class AccountSettings {
  final String userId;
  final bool receiveNotifications;
  final bool privateAccount;
  final String languagePreference;

  AccountSettings({
    required this.userId,
    this.receiveNotifications = true,
    this.privateAccount = false,
    this.languagePreference = 'en',
  });

  factory AccountSettings.fromJson(Map<String, dynamic> json) => AccountSettings(
    userId: json['user_id'],
    receiveNotifications: json['receive_notifications'],
    privateAccount: json['private_account'],
    languagePreference: json['language_preference'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'receive_notifications': receiveNotifications,
    'private_account': privateAccount,
    'language_preference': languagePreference,
  };
}