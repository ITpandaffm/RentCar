//
//  CarAnotationView.m
//  RentCar
//
//  Created by ffm on 16/11/12.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import "CarAnotationView.h"

@implementation CarAnotationView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
  
}

- (instancetype)initWithFrame:(CGRect)frame annotationPic:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIImageView *carView = [[UIImageView alloc] initWithImage:image];
        carView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self addSubview:carView];
    }
    return self;
}

@end
