//
//  ViewController.m
//  RentCar
//
//  Created by ffm on 16/11/11.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

#import "ViewController.h"
#import "MySliderView.h"
#import "SliderControlDelegate.h"
#import "CarAnotationView.h"
@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, SliderControlDelegate>

@property (nonatomic, strong)MKMapView *mapView;
@property (nonatomic, strong)CLLocationManager *locationManager;


@end

@implementation ViewController
{
    int CurrentCarGroup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CurrentCarGroup = 1;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    
    switch (status)
    {
        case 0:
            [self.locationManager requestWhenInUseAuthorization];
        case 3:
        case 4:
            [self startLocate];
            break;
        case 1:
        case 2:
            NSLog(@"ooops，你打开定位权限了嘛？");
            break;
        default:
            NSLog(@"获取权限失败，请检查你的设置");
            break;
    }
    
    
}

//大头针
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    CarAnotationView *carAnotationView = [[CarAnotationView alloc] initWithFrame:CGRectMake(0, 0, 45, 45) annotationPic:[UIImage imageNamed:[NSString stringWithFormat:@"car%d", CurrentCarGroup]]];
    carAnotationView.backgroundColor = [UIColor clearColor];
    return carAnotationView;
}


#pragma mark Location Methods
- (void)startLocate
{
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
//    NSLog(@"更新定位成功~");
}

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"定位用户位置成功~");
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    NSLog(@"didAddAnnotationViews");
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"calloutAccessoryControlTapped");
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didSelectAnnotationView %@",view.description);
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"didDeselectAnnotationView %@",view.description);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    
}





#pragma mark SliderControlDelegate
- (void)sliderControl:(MySliderView *)sliderControlView moveToPosition:(int)position
{
    NSLog(@"现在移动到%d", position);
    CurrentCarGroup = position;
}


#pragma mark 懒加载
- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (MKMapView *)mapView
{
    if (!_mapView)
    {
        CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-100);
        _mapView = [[MKMapView alloc] initWithFrame:rect];
        _mapView.delegate = self;
        [self.view addSubview:_mapView];
        
        //创建下方SliderControlView滑条
        MySliderView *sliderView = [[MySliderView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-100, [UIScreen mainScreen].bounds.size.width, 100)];
        sliderView.delegate = self;
        [self.view addSubview:sliderView];
    }
    return _mapView;
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
