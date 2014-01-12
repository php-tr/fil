package org.phptr.philip;

import android.util.Log;
import com.google.analytics.tracking.android.*;

public class Analytics
{
    private Tracker _tracker;
    private GoogleAnalytics _analytics;

    private static Analytics _instance = null;

    private static String TAG = "[Analytics]";

    public Analytics(MainActivity mainActivity, String trackerId)
    {
        _analytics = GoogleAnalytics.getInstance(mainActivity.getBaseContext());
        _tracker = _analytics.getTracker(trackerId);

        _instance = this;
    }

    public static Analytics getInstance()
    {
        return _instance;
    }

    public Tracker getTracker()
    {
        return _tracker;
    }

    public static void initAnalytics(String trackerId)
    {
        _instance = new Analytics(MainActivity.getInstance(), trackerId);
    }

    public static void sendViewEvent(String screenName)
    {
        Log.d(TAG, "Screen Name: " + screenName);

        getInstance().getTracker().send(
            MapBuilder
                .createAppView()
                .set(Fields.SCREEN_NAME, screenName)
                .build()
        );
    }

    public static void sendEvent(String eventName, String action, String label, int value)
    {
        Log.d(TAG, "Event Name: " + eventName + " Action: " + action + " Label: " + label);

        getInstance().getTracker().send(
            MapBuilder
                .createEvent(eventName, action, label, Long.valueOf(value))
                .build()
        );
    }
}
