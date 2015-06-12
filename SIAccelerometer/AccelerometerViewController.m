//
//  AccelerometerViewController.m
//  SIAccelerometer
//
//  Created by Arran Purewal on 05/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "AccelerometerViewController.h"
#import "Sensor.h"



NSString *accService = @"F000AA10-0451-4000-B000-000000000000";
NSString *accConfig = @"F000AA12-0451-4000-B000-000000000000";
NSString *accData = @"F000AA11-0451-4000-B000-000000000000";
NSString *accPeriod = @"F000AA13-0451-4000-B000-000000000000";

NSString *keysService = @"FFE0";
NSString *keysPressState = @"FFE1";

//added some comments for the git push
@interface AccelerometerViewController () {
    
    int buttonCount;
}

@end

@implementation AccelerometerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
//    _adjustableNumber = arc4random() % 20;
//    
//    self.numberLabel.text = [NSString stringWithFormat:@"%i",_adjustableNumber];
  
    
    if(_start)
        _accManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    
   
}

#pragma mark - CBCentralManager methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if(central.state == CBCentralManagerStatePoweredOn) {
         [_accManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *deviceName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    //connect and set the characteristics to look for
    if([deviceName isEqualToString:@"SensorTag"]) {
        self.peripheralDevice = peripheral;
        self.peripheralDevice.delegate = self;
        [self.accManager stopScan];
        [_accManager connectPeripheral:peripheral options:nil];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [peripheral setDelegate:self];
    NSArray *accArray = [[NSArray alloc]initWithObjects:[CBUUID UUIDWithString:accService],[CBUUID UUIDWithString:keysService], nil];
    [peripheral discoverServices:accArray];
    
}


#pragma mark - CBPeripheral methods

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for(CBService* service in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    //write to config and then read
    for(CBCharacteristic* chars in service.characteristics) {
        if([chars.UUID isEqual:[CBUUID UUIDWithString:accConfig]]) {
            int state = 1;
            NSData *encode = [NSData dataWithBytes:&state length:sizeof(u_int8_t)];
            [self.peripheralDevice writeValue:encode forCharacteristic:chars type:CBCharacteristicWriteWithResponse];
        }
        
        //setting the period between readings to be 300ms
        if([chars.UUID isEqual:[CBUUID UUIDWithString:accPeriod]]) {
            int period = 30;
            NSData *periodToSet = [NSData dataWithBytes:&period length:sizeof(u_int8_t)];
            [self.peripheralDevice writeValue:periodToSet forCharacteristic:chars type:CBCharacteristicWriteWithResponse];
        }
        
        if([chars.UUID isEqual:[CBUUID UUIDWithString:accData]]) {
            [self.peripheralDevice setNotifyValue:YES forCharacteristic:chars];

        }
        
        if([chars.UUID isEqual:[CBUUID UUIDWithString:keysPressState]]) {
            [self.peripheralDevice setNotifyValue:YES forCharacteristic:chars];
        }
        
    }
        
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if(error) {
        NSLog(@"there's an error %@",error);
    }
//    if(!error && [characteristic.UUID isEqual:[CBUUID UUIDWithString:accConfig]])
//        NSLog(@"written the configuration value");
//    
//     if([characteristic.UUID isEqual:[CBUUID UUIDWithString:accPeriod]]) {
//         NSLog(@"the period has been set");
//     }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    float oldX, oldY, oldZ;
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:accData]]) {
        float x = [sensorKXTJ9 calcXValue:characteristic.value];
        float y = [sensorKXTJ9 calcYValue:characteristic.value];
        float z = [sensorKXTJ9 calcZValue:characteristic.value];
        
        if(y > (oldY + 0.2))
        {
            _adjustableNumber++;
        }
        
        if(y < (oldY - 0.2))
        {
            _adjustableNumber--;
        }
        oldX = x;
        oldY = y;
        oldZ = z;
        
        self.numberLabel.text = [NSString stringWithFormat:@"%i",_adjustableNumber];
        
        
        //printing the accelerometer values to screen
        self.xAcc.text = [NSString stringWithFormat:@"%0.1f",x];
        self.yAcc.text = [NSString stringWithFormat:@"%0.1f",y];
        self.zAcc.text = [NSString stringWithFormat:@"%0.1f",z];
    }
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:keysPressState]]) {
        
        ++buttonCount;
        
        
        //indicates button has been pressed
        if(buttonCount == 2) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Answer" message:@"Answer entered" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *correct = [UIAlertAction actionWithTitle:@"Correct Answer!" style:UIAlertActionStyleDefault handler:nil];
            
            UIAlertAction *wrong = [UIAlertAction actionWithTitle:@"Wrong estimate" style:UIAlertActionStyleDefault handler:nil];
            
            //try and make the button unpressable until correct answer foundena
            if(_adjustableNumber == _numberOfDots) {
                
                self.dotsButton.enabled = YES;
                [alert addAction:correct];
            }
            
            
            //show the user the dots again, so add a method that returns the same number of dots to the screen again
            else
                [alert addAction:wrong];
            
            
            [self presentViewController:alert animated:YES completion:^{
               
                //reset for the next game in here
                buttonCount = 0;
                NSLog(@"the value of the adjustableNumber: %i, and the numberOfDots: %i",_adjustableNumber,_numberOfDots);
                
            }];
        }
        
    }
    
}


//if subscribe to a characteristic
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (IBAction)dotButton:(id)sender {
    
    self.dotsButton.enabled = NO;
    
    DotCollectionViewController *dotController = [self.storyboard instantiateViewControllerWithIdentifier:@"DotCollectionView"];
    dotController.countDown = 4;
    dotController.delegate = self;
    [self presentViewController:dotController animated:YES completion:nil];
    
}



#pragma mark - Navigation

- (void)passInfoBack:(DotCollectionViewController *)controller dots:(int)dots randomNumber:(int)randomNumber {
    _numberOfDots = dots;
    _adjustableNumber = randomNumber;
    NSLog(@"in the passBack ftn dots: %i and numberOfDots %i and adjustable %i",dots,_numberOfDots,_adjustableNumber);
}


@end
