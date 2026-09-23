import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pencatatan_keuangan/features/savings_goals/domain/savings_goal.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('SavingsGoal Domain Model Tests', () {
    final now = DateTime(2026, 9, 22);

    test('Progress calculation handles edge cases', () {
      // Zero target
      final zeroTarget = SavingsGoal(
        id: 1,
        name: 'Empty Target',
        iconKey: 'plane',
        gradientIndex: 0,
        targetAmountCents: 0,
        currentAmountCents: 0,
        createdAt: now,
      );
      expect(zeroTarget.progress, equals(0.0));
      expect(zeroTarget.progressPercentage, equals('0%'));
      expect(zeroTarget.isAchieved, isFalse);

      // Normal in-progress
      final inProgress = SavingsGoal(
        id: 2,
        name: 'Liburan Bali',
        iconKey: 'plane',
        gradientIndex: 1,
        targetAmountCents: 10000000,
        currentAmountCents: 4500000,
        createdAt: now,
      );
      expect(inProgress.progress, equals(0.45));
      expect(inProgress.progressPercentage, equals('45%'));
      expect(inProgress.remainingCents, equals(5500000));
      expect(inProgress.isAchieved, isFalse);

      // Fully achieved / over-saved
      final achieved = SavingsGoal(
        id: 3,
        name: 'Macbook',
        iconKey: 'laptop',
        gradientIndex: 0,
        targetAmountCents: 20000000,
        currentAmountCents: 25000000,
        createdAt: now,
      );
      expect(achieved.progress, equals(1.0));
      expect(achieved.progressPercentage, equals('100%'));
      expect(achieved.remainingCents, equals(0));
      expect(achieved.isAchieved, isTrue);
    });

    test('Deadline formatting handles null and valid dates', () {
      final noDeadline = SavingsGoal(
        id: 1,
        name: 'Dana Darurat',
        iconKey: 'health',
        gradientIndex: 2,
        targetAmountCents: 10000000,
        createdAt: now,
      );
      expect(noDeadline.deadlineLabel, equals('Tanpa deadline'));

      final withDeadline = SavingsGoal(
        id: 2,
        name: 'Mobil Baru',
        iconKey: 'car',
        gradientIndex: 3,
        targetAmountCents: 250000000,
        targetDate: DateTime(2027, 5, 20),
        createdAt: now,
      );
      expect(withDeadline.deadlineLabel, contains('2027'));
    });

    test('daysRemaining and deadlineStatusLabel calculate relative time correctly', () {
      final noDeadline = SavingsGoal(
        id: 1,
        name: 'Dana Darurat',
        iconKey: 'health',
        gradientIndex: 2,
        targetAmountCents: 10000000,
        createdAt: now,
      );
      expect(noDeadline.daysRemaining, isNull);
      expect(noDeadline.deadlineStatusLabel, equals('Tanpa deadline'));

      final today = DateTime.now();
      final in15Days = today.add(const Duration(days: 15));
      final goal15Days = SavingsGoal(
        id: 2,
        name: 'Tiket Konser',
        iconKey: 'game',
        gradientIndex: 1,
        targetAmountCents: 2000000,
        targetDate: in15Days,
        createdAt: now,
      );
      expect(goal15Days.daysRemaining, inInclusiveRange(14, 16));
      expect(goal15Days.deadlineStatusLabel, contains('hari'));

      final pastGoal = SavingsGoal(
        id: 3,
        name: 'Buku',
        iconKey: 'graduation',
        gradientIndex: 0,
        targetAmountCents: 500000,
        targetDate: today.subtract(const Duration(days: 3)),
        createdAt: now,
      );
      expect(pastGoal.daysRemaining, lessThan(0));
      expect(pastGoal.deadlineStatusLabel, contains('Lewat'));

      final achievedGoal = pastGoal.copyWith(currentAmountCents: 600000);
      expect(achievedGoal.deadlineStatusLabel, equals('Tercapai 🎉'));
    });

    test('Autosave labels format correctly across frequencies', () {
      final dailyGoal = SavingsGoal(
        id: 1,
        name: 'Tabungan Harian',
        iconKey: 'invest',
        gradientIndex: 0,
        targetAmountCents: 5000000,
        autoSaveEnabled: true,
        autoSaveAmountCents: 50000,
        autoSaveFrequency: 'daily',
        createdAt: now,
      );
      expect(dailyGoal.autoSaveFrequencyLabel, equals('Harian'));
      expect(dailyGoal.autoSaveSummary, contains('hari'));

      final weeklyGoal = dailyGoal.copyWith(
        autoSaveFrequency: 'weekly',
        autoSaveAmountCents: 250000,
      );
      expect(weeklyGoal.autoSaveFrequencyLabel, equals('Mingguan'));
      expect(weeklyGoal.autoSaveSummary, contains('mgg'));

      final monthlyGoal = dailyGoal.copyWith(
        autoSaveFrequency: 'monthly',
        autoSaveAmountCents: 1000000,
      );
      expect(monthlyGoal.autoSaveFrequencyLabel, equals('Bulanan'));
      expect(monthlyGoal.autoSaveSummary, contains('bln'));

      final disabledGoal = dailyGoal.copyWith(autoSaveEnabled: false);
      expect(disabledGoal.autoSaveSummary, equals('Autosave nonaktif'));
    });

    test('SavingsGoalIcons returns correct option or fallback', () {
      final plane = SavingsGoalIcons.get('plane');
      expect(plane.emoji, equals('✈️'));
      expect(plane.label, equals('Liburan'));

      final laptop = SavingsGoalIcons.get('laptop');
      expect(laptop.emoji, equals('💻'));

      final unknown = SavingsGoalIcons.get('unknown_key');
      expect(unknown.key, equals('plane')); // fallback to first
    });

    test('SavingsGoalGradients handles valid and out-of-bound indices', () {
      final g0 = SavingsGoalGradients.at(0);
      expect(g0.colors, isNotEmpty);

      final gOverflow = SavingsGoalGradients.at(999);
      expect(gOverflow.colors, isNotEmpty);
    });
  });
}
