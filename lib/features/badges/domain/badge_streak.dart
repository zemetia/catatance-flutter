/// Length of the current daily-activity streak: consecutive calendar days,
/// counting backwards from today, that have at least one entry in
/// [activityDates]. A gap of a whole day (today has no entry yet, but
/// yesterday does) does not reset the streak — only a missed *previous* day
/// does — so the badge doesn't flicker off first thing each morning.
int computeStreakDays(Iterable<DateTime> activityDates, DateTime now) {
  final days = activityDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  if (days.isEmpty) return 0;

  var cursor = DateTime(now.year, now.month, now.day);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
