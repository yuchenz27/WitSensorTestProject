//
//  WitSensorManager.swift
//  WitSensorTestProject
//
//  Created by Yuchen Zhang on 2023/2/13.
//

import Foundation
import CoreBluetooth
import WitSDK

class WitSensorManager : ObservableObject, IBluetoothEventObserver, IBwt901bleRecordObserver {
    
    var bluetoothManager:WitBluetoothManager = WitBluetoothManager.instance
    
    @Published var deviceList:[Bwt901ble] = [Bwt901ble]()
    
    func scanDevices() {
        print("Start scanning for surrounding bluetooth devices...");
        removeAllDevices()
        self.bluetoothManager.registerEventObserver(observer: self)
        self.bluetoothManager.startScan()
    }
    
    // Stop scanning for devices
    func stopScan(){
        // removes a Bluetooth event observer
        self.bluetoothManager.removeEventObserver(observer: self)
        // Remove listening for newly found sensors
        self.bluetoothManager.stopScan()
        removeAllDevices()
    }
    
    // Remove all devices
    func removeAllDevices() {
        for item in deviceList {
            closeDevice(bwt901ble: item)
        }
        deviceList.removeAll()
    }
    
    // Turn on the device
    func openDevice(bwt901ble: Bwt901ble?){
        print("Turn on the device")
        
        do {
            try bwt901ble?.openDevice()
            // Monitor data
            bwt901ble?.registerListenKeyUpdateObserver(obj: self)
        }
        catch{
            print("Failed to open device")
        }
    }
    
    // Turn off the device
    func closeDevice(bwt901ble: Bwt901ble?){
        print("Turn off the device")
        bwt901ble?.closeDevice()
    }
    
    // Returns true if this device has not been found before
    func isNotFound(_ bluetoothBLE: BluetoothBLE?) -> Bool {
        for device in deviceList {
            if device.mac == bluetoothBLE?.mac {
                return false
            }
        }
        return true
    }
    
    // MARK: IBluetoothEventObserver
    // This method is called when a Bluetooth Low Energy sensor is found
    func onFoundBle(bluetoothBLE: WitSDK.BluetoothBLE?) {
        if isNotFound(bluetoothBLE) {
            print("Found a bluetooth device: \(String(describing: bluetoothBLE?.peripheral.name))")
            self.deviceList.append(Bwt901ble(bluetoothBLE: bluetoothBLE))
        }
    }
    
    // You will be notified here when the connection is successful
    func onConnected(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("\(String(describing: bluetoothBLE?.peripheral.name)) connection succeeded")
    }
    
    // Notifies you here when the connection fails
    func onConnectionFailed(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("\(String(describing: bluetoothBLE?.peripheral.name)) Connection failed")
    }
    
    // You will be notified here when the connection is lost
    func onDisconnected(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("\(String(describing: bluetoothBLE?.peripheral.name)) disconnected")
    }
    
    // MARK: IBwt901bleRecordObserver
    func onRecord(_ bwt901ble: WitSDK.Bwt901ble) {
        print("onRecord \(ProcessInfo.processInfo.systemUptime)")
    }
}
