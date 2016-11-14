//
//  ViewController.m
//  RentCar
//
//  Created by ffm on 16/11/11.
//  Copyright © 2016年 ITPanda. All rights reserved.
//

/*
  终于完成了这个大作业了。。。吐一口老血
  基本实现了所有的要求啦，然后视频里的点击大头针然后滚动到相应的卡片上那个
  感觉是scrollView或者collectionView，这里简化成一个UIViewAnimation，因为感觉不是这章的重点
  
  bug：还是会有，最明显一个就是 点击大头针之后，如果不是点击其他地方，出发deselect方法的话，（比如直接点击另外一个大头针，就触发不了deselect了）然后就会有bug了。
    健壮性还是不够
 
 11.20更新：
 问题：点击用户坐标（蓝色点）会闪退（估计是selectAnnotation没有区别开MKUserLocation的问题）-->bingo!
    测试的数据应该在用户实际位置附近（经纬度+-0.001或随机）——>done!
    点击大头针后，再点击大头针就会出现bug，触发不了deselect函数（那我可以卡片view出现前就取消选择呀）
       -->事实证明手动触发取消选择是错的。 但是原来可以不用把carInfoView, sendback其实只要透明度为零就好，之前的冲突就是因为deselcet动画还在执行，然后已经开始触发新的select，所以在进行新的select的时候，那边deselect执行完 就执行了sendback，所以整个carInfoView都不见了。
 
*/

#import "ViewController.h"
#import "MySliderView.h"
#import "SliderControlDelegate.h"
#import "CarAnotationView.h"
#import "MyAnnotation.h"
#import "CarInfoModel.h"

#define USERLATITUDE self.self.mapView.userLocation.coordinate.latitude
#define USERLONGITUDE self.mapView.userLocation.coordinate.longitude
#define USERCOORDINATE self.mapView.userLocation.location.coordinate

@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate, SliderControlDelegate>

@property (nonatomic, strong)MKMapView *mapView;
@property (nonatomic, strong)CLLocationManager *locationManager;

@property (nonatomic, strong) NSArray *carAnnotationGroup1;
@property (nonatomic, strong) NSArray *carAnnotationGroup2;

@property (weak, nonatomic) IBOutlet UIButton *zoomInBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomOutBtn;

@property (weak, nonatomic) IBOutlet UIButton *locateBtn;
@property (weak, nonatomic) IBOutlet UIView *carInfoView;

@property (nonatomic, strong) NSArray *carInfoPlistArr;

@property (weak, nonatomic) IBOutlet UIImageView *carPic;
@property (weak, nonatomic) IBOutlet UILabel *carNumber;
@property (weak, nonatomic) IBOutlet UILabel *carType;
@property (weak, nonatomic) IBOutlet UILabel *carSeats;

@end

@implementation ViewController
{
    int CurrentCarGroup;
    int zoomLevel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    CurrentCarGroup = 0;
    zoomLevel = 5;
    
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
//点击按钮定位到用户当前位置
- (IBAction)setUserLocationCenter:(id)sender
{
    [self.mapView setCenterCoordinate:USERCOORDINATE animated:YES];
}

//放大
- (IBAction)zoomIn:(id)sender
{
    if (zoomLevel >= -1 && zoomLevel <= 8)
    {
        zoomLevel++;
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.region.center, MKCoordinateSpanMake(self.mapView.region.span.latitudeDelta/1.5, self.mapView.region.span.longitudeDelta/1.5)) animated:YES];
    }
    
}

//缩小
- (IBAction)zoomOut:(id)sender
{
    if (zoomLevel >= 0 && zoomLevel <= 9)
    {
        zoomLevel--;
        [self.mapView setRegion:MKCoordinateRegionMake(self.mapView.region.center, MKCoordinateSpanMake(self.mapView.region.span.latitudeDelta*1.5, self.mapView.region.span.longitudeDelta*1.5)) animated:YES];
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
//    NSLog(@"定位用户位置成功~");
    [self.mapView addAnnotations:self.carAnnotationGroup1];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    //要注意判断区别开UserLocation
    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
    if (view.annotation.coordinate.latitude == USERLATITUDE
        && view.annotation.coordinate.longitude == USERLONGITUDE)
    {
        return;
    } else
    {
        
        MyAnnotation *selectedAnnotation = view.annotation;
        NSString *identifier = selectedAnnotation.carIdentifier;
        
        for (CarInfoModel *model in self.carInfoPlistArr)
        {
            NSString *carID = model.carID;
            if ([carID isEqualToString:identifier])
            {
                self.carNumber.text = model.carNumber;
                self.carType.text = model.carType;
                self.carSeats.text = model.carSeats;
                self.carPic.image = [UIImage imageNamed:model.carInfo];
            }
        }
        
        [self.view bringSubviewToFront:self.carInfoView];
        self.carInfoView.alpha = 0;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
            self.carInfoView.alpha = 1;
        } completion:^(BOOL finished) {

        }];
    }

    
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        self.carInfoView.alpha = 0;
    } completion:^(BOOL finished) {

    }];

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
            annotation1.coordinate = CLLocationCoordinate2DMake(USERLATITUDE-0.005*i, USERLONGITUDE);
            annotation1.title = [NSString stringWithFormat:@"TestData%d", i];
            annotation1.subtitle = @"TestSubtitle1";
            annotation1.carGroup = 1;
            
            annotation1.carIdentifier = [NSString stringWithFormat:@"cargroup1_test%d",i];
            
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
            annotation1.coordinate = CLLocationCoordinate2DMake(USERLATITUDE-0.005*i, USERLONGITUDE-i*0.005);
            annotation1.title = [NSString stringWithFormat:@"TestData%d", i];
            annotation1.subtitle = @"TestSubtitle2";
            annotation1.carGroup = 2;
            
            annotation1.carIdentifier = [NSString stringWithFormat:@"cargroup2_test%d",i];
            
            [carAnnotations addObject:annotation1];
        }
        _carAnnotationGroup2 = carAnnotations;
    }
    return _carAnnotationGroup2;
}

- (NSArray *)carInfoPlistArr
{
    if (!_carInfoPlistArr)
    {
        NSString *strPath = [[NSBundle mainBundle] pathForResource:@"CarInfo" ofType:@"plist"];
        NSArray *tempArr = [[NSArray alloc] initWithContentsOfFile:strPath];
        NSMutableArray *murArr = [NSMutableArray array];
        CarInfoModel *model;
        for (NSDictionary *dict in tempArr)
        {
            model = [CarInfoModel carModelWithDict:dict];
            [murArr addObject:model];
        }
        _carInfoPlistArr = murArr;
    }
    return _carInfoPlistArr;
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
