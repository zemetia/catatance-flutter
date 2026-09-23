/// A saved link between a notification source app (Android package) and
/// the wallet its captured notifications should post transactions against.
class BankNotificationMapping {
  const BankNotificationMapping({
    required this.id,
    required this.packageName,
    required this.appLabel,
    required this.accountId,
    required this.isEnabled,
  });

  final int id;
  final String packageName;
  final String appLabel;
  final int accountId;
  final bool isEnabled;

  BankNotificationMapping copyWith({
    int? id,
    String? packageName,
    String? appLabel,
    int? accountId,
    bool? isEnabled,
  }) {
    return BankNotificationMapping(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appLabel: appLabel ?? this.appLabel,
      accountId: accountId ?? this.accountId,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// A new mapping, before it has an id (see the repository's `insertMapping`).
class BankNotificationMappingDraft {
  const BankNotificationMappingDraft({
    required this.packageName,
    required this.appLabel,
    required this.accountId,
    this.isEnabled = true,
  });

  final String packageName;
  final String appLabel;
  final int accountId;
  final bool isEnabled;
}
