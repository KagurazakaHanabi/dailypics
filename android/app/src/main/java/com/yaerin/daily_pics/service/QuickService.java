package com.yaerin.daily_pics.service;

import android.os.Build;
import android.service.quicksettings.TileService;
import android.widget.Toast;

import androidx.annotation.RequiresApi;

/**
 * Create by Yaerin on 2019/3/2
 *
 * @author Yaerin
 */
@RequiresApi(api = Build.VERSION_CODES.N)
public class QuickService extends TileService {
    @Override
    public void onClick() {
        Toast.makeText(this, "暂未实现", Toast.LENGTH_SHORT).show();
    }
}
