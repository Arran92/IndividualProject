//
//  DotCell.m
//  SIAccelerometer
//
//  Created by Arran Purewal on 10/06/2015.
//  Copyright (c) 2015 Arran Purewal. All rights reserved.
//

#import "DotCell.h"

@implementation DotCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.imageView.image = [UIImage imageNamed:@"dot.png"]
    }
}

@end
