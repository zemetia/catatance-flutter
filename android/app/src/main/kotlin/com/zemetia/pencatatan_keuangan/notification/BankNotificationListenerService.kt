package com.zemetia.pencatatan_keuangan.notification

import android.app.Notification
import android.content.Context
import android.content.pm.PackageManager
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

/**
 * Listens for every posted notification on the device and, for the subset
 * whose source package is in [watchedPackages] (kept in sync from the Dart
 * side via [MainActivity]'s method channel — see [PREFS_NAME]/[KEY_WATCHED_PACKAGES]),
 * appends its title/text to a durable [KEY_PENDING_QUEUE] so Flutter can
 * drain it on next resume, even if the app process was killed when the
 * notification arrived (this service runs independently of the Flutter
 * engine/Activity lifecycle).
 */
class BankNotificationListenerService : NotificationListenerService() {

    companion object {
        const val PREFS_NAME = "com.zemetia.pencatatan_keuangan.bank_notifications"
        const val KEY_WATCHED_PACKAGES = "watched_packages"
        const val KEY_PENDING_QUEUE = "pending_notifications"
        private const val MAX_QUEUE_SIZE = 200
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)

        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val watched = prefs.getStringSet(KEY_WATCHED_PACKAGES, emptySet()) ?: emptySet()
        if (sbn.packageName !in watched) return

        val extras = sbn.notification.extras
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
        val text = (extras.getCharSequence(Notification.EXTRA_BIG_TEXT)
            ?: extras.getCharSequence(Notification.EXTRA_TEXT))?.toString()
        if (text.isNullOrBlank()) return

        val entry = JSONObject().apply {
            put("packageName", sbn.packageName)
            put("appLabel", resolveAppLabel(sbn.packageName))
            put("title", title)
            put("content", text)
            put("postedAt", sbn.postTime)
        }

        val queue = JSONArray(prefs.getString(KEY_PENDING_QUEUE, "[]"))
        val trimmed = JSONArray()
        val start = if (queue.length() >= MAX_QUEUE_SIZE) queue.length() - MAX_QUEUE_SIZE + 1 else 0
        for (i in start until queue.length()) {
            trimmed.put(queue.getJSONObject(i))
        }
        trimmed.put(entry)

        prefs.edit().putString(KEY_PENDING_QUEUE, trimmed.toString()).apply()
    }

    private fun resolveAppLabel(packageName: String): String {
        return try {
            val pm = applicationContext.packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(info).toString()
        } catch (_: PackageManager.NameNotFoundException) {
            packageName
        }
    }
}
