//
//  AccelerometerViewController.h
//  SIAccelerometer
//
//  Created by Arran Purewal on 05/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DotCollectionViewController.h"
@import CoreBluetooth;

@interface AccelerometerViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, SetVariablesDelegate>

@property (strong,nonatomic) CBCentralManager *accManager;
@property (strong,nonatomic) CBPeripheral *peripheralDevice;
@property (weak, nonatomic) IBOutlet UITextField *xAcc;
@property (weak, nonatomic) IBOutlet UITextField *yAcc;
@property (weak, nonatomic) IBOutlet UITextField *zAcc;
@property (assign) BOOL start;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (assign) int adjustableNumber;
@property (assign) int numberOfDots;
@property (weak, nonatomic) IBOutlet UIButton *dotsButton;


@end
