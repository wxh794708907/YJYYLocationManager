//
//  YJYYLocationManager.m
//  YJYYLocationManager
//
//  Created by 遇见远洋 on 17/2/22.
//  Copyright © 2017年 遇见远洋. All rights reserved.
//

#import "YJYYLocationManager.h"
#import <CoreLocation/CoreLocation.h>
typedef void(^YJYYLocationBlock)(CLLocation *location);
typedef void(^YJYYFailureBlock)(NSError *error);
typedef void(^YJYYReverseGeoBlock)(NSString *placeName);
typedef void(^YJYYSpeedBlock)(CLLocationSpeed speed);


@interface YJYYLocationManager ()<CLLocationManagerDelegate>{
    // 位置管理
    CLLocationManager *_locationManager;
    // 地理反编码
    CLGeocoder *_geocoder;
}
/** 定位成功block */
@property(nonatomic,copy) YJYYLocationBlock locationBlock;
/** 定位失败block */
@property(nonatomic,copy) YJYYFailureBlock failureBlock;
/** 反编码成功block */
@property(nonatomic,copy) YJYYReverseGeoBlock reverseGeoBlcok;
/** 速度变化block */
@property(nonatomic,copy) YJYYSpeedBlock speedBlock;
@end

@implementation YJYYLocationManager

+ (instancetype)sharedManager {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _geocoder = [[CLGeocoder alloc] init];
        // 创建管理者
        _locationManager = [[CLLocationManager alloc] init];
        // 设置代理
        _locationManager.delegate  = self;
        // 设置定位距离过滤参数 (当本次定位和上次定位之间的距离大于或等于这个值时，调用代理方法)
        _locationManager.distanceFilter  = 100 ;
        // 设置定位精度(精度越高越耗电)
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //版本适配 请求权限 iOS 8之后必须在plist中添加相应key
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        //判断是否允许定位
        if ([CLLocationManager locationServicesEnabled]) {
            // 开启实时定位
            [_locationManager startUpdatingLocation];
        }
    }
    return self;
}


//获取用户定位
- (void)updateLocationWithLocation:(void (^)(CLLocation *location))locationCB failureCB:(void (^)(NSError *error))failureCB{
    NSAssert(locationCB != nil, @"定位成功回调不能为空");
    self.locationBlock = locationCB;
    NSAssert(failureCB != nil, @"定位失败回调不能为空");
    self.failureBlock = failureCB;
}


//反地理编码
- (void)reverseGeocodeLocation:(CLLocation *)location callBack:(void(^)(NSString * place))callBack{
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark * placemark = placemarks.firstObject;
        if (callBack) {
            callBack(placemark.name);
        }
    }];
}

//获取定位后再反编码
- (void)updateReverseGeocodeLocation:(void (^)(NSString *placeName))callBack {
    NSAssert(callBack !=nil, @"反编码回调传入不能为空");
    self.reverseGeoBlcok = callBack;
}

//用户速度回调
- (void)updateSpeedWithCallBack:(void (^)(CLLocationSpeed speed))callBack {
    NSAssert(callBack !=nil, @"速度回调传入不能为空");
    self.speedBlock = callBack;
}

//计算两坐标距离
- (CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)startCoordinate toTargetCoordinate:(CLLocationCoordinate2D)targetCoordinate {
    CLLocation *curtLocation = [[CLLocation alloc] initWithLatitude:startCoordinate.latitude longitude:startCoordinate.longitude];
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:targetCoordinate.latitude longitude:targetCoordinate.longitude];
    CLLocationDistance distance =  [curtLocation distanceFromLocation:targetLocation];
    return distance/1000.f;
}

//从当前位置到目标位置距离
- (void)distanceFromCurrentLocationToTargetLocation:(CLLocationCoordinate2D)targetCoordinate callBack:(void (^)(CLLocationDistance))callBack{
    //先获取定位
    [self updateLocationWithLocation:^(CLLocation *location) {
        if (callBack) {
            callBack([self distanceFromCoordinate:location.coordinate toTargetCoordinate:targetCoordinate]);
        }
    } failureCB:^(NSError *error) {
        NSLog(@"抱歉获取定位失败");
    }];
}

#pragma  mark -  代理回调
#pragma  mark -
/** 获取到新的位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //去除第一条数据
    CLLocation * location = locations.firstObject;
    
    __weak typeof(self) weakSelf = self;
    
    //定位成功回调
    if (self.locationBlock) {
        self.locationBlock(locations.firstObject);
    }
    
    //反编码回调
    if (self.reverseGeoBlcok) {
        [self reverseGeocodeLocation:locations.firstObject callBack:^(NSString *place) {
            weakSelf.reverseGeoBlcok(place);
        }];
    }
    
    //速度回调
    if (self.speedBlock) {
        self.speedBlock(location.speed *3.6);
    }
}

/** 不能获取位置信息时调用*/
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (self.failureBlock) {
        NSLog(@"获取定位失败");
        self.failureBlock(error);
    }
}

@end
