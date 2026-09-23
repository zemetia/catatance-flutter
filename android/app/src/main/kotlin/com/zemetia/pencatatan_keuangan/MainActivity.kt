package com.zemetia.pencatatan_keuangan

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import com.zemetia.pencatatan_keuangan.notification.BankNotificationListenerService
import com.zemetia.pencatatan_keuangan.widget.TotalBalanceWidgetProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

// local_auth's Android biometric prompt requires a FragmentActivity host.
class MainActivity : FlutterFragmentActivity() {

    private var pendingRoute: String? = null
    private var methodChannel: MethodChannel? = null

    companion object {
        const val CHANNEL = "com.zemetia.pencatatan_keuangan/home_widget"
        const val BANK_NOTIFICATIONS_CHANNEL =
            "com.zemetia.pencatatan_keuangan/bank_notifications"
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
        pendingRoute?.let { route ->
            methodChannel?.invokeMethod("onNavigateRoute", route)
            pendingRoute = null
        }
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        if (intent.action == TotalBalanceWidgetProvider.ACTION_ADD_TRANSACTION ||
            intent.getStringExtra(TotalBalanceWidgetProvider.EXTRA_ROUTE) == "/transactions/add"
        ) {
            pendingRoute = "/transactions/add"
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetData" -> {
                    val balanceText = call.argument<String>("balance_text") ?: "Rp 0"
                    val subtitleText = call.argument<String>("subtitle_text") ?: "Pencatatan Keuangan • Real-time"

                    val prefs = getSharedPreferences(TotalBalanceWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit()
                        .putString(TotalBalanceWidgetProvider.KEY_BALANCE_TEXT, balanceText)
                        .putString(TotalBalanceWidgetProvider.KEY_SUBTITLE_TEXT, subtitleText)
                        .apply()

                    TotalBalanceWidgetProvider.updateAllWidgets(this)
                    result.success(true)
                }

                "requestPinWidget" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val appWidgetManager = getSystemService(AppWidgetManager::class.java)
                        val provider = ComponentName(this, TotalBalanceWidgetProvider::class.java)
                        if (appWidgetManager != null && appWidgetManager.isRequestPinAppWidgetSupported) {
                            val pinned = appWidgetManager.requestPinAppWidget(provider, null, null)
                            result.success(pinned)
                            return@setMethodCallHandler
                        }
                    }
                    result.success(false)
                }

                "getInitialRoute" -> {
                    val route = pendingRoute
                    pendingRoute = null
                    result.success(route)
                }

                else -> result.notImplemented()
            }
        }

        val bankNotificationsChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BANK_NOTIFICATIONS_CHANNEL)

        bankNotificationsChannel.setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences(
                BankNotificationListenerService.PREFS_NAME,
                Context.MODE_PRIVATE,
            )

            when (call.method) {
                "isListenerEnabled" -> {
                    val enabled = NotificationManagerCompat.getEnabledListenerPackages(this)
                        .contains(packageName)
                    result.success(enabled)
                }

                "openListenerSettings" -> {
                    startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                    result.success(null)
                }

                "drainPendingNotifications" -> {
                    val raw = prefs.getString(
                        BankNotificationListenerService.KEY_PENDING_QUEUE,
                        "[]",
                    ) ?: "[]"
                    prefs.edit()
                        .putString(BankNotificationListenerService.KEY_PENDING_QUEUE, "[]")
                        .apply()

                    val queue = JSONArray(raw)
                    val items = mutableListOf<Map<String, Any?>>()
                    for (i in 0 until queue.length()) {
                        val entry = queue.getJSONObject(i)
                        items.add(
                            mapOf(
                                "packageName" to entry.optString("packageName"),
                                "appLabel" to entry.optString("appLabel"),
                                "title" to entry.opt("title"),
                                "content" to entry.optString("content"),
                                "postedAt" to entry.optLong("postedAt"),
                            ),
                        )
                    }
                    result.success(items)
                }

                "updateWatchedPackages" -> {
                    val packages = (call.arguments as? List<*>)
                        ?.filterIsInstance<String>()
                        ?.toSet()
                        ?: emptySet()
                    prefs.edit()
                        .putStringSet(
                            BankNotificationListenerService.KEY_WATCHED_PACKAGES,
                            packages,
                        )
                        .apply()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
