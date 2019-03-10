package com.yaerin.daily_pics.service;

import android.os.Build;
import android.service.quicksettings.TileService;

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
        // TODO: 2019/3/3 Yaerin: Tile 逻辑
    }
}
