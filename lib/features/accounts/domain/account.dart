import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Broad category of a wallet/account, mirrors `Accounts.type` in the DB.
enum AccountType {
  cash,
  bank,
  eWallet,
  card,
  savings,
  other;

  static AccountType fromRaw(String raw) => switch (raw) {
    'bank' => AccountType.bank,
    'e-wallet' => AccountType.eWallet,
    'card' => AccountType.card,
    'savings' => AccountType.savings,
    'other' => AccountType.other,
    _ => AccountType.cash,
  };

  String get raw => switch (this) {
    AccountType.cash => 'cash',
    AccountType.bank => 'bank',
    AccountType.eWallet => 'e-wallet',
    AccountType.card => 'card',
    AccountType.savings => 'savings',
    AccountType.other => 'other',
  };

  String get label => switch (this) {
    AccountType.cash => 'Tunai',
    AccountType.bank => 'Bank',
    AccountType.eWallet => 'E-wallet',
    AccountType.card => 'Kartu',
    AccountType.savings => 'Tabungan',
    AccountType.other => 'Lainnya',
  };

  IconData get icon => switch (this) {
    AccountType.cash => LucideIcons.wallet,
    AccountType.bank => LucideIcons.landmark,
    AccountType.eWallet => LucideIcons.smartphone,
    AccountType.card => LucideIcons.credit_card,
    AccountType.savings => LucideIcons.piggy_bank,
    AccountType.other => LucideIcons.package,
  };
}

/// A wallet/account the user tracks balances in (bank, e-wallet, cash, ...).
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceCents,
    required this.colorValue,
    required this.isDefault,
  });

  final int id;
  final String name;
  final AccountType type;
  final int balanceCents;
  final int colorValue;
  final bool isDefault;

  Color get color => Color(colorValue);
}
