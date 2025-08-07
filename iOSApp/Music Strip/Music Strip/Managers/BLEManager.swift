//
//  BLEManager.swift
//  Music Strip
//
//  Created by Suraj Laddagiri  on 8/6/25.
//


import Foundation
import CoreBluetooth
import SwiftUI

enum BluetoothError: Error {
    case unknown, off
}
let serviceID = CBUUID(string: "54df84fc-7f55-4867-bb29-617f9d2a7925")

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    private var manager: CBCentralManager!
    private var ESP32: CBPeripheral?
    private var MainService: CBService?
    private var MainCharacteristic: CBCharacteristic?
    private var writeableCharacteristic: CBCharacteristic?
    @Published var peripherals = [CBPeripheral]()
    private var peripheral_IDs: Set<UUID> = []
    @Published var connected = false
    var appState: AppState?
    @Published var FinishedAuto = false
    init(appState: AppState) {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
        self.appState = appState
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unkown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
                do{
                    try self.autoScanning()
                }catch{
                
                }
            @unknown default:
                print("default")
        }
    }
    
    
    
    func autoScanning() throws{
        print("Autoscanning Started")
        if manager.state == .poweredOff {
            throw BluetoothError.off
        }else if manager.state != .poweredOn {
            throw BluetoothError.unknown
        }
        manager.scanForPeripherals(withServices: [serviceID])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.manager.stopScan()
            print("Autoscanning Stopped")
            if !(self.peripherals.count == 1) {
                self.peripherals.removeAll()
                self.peripheral_IDs.removeAll()
                withAnimation{
                    self.FinishedAuto = true
                }
            }else{
                print(self.peripherals[0])
                self.connect(to: self.peripherals[0])
            }
            
        }
    }
    
    
    
    func startScanning() throws{
        if manager.state == .poweredOff {
            throw BluetoothError.off
        }else if manager.state != .poweredOn {
            throw BluetoothError.unknown
        }
        manager.scanForPeripherals(withServices: [serviceID])
    }
    func connect(to p:CBPeripheral){
        ESP32 = p
        manager.connect(p)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceID])
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        appState!.currPage = .Error
    }
    
    
    func stopScanning(){
        manager.stopScan()
        peripheral_IDs.removeAll()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber){
        if !peripheral_IDs.contains(peripheral.identifier){
            peripheral_IDs.insert(peripheral.identifier)
            print(peripheral)
            let scanned = peripheral.name ?? "Unknown Device"
            if scanned != "Unknown Device"{
                withAnimation{
                    peripherals.append(peripheral)
                }
            }
            
        }
    }
    
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else {return}
        for service in services {
            MainService = service
            print(service)
        }
        peripheral.discoverCharacteristics(nil, for: MainService!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard let characteristics = service.characteristics else {return}
        for characteristic in characteristics {
            MainCharacteristic = characteristic
            print(characteristic.properties.contains(.read))
            print(characteristic.properties.contains(.write))
            print(characteristic.properties.contains(.writeWithoutResponse))
        }
        withAnimation{
            appState?.currPage = .ManualControl
        }
        withAnimation{
            connected = true
        }
        withAnimation{
            FinishedAuto = true
        }
        
    }
    
    
    func disconnect(){
        //manager.cancelPeripheralConnection(ESP32!)
        //connected = false
        //FinishedAuto = true
        print("NOT WORKING!!!!!!!")
    }
    
    func sendCommand(_ command: String) {
        guard let peripheral = ESP32 else {return}
        peripheral.writeValue(Data(command.utf8), for: MainCharacteristic!, type: .withResponse)
    }
    
}
