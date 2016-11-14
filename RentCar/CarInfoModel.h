//
//  CarInfoModel.h
//  RentCar
//
//  Created by ffm on 16/11/14.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarInfoModel : NSObject


@property (nonatomic, copy) NSString *carNumber;
@property (nonatomic, copy) NSString *carType;
@property (nonatomic, copy) NSString *carSeats;
@property (nonatomic, copy) NSString *carID;
@property (nonatomic, copy) NSString *carInfo;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)carModelWithDict:(NSDictionary *)dict;


@end
