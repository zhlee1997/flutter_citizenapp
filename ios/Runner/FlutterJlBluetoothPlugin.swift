//
//  FlutterJlBluetoothPlugin.swift
//  Runner
//
//  Created by 周志伟 on 2021/8/7.
//

import Foundation
import Flutter

class FlutterJlBluetoothPlugin: NSObject, FlutterStreamHandler {
    
    static let plugin = FlutterJlBluetoothPlugin()
    var eSink:FlutterEventSink?
    var channel:FlutterEventChannel?
        
    func register(messenger: FlutterBinaryMessenger) {
        channel = FlutterEventChannel(name: "com.sma.citizen_mobile/pay", binaryMessenger: messenger)
        channel?.setStreamHandler(self)
    }
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eSink = nil
        return nil
    }
}
