//
//  DotCollectionViewController.h
//  SIAccelerometer
//
//  Created by Arran Purewal on 11/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DotCollectionViewController;
@protocol SetVariablesDelegate <NSObject>

- (void)passInfoBack:(DotCollectionViewController*)controller dots:(int)dots randomNumber:(int)randomNumber;

@end

@interface DotCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (strong,nonatomic) NSTimer *timer;
@property (assign) int countDown;
@property (weak,nonatomic) id<SetVariablesDelegate>delegate;
@property (assign) int howManyDots;


- (void)timerCheck;


@end
