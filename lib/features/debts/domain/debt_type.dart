import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';

/// Distinguishes between debt (saya berutang) and receivable (orang berutang ke saya).
enum DebtType {
  debt,
  receivable;

  static DebtType fromRaw(String raw) => switch (raw) {
    'receivable' => DebtType.receivable,
    _ => DebtType.debt,
  };

  String get raw => switch (this) {
    DebtType.debt => 'debt',
    DebtType.receivable => 'receivable',
  };

  /// Indonesian display label.
  String get label => switch (this) {
    DebtType.debt => 'Utang',
    DebtType.receivable => 'Piutang',
  };

  /// Clarifying title for menus / headers.
  String get title => switch (this) {
    DebtType.debt => 'Utang Saya',
    DebtType.receivable => 'Piutang Saya',
  };

  /// Short explanatory description.
  String get description => switch (this) {
    DebtType.debt => 'Saya meminjam uang dari orang lain',
    DebtType.receivable => 'Orang lain meminjam uang dari saya',
  };

  /// Label for person role.
  String get personLabel => switch (this) {
    DebtType.debt => 'Pemberi Pinjaman',
    DebtType.receivable => 'Peminjam / Pihak Terkait',
  };

  /// Label for the payment action.
  String get paymentActionLabel => switch (this) {
    DebtType.debt => 'Bayar Utang',
    DebtType.receivable => 'Terima Pembayaran',
  };

  Color get color => switch (this) {
    DebtType.debt => AppColors.expense,
    DebtType.receivable => AppColors.income,
  };

  Color get containerColor => switch (this) {
    DebtType.debt => AppColors.expenseContainer,
    DebtType.receivable => AppColors.incomeContainer,
  };

  IconData get icon => switch (this) {
    DebtType.debt => LucideIcons.arrow_up_right,
    DebtType.receivable => LucideIcons.arrow_down_left,
  };
}

/// Settlement status of the debt.
enum DebtStatus {
  unpaid,
  paid;

  static DebtStatus fromRaw(String raw) => switch (raw) {
    'paid' => DebtStatus.paid,
    _ => DebtStatus.unpaid,
  };

  String get raw => switch (this) {
    DebtStatus.unpaid => 'unpaid',
    DebtStatus.paid => 'paid',
  };

  String get label => switch (this) {
    DebtStatus.unpaid => 'Belum Lunas',
    DebtStatus.paid => 'Lunas',
  };
}
