//
//  ViewController.m
//  SIAccelerometer
//
//  Created by Arran Purewal on 05/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "ViewController.h"
#import "TempViewController.h"
#import "AccelerometerViewController.h"
#import "GyroscopeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tempButton:(id)sender {
    [self performSegueWithIdentifier:@"GoToTemp" sender:self];
    
}

- (IBAction)accelerometerButton:(id)sender {
    [self performSegueWithIdentifier:@"GoToAccelerometer" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"GoToTemp"]) {
        TempViewController *tempViewController = (TempViewController*) segue.destinationViewController;
        tempViewController.startScan = YES;
    }
    
    if([segue.identifier isEqualToString:@"GoToAccelerometer"]) {
        AccelerometerViewController *accViewController = (AccelerometerViewController*) segue.destinationViewController;
        accViewController.start = YES;
    }
    
    if([segue.identifier isEqualToString:@"GoToGyro"]) {
        GyroscopeViewController *gyro = (GyroscopeViewController*) segue.destinationViewController;
        gyro.scanning = YES;
    }
    
}

- (IBAction)gyroscopeButton:(id)sender {
    
    [self performSegueWithIdentifier:@"GoToGyro" sender:self];
}


- (IBAction)close:(UIStoryboardSegue*)segue {
    NSLog(@"closed");
}

@end
