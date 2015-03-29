package org.cocos2dx.lua;

import org.cocos2dx.CocosLuaGame.R;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class AlarmBroadcastReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        PendingIntent contentIntent = PendingIntent.getActivity(context, 0, new Intent(context, AppActivity.class), 0);
        Notification.Builder builder = new Notification.Builder(context);
        builder.setContentIntent(contentIntent);
        builder.setTicker(context.getString(R.string.app_name)); // ステータスバーに表示されるテキスト
        builder.setSmallIcon(R.drawable.icon); // アイコン
        builder.setContentTitle(context.getString(R.string.app_name)); // Notificationを開いたときに表示されるタイトル
        builder.setContentText(intent.getStringExtra("body")); // Notificationを開いたときに表示されるサブタイトル
        builder.setDefaults(Notification.DEFAULT_LIGHTS); // 通知時の音・バイブ・ライト
        builder.setAutoCancel(true); // タップするとキャンセル(消える)
        builder.setContentIntent(contentIntent);
        NotificationManager manager = (NotificationManager)context.getSystemService(Service.NOTIFICATION_SERVICE);
        manager.notify(R.string.app_name, builder.build());
    }

}
