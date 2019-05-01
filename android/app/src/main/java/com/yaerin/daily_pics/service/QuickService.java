package com.yaerin.daily_pics.service;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.service.quicksettings.TileService;
import android.widget.Toast;

import androidx.annotation.RequiresApi;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.yaerin.daily_pics.R;
import com.yaerin.daily_pics.util.WallpaperHelper;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.ResponseBody;

import static android.os.Environment.DIRECTORY_PICTURES;
import static android.os.Environment.getExternalStoragePublicDirectory;

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
            Picture data = new Gson().fromJson(body.string(), Response.class).data.get(0);
            String url = data.url;
            String suffix = url.substring(url.lastIndexOf("."));
            File destDir = new File(getExternalStoragePublicDirectory(DIRECTORY_PICTURES), "/Tujian");
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                destDir = new File(getExternalMediaDirs()[0], "/Tujian");
            }
            if (!destDir.exists()) destDir.mkdirs();
            File dest = new File(destDir, data.id + suffix);
            InputStream is = client.newCall(
                    new Request.Builder().url(url).build()
            ).execute().body().byteStream();
            FileOutputStream os = new FileOutputStream(dest);
            byte[] bytes = new byte[2048];
            int len;
            while ((len = is.read(bytes)) != -1) {
                os.write(bytes, 0, len);
            }
            is.close();
            os.close();
            Uri uri = Uri.fromFile(dest);
            sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE).setData(uri));
            toast("下载完成");
            WallpaperHelper.set(this, uri);
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
