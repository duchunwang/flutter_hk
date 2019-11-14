package jinhx.cn.flutter_hk;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.PixelFormat;
import android.util.Log;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.SurfaceView;
import android.view.View;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import com.hikvision.netsdk.HCNetSDK;
import com.hikvision.netsdk.NET_DVR_PREVIEWINFO;

@SuppressLint("NewApi")
public class PlaySurfaceView extends SurfaceView implements PlatformView,MethodChannel.MethodCallHandler, Callback {
    private final MethodChannel channel;
    private final String TAG = "PlaySurfaceView";
    private boolean isPlaying = false;

    public int m_iPreviewHandle = -1;
    public boolean bCreate = false;


    public PlaySurfaceView(Context context, BinaryMessenger messenger, int id)
    {
        super(context);
        // TODO Auto-generated constructor stub
        getHolder().addCallback(this);

        channel = new MethodChannel(messenger, "flutter_hk/player_" + id);
        channel.setMethodCallHandler(this);
    }

    @Override
    public View getView() {
        return this;
    }

    @Override
    public void dispose() {
        this.stopPreview();
    }


    @Override
    public void surfaceChanged(SurfaceHolder arg0, int arg1, int arg2, int arg3)
    {
        // TODO Auto-generated method stub
        setZOrderOnTop(true);
        getHolder().setFormat(PixelFormat.TRANSLUCENT);
        System.out.println("surfaceChanged");
    }

    @Override
    public void surfaceCreated(SurfaceHolder arg0)
    {
        // TODO Auto-generated method stub
        bCreate = true;
        System.out.println("surfaceCreated");
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder arg0)
    {
        // TODO Auto-generated method stub
        System.out.println("surfaceDestroyed");
        bCreate = false;

    }

    public void startPreview(int iUserID, int iChan)
    {
        Log.i(TAG, "preview channel:" + iChan);
        while (!bCreate)
        {
            try
            {
                Thread.sleep(100);
                Log.i(TAG, "wait for surface create");
            }
            catch (InterruptedException e)
            {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        NET_DVR_PREVIEWINFO previewInfo = new NET_DVR_PREVIEWINFO();
        previewInfo.lChannel = iChan;
        previewInfo.dwStreamType = 1; // substream
        previewInfo.bBlocked = 1;
        previewInfo.hHwnd = this.getHolder();

        // HCNetSDK start preview
        m_iPreviewHandle = HCNetSDK.getInstance().NET_DVR_RealPlay_V40(iUserID, previewInfo, null);
        if (m_iPreviewHandle < 0)
        {
            Log.e(TAG, "NET_DVR_RealPlay is failed!Err:" + HCNetSDK.getInstance().NET_DVR_GetLastError());
        }
        this.isPlaying = true;
        Log.i(TAG, "NET_DVR_RealPlay is success");
    }

    public void stopPreview()
    {
        HCNetSDK.getInstance().NET_DVR_StopRealPlay(m_iPreviewHandle);
        this.isPlaying = false;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method){
            case "play":
                Log.i(TAG, "play");
                int iUserID = methodCall.argument("iUserID");
                int ichan = methodCall.argument("iChan");
                this.startPreview(iUserID, ichan);
                result.success(null);
                break;
            case "stop":
                Log.i(TAG, "stop");
                this.stopPreview();
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }
}
