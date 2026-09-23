import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'badge_metric_type.dart';
import 'badge_tier.dart';

/// Static description of one achievable badge (Lencana) — title, criteria,
/// and how to read its progress numbers. The catalog below is the single
/// source of truth for what badges exist; [BadgeEvaluator] (see
/// `badge_evaluator.dart`) maps each [key] to a live value pulled from
/// [BadgeMetricsSnapshot].
class BadgeDefinition {
  const BadgeDefinition({
    required this.key,
    required this.title,
    required this.description,
    required this.tier,
    required this.metricType,
    required this.target,
    required this.icon,
  });

  /// Stable identifier, also the primary key stored in `EarnedBadges`.
  final String key;
  final String title;
  final String description;
  final BadgeTier tier;
  final BadgeMetricType metricType;

  /// The value [BadgeMetricType]-specific to reach 100%: a count, a whole
  /// percent (0-100), a day streak length, or an amount in cents.
  final int target;
  final IconData icon;
}

/// The 20 badges currently offered, covering both fixed milestones (counts,
/// amounts, streaks) and relative targets (percentages of the user's own
/// goals/income) across every major feature of the app.
const List<BadgeDefinition> badgeCatalog = [
  // --- Pencatatan transaksi -------------------------------------------
  BadgeDefinition(
    key: 'first_transaction',
    title: 'Langkah Pertama',
    description: 'Catat transaksi pertamamu di aplikasi.',
    tier: BadgeTier.bronze,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.footprints,
  ),
  BadgeDefinition(
    key: 'transactions_50',
    title: 'Rajin Mencatat',
    description: 'Catat 50 transaksi, apa pun jenisnya.',
    tier: BadgeTier.silver,
    metricType: BadgeMetricType.count,
    target: 50,
    icon: LucideIcons.notebook_pen,
  ),
  BadgeDefinition(
    key: 'transactions_250',
    title: 'Master Pencatatan',
    description: 'Catat 250 transaksi — kebiasaan yang sudah mengakar.',
    tier: BadgeTier.gold,
    metricType: BadgeMetricType.count,
    target: 250,
    icon: LucideIcons.book_check,
  ),
  BadgeDefinition(
    key: 'transactions_1000',
    title: 'Legenda Keuangan',
    description: 'Catat 1.000 transaksi. Level dewa pencatatan.',
    tier: BadgeTier.platinum,
    metricType: BadgeMetricType.count,
    target: 1000,
    icon: LucideIcons.crown,
  ),
  BadgeDefinition(
    key: 'categories_8',
    title: 'Kategorisasi Rapi',
    description: 'Gunakan 8 kategori berbeda saat mencatat transaksi.',
    tier: BadgeTier.silver,
    metricType: BadgeMetricType.count,
    target: 8,
    icon: LucideIcons.tags,
  ),
  BadgeDefinition(
    key: 'streak_7',
    title: 'Konsisten 7 Hari',
    description: 'Catat setidaknya satu transaksi, 7 hari berturut-turut.',
    tier: BadgeTier.silver,
    metricType: BadgeMetricType.streak,
    target: 7,
    icon: LucideIcons.flame_kindling,
  ),
  BadgeDefinition(
    key: 'streak_30',
    title: 'Konsisten 30 Hari',
    description: 'Catat setidaknya satu transaksi, 30 hari berturut-turut.',
    tier: BadgeTier.platinum,
    metricType: BadgeMetricType.streak,
    target: 30,
    icon: LucideIcons.flame,
  ),

  // --- Dompet ------------------------------------------------------------
  BadgeDefinition(
    key: 'wallets_3',
    title: 'Dompet Lengkap',
    description: 'Miliki 3 dompet aktif untuk memisahkan sumber dana.',
    tier: BadgeTier.bronze,
    metricType: BadgeMetricType.count,
    target: 3,
    icon: LucideIcons.wallet,
  ),
  BadgeDefinition(
    key: 'wallets_5',
    title: 'Kolektor Dompet',
    description: 'Miliki 5 dompet aktif sekaligus.',
    tier: BadgeTier.gold,
    metricType: BadgeMetricType.count,
    target: 5,
    icon: LucideIcons.wallet_cards,
  ),
  BadgeDefinition(
    key: 'transfers_5',
    title: 'Transfer Cerdas',
    description: 'Lakukan 5 kali transfer antar dompet.',
    tier: BadgeTier.bronze,
    metricType: BadgeMetricType.count,
    target: 5,
    icon: LucideIcons.arrow_left_right,
  ),

  // --- Target tabungan -----------------------------------------------------
  BadgeDefinition(
    key: 'goal_first',
    title: 'Penabung Pemula',
    description: 'Buat target tabungan pertamamu.',
    tier: BadgeTier.bronze,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.piggy_bank,
  ),
  BadgeDefinition(
    key: 'goal_halfway',
    title: 'Separuh Jalan',
    description: 'Capai 50% dari salah satu target tabunganmu.',
    tier: BadgeTier.silver,
    metricType: BadgeMetricType.percentage,
    target: 50,
    icon: LucideIcons.trending_up,
  ),
  BadgeDefinition(
    key: 'goal_completed_1',
    title: 'Target Tercapai',
    description: 'Selesaikan satu target tabungan hingga 100%.',
    tier: BadgeTier.gold,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.party_popper,
  ),
  BadgeDefinition(
    key: 'goal_completed_3',
    title: 'Kolektor Target',
    description: 'Selesaikan 3 target tabungan hingga 100%.',
    tier: BadgeTier.platinum,
    metricType: BadgeMetricType.count,
    target: 3,
    icon: LucideIcons.trophy,
  ),

  // --- Anggaran ------------------------------------------------------------
  BadgeDefinition(
    key: 'budget_first',
    title: 'Perencana Anggaran',
    description: 'Buat anggaran pertamamu untuk sebuah kategori.',
    tier: BadgeTier.bronze,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.clipboard_list,
  ),
  BadgeDefinition(
    key: 'savings_rate_20',
    title: 'Rasio Hemat 20%',
    description: 'Sisihkan minimal 20% dari pemasukan bulan ini.',
    tier: BadgeTier.gold,
    metricType: BadgeMetricType.percentage,
    target: 20,
    icon: LucideIcons.percent,
  ),

  // --- Utang, piutang & cicilan --------------------------------------------
  BadgeDefinition(
    key: 'debt_paid_1',
    title: 'Bebas Utang',
    description: 'Lunasi salah satu utangmu sepenuhnya.',
    tier: BadgeTier.silver,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.badge_check,
  ),
  BadgeDefinition(
    key: 'receivable_paid_1',
    title: 'Piutang Cair',
    description: 'Berhasil tagih satu piutang hingga lunas.',
    tier: BadgeTier.silver,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.hand_coins,
  ),
  BadgeDefinition(
    key: 'installment_completed_1',
    title: 'Tuntas Cicilan',
    description: 'Selesaikan satu rencana cicilan hingga lunas.',
    tier: BadgeTier.gold,
    metricType: BadgeMetricType.count,
    target: 1,
    icon: LucideIcons.check_check,
  ),

  // --- Kekayaan bersih -------------------------------------------------
  BadgeDefinition(
    key: 'net_worth_10jt',
    title: 'Saldo Sultan',
    description: 'Total saldo seluruh dompetmu mencapai Rp10.000.000.',
    tier: BadgeTier.platinum,
    metricType: BadgeMetricType.amount,
    target: 10000000,
    icon: LucideIcons.gem,
  ),
];
