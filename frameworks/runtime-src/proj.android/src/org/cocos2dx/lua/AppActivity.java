/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.io.File;
import java.util.Calendar;
import java.util.Enumeration;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import android.app.AlertDialog;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.app.Service;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.ActivityNotFoundException;
import android.content.pm.ApplicationInfo;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.provider.Settings;
import android.text.format.Formatter;
import android.util.Log;
import android.view.Gravity;
import android.view.WindowManager;
import android.view.animation.TranslateAnimation;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.Toast;

import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.games.*;
import com.google.android.gms.common.*;
import com.google.android.gms.common.api.*;
import com.google.example.games.basegameutils.BaseGameUtils;

import com.jirbo.adcolony.*;
import jp.live_aid.aid.AdController;

import net.uracon.owatag.R;
import net.uracon.owatag.BuildConfig;

public class AppActivity extends Cocos2dxActivity implements GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {

    static String hostIPAdress = "0.0.0.0";
    private static int RC_SIGN_IN = 9001;
    private static int RC_LEADER_BOARD = 9002;
    private AdView mAdView;
    private static AppActivity sApp;
    private Handler handerForLuaj;
    private static float currentAdY = -100;
    private GoogleApiClient mGoogleApiClient;
    private boolean mResolvingConnectionFailure = false;
    private boolean mSignInClicked = false;
    private static String sBoardID = null;
    private static final String SP_NAME = "owatag_game_service";
    private static final String SP_KEY = "owatag_login";
    private static boolean sRewardSuccess = false;
    private AdController mAidAdController;

    private static Map<String, String> sBoardIdMap = new HashMap<String, String>() {{
        put("shobon", "CgkIvMqenM0UEAIQAQ");
        put("kita", "CgkIvMqenM0UEAIQBQ");
        put("monyu", "CgkIvMqenM0UEAIQBg");
        put("pokan", "CgkIvMqenM0UEAIQBw");
        put("shakin", "CgkIvMqenM0UEAIQCA");
        put("pupu", "CgkIvMqenM0UEAIQCQ");
        put("tehe", "CgkIvMqenM0UEAIQCg");
        put("jito", "CgkIvMqenM0UEAIQCw");
        put("he", "CgkIvMqenM0UEAIQDA");
        put("mona", "CgkIvMqenM0UEAIQDQ");
        put("mega", "CgkIvMqenM0UEAIQDg");
        put("yoda", "CgkIvMqenM0UEAIQDw");
        put("nipa", "CgkIvMqenM0UEAIQEA");
        put("cry", "CgkIvMqenM0UEAIQEQ");
        put("po", "CgkIvMqenM0UEAIQEg");
        put("een", "CgkIvMqenM0UEAIQEw");
        put("buwa", "CgkIvMqenM0UEAIQFA");
        put("iiha", "CgkIvMqenM0UEAIQFQ");
        put("nonowa", "CgkIvMqenM0UEAIQFg");
        put("eee", "CgkIvMqenM0UEAIQFw");
        put("puu", "CgkIvMqenM0UEAIQGA");
        put("biki", "CgkIvMqenM0UEAIQGQ");
        put("tira", "CgkIvMqenM0UEAIQGg");
        put("haha", "CgkIvMqenM0UEAIQGw");
        put("foon", "CgkIvMqenM0UEAIQHA");
        put("blank", "CgkIvMqenM0UEAIQHQ");
        put("cyun", "CgkIvMqenM0UEAIQHg");
        put("puyo", "CgkIvMqenM0UEAIQHw");
        put("tere", "CgkIvMqenM0UEAIQIA");
        put("robo", "CgkIvMqenM0UEAIQIQ");
        put("nyan", "CgkIvMqenM0UEAIQIg");
        put("usa", "CgkIvMqenM0UEAIQIw");
        put("manda", "CgkIvMqenM0UEAIQJA");
        put("suya", "CgkIvMqenM0UEAIQJQ");
        put("pero", "CgkIvMqenM0UEAIQJg");
        put("kona", "CgkIvMqenM0UEAIQJw");
        put("yare", "CgkIvMqenM0UEAIQKA");
        put("owata", "CgkIvMqenM0UEAIQKQ");
    }};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        sApp = this;
        handerForLuaj = new Handler();
        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }

        //2.Set the format of window
        mAdView = new AdView(this);
        mAdView.setBackgroundColor(0xff000000);
        mAdView.setAdSize(AdSize.BANNER);
        mAdView.setAdUnitId("ca-app-pub-9353254478629065/6778045836");
        AdRequest.Builder adBuilder = new AdRequest.Builder();
        if (BuildConfig.DEBUG) {
            adBuilder.addTestDevice("C22176DF884CDD4EFE0FFA0A41B8F838");
        }
        mAdView.loadAd(adBuilder.build());
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
        lp.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
        mAdView.setLayoutParams(lp);

        mGoogleApiClient = new GoogleApiClient.Builder(this)
            .addConnectionCallbacks(this)
            .addOnConnectionFailedListener(this)
            .addApi(Games.API).addScope(Games.SCOPE_GAMES)
            .build();

        String version = "1.0.0";
        try {
            version = getPackageManager().getPackageInfo(getPackageName(), 0).versionName;
        } catch(android.content.pm.PackageManager.NameNotFoundException e) {
        }
        AdColony.configure(this, String.format("version:%s,store:google", version), "app840964bf14404a0d89", "vz74bcdc5a758946018b");
        AdColony.addV4VCListener(new AdColonyV4VCListener() {
            public void onAdColonyV4VCReward(AdColonyV4VCReward reward) {
                sRewardSuccess = reward.success();
            }
        });
        if (mAidAdController == null) {
            mAidAdController = new AdController("net.uracon.owatag", this) {
                protected void dialogQuitButtonWasClicked(Dialog dialog, View view) {
                    super.dialogQuitButtonWasClicked(dialog, view);
                    System.exit(0);
                }
            };
            mAidAdController.setCreativeStyle(AdController.CreativeStyle.POPUP_IMAGE);
        }

        // Check the wifi is opened when the native is debug.
        if(nativeIsDebug())
        {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            if(!isNetworkConnected())
            {
                AlertDialog.Builder builder=new AlertDialog.Builder(this);
                builder.setTitle("Warning");
                builder.setMessage("Please open WIFI for debuging...");
                builder.setPositiveButton("OK",new DialogInterface.OnClickListener() {

                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
                        finish();
                        System.exit(0);
                    }
                });

                builder.setNegativeButton("Cancel", null);
                builder.setCancelable(true);
                builder.show();
            }
            hostIPAdress = getHostIpAddress();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (getSharedPreferences(SP_NAME, MODE_PRIVATE).getBoolean(SP_KEY, false)) {
            mGoogleApiClient.connect();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        mGoogleApiClient.disconnect();
    }

    @Override
    public void onResume() {
        super.onResume();
        mAdView.resume();
        AdColony.resume(this);
        mAidAdController.startPreloading();
    }

    @Override
    public void onPause() {
        mAdView.pause();
        AdColony.pause();
        mAidAdController.stopPreloading();
        super.onPause();
    }

    @Override
    public void onDestroy() {
        mAdView.destroy();
        super.onDestroy();
    }

    @Override
    public void onConnected(Bundle connectionHint) {
        if (sBoardID != null) {
            startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mGoogleApiClient, sBoardID), RC_LEADER_BOARD);
            sBoardID = null;
        }
        getSharedPreferences(SP_NAME, MODE_PRIVATE).edit().putBoolean(SP_KEY, true).commit();
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
        if (mResolvingConnectionFailure) {
            return;
        }
        if (mSignInClicked) {
            mSignInClicked = false;
            mResolvingConnectionFailure = true;
            if (!BaseGameUtils.resolveConnectionFailure(this, mGoogleApiClient, connectionResult, RC_SIGN_IN, getString(R.string.signin_other_error))) {
                mResolvingConnectionFailure = false;
            }
        }
        // Put code here to display the sign-in button
    }

    @Override
    public void onConnectionSuspended(int i) {
        mGoogleApiClient.connect();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == RC_SIGN_IN) {
            mSignInClicked = false;
            mResolvingConnectionFailure = false;
            if (resultCode == RESULT_OK) {
                mGoogleApiClient.connect();
            } else {
                BaseGameUtils.showActivityResultError(this, requestCode, resultCode, R.string.signin_failure);
            }
        } else if (requestCode == RC_LEADER_BOARD && resultCode == GamesActivityResultCodes.RESULT_RECONNECT_REQUIRED) {
            mSignInClicked = false;
            mGoogleApiClient.disconnect();
            getSharedPreferences(SP_NAME, MODE_PRIVATE).edit().remove(SP_KEY).commit();
        }
        super.onActivityResult(requestCode, resultCode, intent);
    }

    private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
            if (cm != null) {
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();
            ArrayList networkTypes = new ArrayList();
            networkTypes.add(ConnectivityManager.TYPE_WIFI);
            try {
                networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
            } catch (NoSuchFieldException nsfe) {
            }
            catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
            if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
                    return true;
                }
            }
            return false;
        }

    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }

    public static String getLocalIpAddress() {
        return hostIPAdress;
    }

    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();

    public static void share(final String text, final String image) {
        sApp.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                File file = new File(image);
                file.setReadable(true, false);
                Intent intent = new Intent(Intent.ACTION_SEND);
                intent.setType("image/jpeg");
                intent.putExtra(Intent.EXTRA_TEXT, text);
                intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));
                try {
                    sApp.startActivity(intent);
                } catch (ActivityNotFoundException e) {
                    Toast.makeText(sApp, "Client not found.", Toast.LENGTH_LONG).show();
                }
            }
        });
    }

    public static void bannerAd(final boolean show) {
        sApp.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                float nextAdY = show ? 0 : -100;
                TranslateAnimation translate = new TranslateAnimation(0, 0, currentAdY, nextAdY);
                translate.setFillBefore(true);
                translate.setFillAfter(true);
                translate.setFillEnabled(true);
                translate.setDuration(show ? 200 : 0);
                sApp.mAdView.startAnimation(translate);
                if (show && sApp.mAdView.getParent() == null)
                    sApp.mFrameLayout.addView(sApp.mAdView);
                if (!show && sApp.mAdView.getParent() != null)
                    sApp.mFrameLayout.removeView(sApp.mAdView);
                currentAdY = nextAdY;
            }
        });
    }

    public static void reward(final int callback) {
        sRewardSuccess = false;
        sApp.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                new AdColonyV4VCAd().withListener(new AdColonyAdListener() {
                    public void onAdColonyAdStarted(AdColonyAd ad) {}
                    public void onAdColonyAdAttemptFinished(AdColonyAd ad) {
                        Cocos2dxLuaJavaBridge.callLuaFunctionWithString(callback, sRewardSuccess ? "success" : "fail");
                        Cocos2dxLuaJavaBridge.releaseLuaFunction(callback);
                    }
                }).show();
            }
        });
    }

    public static boolean isSignIn() {
        return sApp.mGoogleApiClient != null && sApp.mGoogleApiClient.isConnected();
    }

    public static void reportScore(String board, int score) {
        if (isSignIn()) {
            Games.Leaderboards.submitScore(sApp.mGoogleApiClient, sBoardIdMap.get(board), score);
        }
    }

    public static void showBoard(String id) {
        final String boardId = sBoardIdMap.get(id);
        if (!isSignIn()) {
            sApp.mSignInClicked = true;
            sBoardID = boardId;
            sApp.mGoogleApiClient.connect();
        } else {
            sApp.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    sApp.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(sApp.mGoogleApiClient, boardId), RC_LEADER_BOARD);
                }
            });
        }
    }

    public static void localNotification(int sec, String body) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.SECOND, sec);
        Intent intent = new Intent(sApp.getApplicationContext(), AlarmBroadcastReceiver.class);
        intent.putExtra("body", body);
        PendingIntent pending = PendingIntent.getBroadcast(sApp.getApplicationContext(), 0, intent, 0);
        AlarmManager am = (AlarmManager)sApp.getSystemService(Service.ALARM_SERVICE);
        am.set(AlarmManager.RTC_WAKEUP, cal.getTimeInMillis(), pending);
    }

    public static void showFinishAd() {
        sApp.handerForLuaj.post(new Runnable() {
            @Override public void run() {
                sApp.mAidAdController.showDialog(AdController.DialogType.ON_EXIT);
            }
        });
    }

}
