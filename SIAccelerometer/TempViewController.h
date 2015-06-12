//
//  TempViewController.h
//  SIAccelerometer
//
//  Created by Arran Purewal on 05/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;

@interface TempViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (assign) BOOL startScan;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectedLabel;


@end
