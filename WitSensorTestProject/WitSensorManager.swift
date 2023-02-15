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
    
    var dataReceptionCount: Int = 0
    
    var startTime: Double = 0
    
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
            self.startTime = ProcessInfo.processInfo.systemUptime
        }
        catch{
            print("Failed to open device")
        }
    }
    
    // Get the data of the device and concatenate it into a string
    func getDeviceDataToString(_ device:Bwt901ble) -> String {
        var s = ""
        s  = "\(s)Device name:\(device.name ?? "")\r"
        s  = "\(s)Device Bluetooth address:\(device.mac ?? "")\r"
        //s  = "\(s)Version number:\(device.getDeviceData(WitSensorKey.VersionNumber) ?? "")\r\n"
        s  = "\(s)Acceleration X:\(device.getDeviceData(WitSensorKey.AccX) ?? "") g\r"
        s  = "\(s)Acceleration Y:\(device.getDeviceData(WitSensorKey.AccY) ?? "") g\r"
        s  = "\(s)Acceleration Z:\(device.getDeviceData(WitSensorKey.AccZ) ?? "") g\r"
//        s  = "\(s)Angular velocity X:\(device.getDeviceData(WitSensorKey.GyroX) ?? "") °/s\r\n"
//        s  = "\(s)Angular velocity Y:\(device.getDeviceData(WitSensorKey.GyroY) ?? "") °/s\r\n"
//        s  = "\(s)Angular velocity Z:\(device.getDeviceData(WitSensorKey.GyroZ) ?? "") °/s\r\n"
        s  = "\(s)Angle X:\(device.getDeviceData(WitSensorKey.AngleX) ?? "") °\r"
        s  = "\(s)Angle Y:\(device.getDeviceData(WitSensorKey.AngleY) ?? "") °\r"
        s  = "\(s)Angle Z:\(device.getDeviceData(WitSensorKey.AngleZ) ?? "") °\r"
        s  = "\(s)Magnetic field X:\(device.getDeviceData(WitSensorKey.MagX) ?? "") μt\r"
        s  = "\(s)Magnetic field Y:\(device.getDeviceData(WitSensorKey.MagY) ?? "") μt\r"
        s  = "\(s)Magnetic field Z:\(device.getDeviceData(WitSensorKey.MagZ) ?? "") μt\r"
        s  = "\(s)Electricity:\(device.getDeviceData(WitSensorKey.ElectricQuantityPercentage) ?? "") %\r"
        s  = "\(s)Temperature:\(device.getDeviceData(WitSensorKey.Temperature) ?? "") °C\r"
        return s
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
        self.startTime = ProcessInfo.processInfo.systemUptime
    }
    
    // Notifies you here when the connection fails
    func onConnectionFailed(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("\(String(describing: bluetoothBLE?.peripheral.name)) connection failed")
    }
    
    // You will be notified here when the connection is lost
    func onDisconnected(bluetoothBLE: WitSDK.BluetoothBLE?) {
        print("\(String(describing: bluetoothBLE?.peripheral.name)) disconnected")
    }
    
    // MARK: IBwt901bleRecordObserver
    func onRecord(_ bwt901ble: WitSDK.Bwt901ble) {
        self.dataReceptionCount += 1
        let duration = ProcessInfo.processInfo.systemUptime - self.startTime
        let frequency = Double(self.dataReceptionCount) / duration
        //print("count: \(self.dataReceptionCount) duration: \(duration)")
        print("frequency: \(frequency)")
        
        let deviceData = getDeviceDataToString(bwt901ble)
        print(deviceData)
    }
}
