package com.sioc.sma.flutter_citizenapp;

import androidx.annotation.NonNull;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.EventChannel;

import sharepay.paylibrary.BaseCallbackBean;
import sharepay.paylibrary.SarawakAPI;
import sharepay.paylibrary.SarawakPay;
import sharepay.paylibrary.SarawakPayCallback;

public class MainActivity extends FlutterActivity implements SarawakPayCallback {
    private static final String CHANNEL = "com.sma.citizen_mobile/main";
    private SarawakAPI mFactory;
    
    // Encrypted data, refer to Appendix II for how to encrypt and APP Payment Integration Manual Order Creation for parameters
    private String data = "";
    private Result resultDelegate;
    private MethodChannel methodChannel;
    EventChannel eventChannelPay;
    EventChannel.EventSink eventSinkS;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        final Context delegate = this;
        super.onCreate(savedInstanceState);
        //创建相应的对象
        mFactory = SarawakPay.createFactory(delegate);
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        eventChannelPay = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),"com.sma.citizen_mobile/pay");
        System.out.println(">>>>"+"configureFlutterEngine回调"+"<<<<");

        // EventChannel
        eventChannelPay.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
                System.out.println("init eventChannelPay onListen: " +  ">>>>" + "调用了成功回调" + "<<<<");
                System.out.println("init eventChannelPay mFactory: " +  mFactory);
                eventSinkS = eventSink;
            }

            @Override
            public void onCancel(Object o) {

            }
        });

        // MethodChannel: spayPlaceOrder
        methodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                resultDelegate = result;
                final Map<String, Object> arguments = methodCall.arguments();
                if (methodCall.method.equals("spayPlaceOrder")) {
                    String dataString = (String) arguments.get("dataString");
                    data = dataString;
                    sendRequest();
                }
            }
        });
    }
    
    //发送请求
    public void sendRequest() {
        System.out.println("spay java sendRequest: Exec sendRequest..");
        System.out.println("spay java sendRequest: " + mFactory);
        System.out.println("spay java sendRequest: " + data);
        //发送请求
        mFactory.sendReq(data, this);
    }

    @Override
    public void payResult(BaseCallbackBean baseCallbackBean) {
        //其中baseCallbackBean封装了相应的请求返回信息
        System.out.println("spay java payResult: " + baseCallbackBean.getFlag() + "<<<<<<<<<<<<<");
        if (eventSinkS != null) {
            System.out.println("spay java payResult: " + "调用了eventSinkS" + "<<<<<<<<<<<<<");
            eventSinkS.success(baseCallbackBean.getFlag());
        } else {
            System.out.println("spay java payResult: " + "eventSink空" + "<<<<<<<<<<<<<");
        }
        System.out.println("spay java payResult: " + "调用后resultDelegate" + "<<<<<<<<<<<<<");
        resultDelegate.success(baseCallbackBean.getFlag());
    }

    @Override
    protected void onDestroy() {
        System.out.println("Exec onDestroy..");
        super.onDestroy();
        if (mFactory != null) {
            mFactory.onDestroy();
        }
    }
}
