//
//  GyroscopeViewController.h
//  SIAccelerometer
//
//  Created by Arran Purewal on 09/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "ViewController.h"
#import "Sensor.h"

@import CoreBluetooth;

@interface GyroscopeViewController : ViewController <CBCentralManagerDelegate,CBPeripheralDelegate>
@property (weak, nonatomic) IBOutlet UITextField *deltaX;
@property (weak, nonatomic) IBOutlet UITextField *deltaY;
@property (weak, nonatomic) IBOutlet UITextField *deltaZ;
@property (strong,nonatomic) CBCentralManager *gyroManager;
@property (strong,nonatomic) CBPeripheral *peripheralDevice;

@property (strong,nonatomic) sensorIMU3000 *gyroScope;

@property (assign) BOOL scanning;

#define GYRO @"F000AA50-0451-4000-B000-000000000000";

@end
