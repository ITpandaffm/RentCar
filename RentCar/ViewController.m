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
#import "MyAnnotation.h"

#define LATTITUDE 41.76
#define LONGITUDE 123.41

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, SliderControlDelegate>

@property (nonatomic, strong)MKMapView *mapView;
@property (nonatomic, strong)CLLocationManager *locationManager;


@property (nonatomic, strong) NSArray *carAnnotationGroup1;
@property (nonatomic, strong) NSArray *carAnnotationGroup2;

@property (weak, nonatomic) IBOutlet UIButton *zoomInBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutBtn;

@property (weak, nonatomic) IBOutlet UIButton *locateBtn;

@end

@implementation ViewController
{
    int CurrentCarGroup;
    int zoomLevel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CurrentCarGroup = 0;
    zoomLevel = 1;
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
    [self.view bringSubviewToFront:self.zoomInBtn];
    [self.view bringSubviewToFront:self.zoomOutBtn];
    [self.view bringSubviewToFront:self.locateBtn];
    
    
}

//大头针
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    CGRect rect = CGRectMake(0, 0, 45, 45);
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    CarAnotationView *carAnotationView = [[CarAnotationView alloc] initWithFrame:rect annotationPic:[UIImage imageNamed:[NSString stringWithFormat:@"car%d", CurrentCarGroup]]];
    carAnotationView.backgroundColor = [UIColor clearColor];
    return carAnotationView;
}

#pragma mark click Methods

- (IBAction)setUserLocationCenter:(id)sender
{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}

- (IBAction)zoomIn:(id)sender
{
    if (zoomLevel >= 1)
    {
        zoomLevel++;
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.region.center, MKCoordinateSpanMake(1000*zoomLevel, 1000*zoomLevel)) animated:YES];
    }
    
}

- (IBAction)zoomOut:(id)sender
{
    if (zoomLevel <= 10)
    {
        zoomLevel--;
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.region.center, MKCoordinateSpanMake(1000/zoomLevel, 1000/zoomLevel)) animated:YES];
    }
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
    [self.mapView addAnnotations:self.carAnnotationGroup1];
//    MyAnnotation *userAnnotation =  [[MyAnnotation alloc] init];
//    userAnnotation.coordinate = userLocation.location.coordinate;
//    [self.mapView addAnnotation:userAnnotation];

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
    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"取消选择了大头针 %@",view.description);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    
}





#pragma mark SliderControlDelegate
- (void)sliderControl:(MySliderView *)sliderControlView moveToPosition:(int)position
{
    NSLog(@"现在移动到%d", position);
    CurrentCarGroup = position;
    if (CurrentCarGroup == 0)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:self.carAnnotationGroup1];
    } else if (CurrentCarGroup == 1)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:self.carAnnotationGroup2];
    } else
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
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

- (NSArray *)carAnnotationGroup1
{
    if (!_carAnnotationGroup1)
    {
        NSMutableArray *carAnnotations = [NSMutableArray array];
        
        for (int i = 1; i < 5; i++)
        {
            MyAnnotation *annotation1 = [[MyAnnotation alloc] init];
            annotation1.coordinate = CLLocationCoordinate2DMake(LATTITUDE-0.005*i, LONGITUDE);
            annotation1.title = [NSString stringWithFormat:@"TestData%d", i];
            annotation1.subtitle = @"TestSubtitle1";
            [carAnnotations addObject:annotation1];
        }
        _carAnnotationGroup1 = carAnnotations;
    }
    return _carAnnotationGroup1;
}

- (NSArray *)carAnnotationGroup2
{
    if (!_carAnnotationGroup2)
    {
        NSMutableArray *carAnnotations = [NSMutableArray array];
        
        for (int i = 1; i < 5; i++)
        {
            MyAnnotation *annotation1 = [[MyAnnotation alloc] init];
            annotation1.coordinate = CLLocationCoordinate2DMake(LATTITUDE-0.005*i, LONGITUDE-i*0.005);
            annotation1.title = [NSString stringWithFormat:@"TestData%d", i];
            annotation1.subtitle = @"TestSubtitle2";
            [carAnnotations addObject:annotation1];
        }
        _carAnnotationGroup2 = carAnnotations;
    }
    return _carAnnotationGroup2;
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
