//
//  SliderControlDelegate.h
//  RentCar
//
//  Created by ffm on 16/11/11.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySliderView.h"

@class MySliderView;

@protocol SliderControlDelegate <NSObject>

@required
- (void)sliderControl:(MySliderView *)sliderControlView moveToPosition:(int)position;

@end


