package com.frasesdiarias.frases_diarias

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget de tela inicial com a FRASE DO DIA. Renderização NATIVA via
 * RemoteViews (nunca renderFlutterWidget com foto — trava em loop). Os dados
 * (quote_text / app_name) são gravados pelo Flutter via home_widget.
 */
class QuoteWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val quote = widgetData.getString("quote_text", null)
                ?: "Grandes pensamentos para todos os dias."
            val appName = widgetData.getString("app_name", null) ?: "Frases Diárias"

            val views = RemoteViews(context.packageName, R.layout.quote_widget).apply {
                setTextViewText(R.id.widget_appname, appName)
                setTextViewText(R.id.widget_quote, quote)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
