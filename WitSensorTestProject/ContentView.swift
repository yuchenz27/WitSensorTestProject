//
//  ContentView.swift
//  WitSensorTestProject
//
//  Created by Yuchen Zhang on 2023/2/13.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var witSensorManager = WitSensorManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            scanButton
            
            deviceList
        }
        .padding()
    }
    
    var scanButton: some View {
        Button("Scan Devices") {
            witSensorManager.scanDevices()
        }
    }
    
    var deviceList: some View {
        VStack {
            Text("Device list")
            
            if let sensor = witSensorManager.deviceList.first {
                Button("Connect") {
                    witSensorManager.openDevice(bwt901ble: sensor)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
