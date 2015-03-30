package org.cocos2dx.lua;

import android.app.Application;
import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.Logger;
import net.uracon.owatag.R;
import net.uracon.owatag.BuildConfig;

public class AppApplication extends Application {

    @Override
    public void onCreate() {
        GoogleAnalytics ga = GoogleAnalytics.getInstance(this);
        ga.newTracker(R.xml.global_tracker);
        if (BuildConfig.DEBUG) {
            ga.getLogger().setLogLevel(Logger.LogLevel.VERBOSE);
        }
    }

}
