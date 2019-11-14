package jinhx.cn.flutter_hk;

import android.util.Log;

import com.hikvision.netsdk.ExceptionCallBack;
import com.hikvision.netsdk.HCNetSDK;
import com.hikvision.netsdk.NET_DVR_DEVICEINFO_V30;
import com.hikvision.netsdk.NET_DVR_PICCFG_V30;

import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class HkController implements MethodChannel.MethodCallHandler {
    private final MethodChannel channel;
    private int m_iLogID = -1; // return by NET_DVR_Login_v30
    private final String TAG = "hk";
    private int m_iStartChan = 0; // start channel number
    private int m_iChanNum = 0;
    private String name;

    HkController(String name, BinaryMessenger messenger){
        this.name = name;
        channel = new MethodChannel(messenger, "flutter_hk/controller_" + name);
        channel.setMethodCallHandler(this);
        Log.e(TAG, "HkController:"+name);
    }

    @Override
    protected void finalize(){
        Log.e(TAG, "-HkController:"+name);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Map<Object,Object> ret;
        Log.e("ctrl1", call.method);
        switch (call.method){
            case "login":
                String ip = call.argument("ip");
                int port = call.argument("port");
                String user = call.argument("user");
                String psd = call.argument("psd");
                try {
                    ret = new HashMap<>();
                    ret.put(0, this.login(ip, port, user, psd));
                    result.success(ret);
                }catch (Exception err){
                    result.error("ERR", err.getMessage(), null);
                }
                break;
            case "logout":
                this.logout();
                result.success(null);
                break;
            case "getChans":
                ret = this.getChans();
                result.success(ret);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private int login(String ip, int port, String user, String psd)throws Exception{
        try {
            // login on the device
            m_iLogID = loginDevice(ip, port, user, psd);
            if (m_iLogID < 0)
            {
                Log.e(TAG, "This device logins failed!");
                throw new Exception("This device logins failed!");
            }
            else
            {
                Log.i(TAG, "m_iLogID=" + m_iLogID);
            }
            // get instance of exception callback and set
            ExceptionCallBack oexceptionCbf = getExceptiongCbf();
            if (oexceptionCbf == null)
            {
                Log.e(TAG, "ExceptionCallBack object is failed!");
                throw new Exception("ExceptionCallBack object is failed!");
            }

            if (!HCNetSDK.getInstance().NET_DVR_SetExceptionCallBack(oexceptionCbf))
            {
                Log.e(TAG, "NET_DVR_SetExceptionCallBack is failed!");
                throw new Exception("ExceptionCallBack object is failed!");
            }

            Log.i(TAG, "Login sucess");
            return m_iLogID;

        }
        catch (Exception err)
        {
            Log.e(TAG, "error: " + err.toString());
            throw err;
        }
    }

    private boolean logout(){
        try{
            if (this.m_iLogID >= 0 && !HCNetSDK.getInstance().NET_DVR_Logout_V30(m_iLogID))
            {
                Log.e(TAG, " NET_DVR_Logout is failed!");
                //if (!HCNetSDKJNAInstance.getInstance().NET_DVR_DeleteOpenEzvizUser(m_iLogID)) {
                //		Log.e(TAG, " NET_DVR_DeleteOpenEzvizUser is failed!");
                return false;
            }
            Log.e(TAG, " NET_DVR_Logout is success!"+this.m_iLogID);
            m_iLogID = -1;
            return true;
        }catch (Exception err)
        {
            Log.e(TAG, "error: " + err.toString());
            throw err;
        }
    }

    /**
     * @fn loginDevice
     * @author zhangqing
     * @brief login on device
     * @return login ID
     */
    private int loginDevice(String ip, int port, String user, String psd)throws Exception
    {
        int iLogID = -1;
        NET_DVR_DEVICEINFO_V30 m_oNetDvrDeviceInfoV30 = new NET_DVR_DEVICEINFO_V30();
        if (null == m_oNetDvrDeviceInfoV30)
        {
            Log.e(TAG, "HKNetDvrDeviceInfoV30 new is failed!");
            throw new Exception("HKNetDvrDeviceInfoV30 new is failed!");
        }
        String strIP = ip;
        int nPort = port;
        String strUser = user;
        String strPsd = psd;

        // call NET_DVR_Login_v30 to login on, port 8000 as default
        iLogID = HCNetSDK.getInstance().NET_DVR_Login_V30(strIP, nPort, strUser, strPsd, m_oNetDvrDeviceInfoV30);
        if (iLogID < 0)
        {
            int ret = getLastError();
            Log.e(TAG, "NET_DVR_Login is failed!Err:" + ret);
            throw new Exception("NET_DVR_Login is failed!Err:" + ret);
        }

        if (m_oNetDvrDeviceInfoV30.byChanNum > 0)
        {
            m_iStartChan = m_oNetDvrDeviceInfoV30.byStartChan;
            m_iChanNum = m_oNetDvrDeviceInfoV30.byChanNum;
        }
        else if (m_oNetDvrDeviceInfoV30.byIPChanNum > 0)
        {
            m_iStartChan = m_oNetDvrDeviceInfoV30.byStartDChan;
            m_iChanNum = m_oNetDvrDeviceInfoV30.byIPChanNum + m_oNetDvrDeviceInfoV30.byHighDChanNum * 256;
        }

        Log.i(TAG, "NET_DVR_Login is Successful!");
        return iLogID;
    }

    private Map<Object,Object> getChans(){
        Log.i(TAG, "getChans is starting!");
        NET_DVR_PICCFG_V30 net_dvr_piccfg_v30 = new NET_DVR_PICCFG_V30();
        Map<Object,Object> chans = new HashMap<>();
        for (int i = this.m_iStartChan; i<this.m_iStartChan+this.m_iChanNum;i++){
            try {
                HCNetSDK.getInstance().NET_DVR_GetDVRConfig(this.m_iLogID, HCNetSDK.NET_DVR_GET_PICCFG_V30, i, net_dvr_piccfg_v30);
                chans.put(i, new String(net_dvr_piccfg_v30.sChanName, "GBK"));
            }catch (UnsupportedEncodingException ex){
                continue;
            }
        }
        Log.i(TAG, "getChans is Successful!");
        return chans;
    }


    /**
     * @fn getExceptiongCbf
     * @author zhuzhenlei
     * @brief process exception
     * @return exception instance
     */
    private ExceptionCallBack getExceptiongCbf()
    {
        ExceptionCallBack oExceptionCbf = new ExceptionCallBack()
        {
            public void fExceptionCallBack(int iType, int iUserID, int iHandle)
            {
                System.out.println("recv exception, type:" + iType);
            }
        };
        return oExceptionCbf;
    }

    /**
     *
     * @return err的-值
     */
    private int getLastError(){
        return -HCNetSDK.getInstance().NET_DVR_GetLastError();
    }
}
