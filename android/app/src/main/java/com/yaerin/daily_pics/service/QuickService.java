package com.yaerin.daily_pics.service;

import android.app.WallpaperManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.service.quicksettings.TileService;
import android.widget.Toast;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.yaerin.daily_pics.R;
import com.yaerin.daily_pics.util.WallpaperHelper;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.List;

import androidx.annotation.RequiresApi;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.ResponseBody;

/**
 * Create by Yaerin on 2019/3/2
 *
 * @author Yaerin
 */
@RequiresApi(api = Build.VERSION_CODES.N)
public class QuickService extends TileService implements Runnable {
    @Override
    public void onClick() {
        new Thread(this).start();
    }

    @Override
    public void run() {
        try {
            toast("正在开始下载...");
            OkHttpClient client = new OkHttpClient();
            Request request = new Request.Builder()
                    .url("https://dp.chimon.me/api/random.php?api=yes")
                    .build();
            ResponseBody body = client.newCall(request).execute().body();
            if (body == null) {
                throw new IOException("ERR_EMPTY_RESPONSE");
            }
            Response res = new Gson().fromJson(body.string(), Response.class);
            WallpaperHelper.set(this, res.data.get(0).url);
        } catch (IOException e) {
            toast(getString(R.string.err_set_failed, e.getLocalizedMessage()));
        }
    }

    private void toast(String text) {
        new Handler(Looper.getMainLooper()).post(() -> {
            Toast.makeText(QuickService.this, text, Toast.LENGTH_SHORT).show();
        });
    }

    class Response {
        @SerializedName("pictures")
        List<Picture> data;

        String status;
    }

    class Picture {
        @SerializedName("PID")
        String id;

        @SerializedName("p_title")
        String title;

        @SerializedName("p_content")
        String info;

        int width;

        int height;

        @SerializedName("username")
        String user;

        @SerializedName("p_link")
        String url;

        @SerializedName("p_date")
        String date;

        @SerializedName("TNAME")
        String type;
    }
}
