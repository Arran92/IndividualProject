//
//  TempViewController.m
//  SIAccelerometer
//
//  Created by Arran Purewal on 05/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "TempViewController.h"
#import "Sensor.h"

NSString *tempService = @"F000AA00-0451-4000-B000-000000000000";
NSString *tempConfig = @"F000AA02-0451-4000-B000-000000000000";
NSString *tempData = @"F000AA01-0451-4000-B000-000000000000";

@interface TempViewController ()
@property (strong,nonatomic) CBCentralManager *myCentralManager;
@property (strong,nonatomic) CBPeripheral *peripheralDevice;

@end

@implementation TempViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
   
    self.tempLabel.text = [NSString stringWithFormat:@"Processing data..."];
    if(self.startScan) {
        _myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBCentralManager delegate methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if(central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"ready to start scanning");
       
        [_myCentralManager scanForPeripheralsWithServices:nil options:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *deviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if([deviceName isEqualToString:@"SensorTag"]) {
        self.peripheralDevice = peripheral;
        self.peripheralDevice.delegate = self;
        [self.myCentralManager stopScan];
        [_myCentralManager connectPeripheral:peripheral options:nil];

        
    }
    
    //otherwise discovering other peripherals
    else {
        NSString *otherDeviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
        if(otherDeviceName != NULL) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Discovered %@, which is the wrong device",otherDeviceName] message:@"Turn the peripheral off" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:^{
               //do action on completion handler
                [_myCentralManager scanForPeripheralsWithServices:nil options:nil];
            }];
            
            
        }
    }
    
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [peripheral setDelegate:self];
    NSArray *services = [[NSArray alloc] initWithObjects:[CBUUID UUIDWithString:tempService], nil];
    
    if(peripheral.state == CBPeripheralStateConnected) {
        self.connectedLabel.text = [NSString stringWithFormat:@"Connected"];
        
        //only want to find temperature here parameter not set to nil
        [peripheral discoverServices:services];
    
    }
    
    if(peripheral.state == CBPeripheralStateDisconnected)
        NSLog(@"DISCONNECTED");
}


#pragma mark - CBPeripheral delegate methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    //verify that it is the service
    for(CBService *service in peripheral.services) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:tempService]]) {
            NSLog(@"found the temp service");
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    int numberToEncode = 1;
    NSData *data = [NSData dataWithBytes:&numberToEncode length:sizeof(u_int8_t)];
    

    for(CBCharacteristic *characteristic in service.characteristics) {
        
        //want to write the value the config to 1 to be able to read values
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:tempConfig]]) {
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            
            
        }
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:tempData]]) {
            //read the value now
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
        
        
    }
    
    
}

//to read the value and set the temp label
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:tempData]]) {
        if(characteristic.value == nil)
            return;
        
        float tAmb = [sensorTMP006 calcTAmb:characteristic.value];
        self.tempLabel.text = [NSString stringWithFormat:@"%0.1f\u2070C",tAmb];
    }
    
    
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:tempData]]) {
        float tAmb = [sensorTMP006 calcTAmb:characteristic.value];
        self.tempLabel.text = [NSString stringWithFormat:@"%0.1f\u2070C",tAmb];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if(error) {
        NSLog(@"error when writing config: %@",error);
    }
    
    
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
