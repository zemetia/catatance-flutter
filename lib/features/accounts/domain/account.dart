import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Broad category of a wallet/account, mirrors `Accounts.type` in the DB.
enum AccountType {
  cash,
  bank,
  eWallet;

  static AccountType fromRaw(String raw) => switch (raw) {
    'bank' => AccountType.bank,
    'e-wallet' => AccountType.eWallet,
    _ => AccountType.cash,
  };

  String get label => switch (this) {
    AccountType.cash => 'Tunai',
    AccountType.bank => 'Bank',
    AccountType.eWallet => 'E-wallet',
  };

  IconData get icon => switch (this) {
    AccountType.cash => LucideIcons.wallet,
    AccountType.bank => LucideIcons.landmark,
    AccountType.eWallet => LucideIcons.smartphone,
  };
}

/// A wallet/account the user tracks balances in (bank, e-wallet, cash).
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceCents,
  });

  final int id;
  final String name;
  final AccountType type;
  final int balanceCents;
}
