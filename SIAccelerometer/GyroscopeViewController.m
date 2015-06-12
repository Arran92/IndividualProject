//
//  GyroscopeViewController.m
//  SIAccelerometer
//
//  Created by Arran Purewal on 09/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "GyroscopeViewController.h"


NSString *gyroService = @"F000AA50-0451-4000-B000-000000000000";
NSString *gyroConfig = @"F000AA52-0451-4000-B000-000000000000";
NSString *gyroData = @"F000AA51-0451-4000-B000-000000000000";


@interface GyroscopeViewController ()

@end

@implementation GyroscopeViewController
    


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.gyroScope = [[sensorIMU3000 alloc]init];
    [self.gyroScope calibrate];
    
    if(_scanning) {
        _gyroManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
    
    
}


#pragma CBCentralManager protocol methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if(central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"ready to start scanning");
        [_gyroManager scanForPeripheralsWithServices:nil options:nil];
    }
  
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *peripheralName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    //ready to connect and set peripheral delegate
    if([peripheralName isEqualToString:@"SensorTag"]) {
        self.peripheralDevice = peripheral;
        self.peripheralDevice.delegate = self;
        [_gyroManager stopScan];
        [_gyroManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"connected to the peripheral, will discover gyro service");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];

    
}


#pragma CBPeripheral protocol methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for(CBService *service in peripheral.services) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:gyroService]]) {
            NSLog(@"found the gyro service");
            [peripheral discoverCharacteristics:nil forService:service];
            
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for(CBCharacteristic *chars in service.characteristics) {
        if([chars.UUID isEqual:[CBUUID UUIDWithString:gyroConfig]]) {
            int configType = 7;
            NSData *encodeThis = [NSData dataWithBytes:&configType length:sizeof(u_int8_t)];
            [self.peripheralDevice writeValue:encodeThis forCharacteristic:chars type:CBCharacteristicWriteWithResponse];
        }
        
        if([chars.UUID isEqual:[CBUUID UUIDWithString:gyroData]]) {
            [self.peripheralDevice setNotifyValue:YES forCharacteristic:chars];
        }
        
        
        
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    
    
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:gyroData]]) {
        float x = [_gyroScope calcXValue:characteristic.value];
        float y = [_gyroScope calcYValue:characteristic.value];
        float z = [_gyroScope calcZValue:characteristic.value];
    
    
    self.deltaX.text = [NSString stringWithFormat:@"%0.2f°/S",x];
    self.deltaY.text = [NSString stringWithFormat:@"%0.2f°/S",y];
    self.deltaZ.text = [NSString stringWithFormat:@"%0.2f°/S",z];
    
    }

    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if(error)
        NSLog(@"error writing the config: %@",error);
    
    if(!error)
        NSLog(@"writing the config was successful");
    
}











/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
