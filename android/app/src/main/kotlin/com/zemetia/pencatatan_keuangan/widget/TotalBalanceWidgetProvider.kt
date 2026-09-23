package com.zemetia.pencatatan_keuangan.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import com.zemetia.pencatatan_keuangan.MainActivity
import com.zemetia.pencatatan_keuangan.R

class TotalBalanceWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        const val PREFS_NAME = "com.zemetia.pencatatan_keuangan.widget"
        const val KEY_BALANCE_TEXT = "balance_text"
        const val KEY_SUBTITLE_TEXT = "subtitle_text"
        const val ACTION_ADD_TRANSACTION = "com.zemetia.pencatatan_keuangan.ACTION_ADD_TRANSACTION"
        const val EXTRA_ROUTE = "route"

        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val balanceText = prefs.getString(KEY_BALANCE_TEXT, "Rp 0") ?: "Rp 0"
            val subtitleText = prefs.getString(KEY_SUBTITLE_TEXT, "Pencatatan Keuangan • Real-time")
                ?: "Pencatatan Keuangan • Real-time"

            val views = RemoteViews(context.packageName, R.layout.widget_total_balance)
            views.setTextViewText(R.id.widget_balance_text, balanceText)
            views.setTextViewText(R.id.widget_subtitle_text, subtitleText)

            val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or (
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
            )

            // PendingIntent for tapping the card / balance: opens main app
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                this.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openAppPendingIntent = PendingIntent.getActivity(context, 0, openAppIntent, pendingIntentFlags)
            views.setOnClickPendingIntent(R.id.widget_root, openAppPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_info_container, openAppPendingIntent)

            // PendingIntent for '+' button: quick access to transaction creation
            val addTransactionIntent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_ADD_TRANSACTION
                putExtra(EXTRA_ROUTE, "/transactions/add")
                this.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val addTransactionPendingIntent = PendingIntent.getActivity(context, 1, addTransactionIntent, pendingIntentFlags)
            views.setOnClickPendingIntent(R.id.widget_btn_add, addTransactionPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, TotalBalanceWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            for (id in allWidgetIds) {
                updateAppWidget(context, appWidgetManager, id)
            }
        }
    }
}
