//
//  MyAnnotation.h
//  RentCar
//
//  Created by ffm on 16/11/13.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>


@property (nonatomic, ) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) int carGroup;






@end
