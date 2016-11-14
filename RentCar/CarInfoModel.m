//
//  CarInfoModel.m
//  RentCar
//
//  Created by ffm on 16/11/14.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import "CarInfoModel.h"

@implementation CarInfoModel

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)carModelWithDict:(NSDictionary *)dict
{
    return [[CarInfoModel alloc] initWithDict:dict];
}


@end
