//
//  MySliderView.h
//  RentCar
//
//  Created by ffm on 16/11/10.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderControlDelegate.h"


@interface MySliderView : UIView

@property (nonatomic, weak) id<SliderControlDelegate>delegate;

@end
