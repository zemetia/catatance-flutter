/// Lifecycle status of an installment plan (cicilan).
enum InstallmentStatus {
  active,
  completed;

  static InstallmentStatus fromRaw(String raw) => switch (raw) {
        'completed' => InstallmentStatus.completed,
        _ => InstallmentStatus.active,
      };

  String get raw => switch (this) {
        InstallmentStatus.active => 'active',
        InstallmentStatus.completed => 'completed',
      };

  String get label => switch (this) {
        InstallmentStatus.active => 'Aktif',
        InstallmentStatus.completed => 'Lunas',
      };
}
