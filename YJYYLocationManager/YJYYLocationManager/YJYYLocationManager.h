//
//  YJYYLocationManager.h
//  YJYYLocationManager
//
//  Created by 遇见远洋 on 17/2/22.
//  Copyright © 2017年 遇见远洋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface YJYYLocationManager : NSObject

/**
 创建地理位置管理单例

 @return 返回地理位置管理单例
 */
+ (instancetype)sharedManager;


/**
 更新地理位置

 @param locationCB 定位成功回调
 */
- (void)updateLocationWithLocation:(void(^)(CLLocation *location))locationCB failureCB:(void(^)(NSError *error))failureCB;


/**
 传入经纬度返回地名

 @param location location
 @param callBack 反编码成功回调
 */
- (void)reverseGeocodeLocation:(CLLocation *)location callBack:(void(^)(NSString * place))callBack;


/**
 获取定位后反编码之后用户位置

 @param callBack 反编码成功之后的回调
 */
- (void)updateReverseGeocodeLocation:(void(^)(NSString *placeName))callBack;


/**
 更新速度信息
 
 @param callBack 速度变化回调
 */
-(void)updateSpeedWithCallBack:(void(^)(CLLocationSpeed speed)) callBack;


/**
 计算相对距离(km)
 
 @param startCoordinate 起点
 @param targetCoordinate 目标位置
 @return 相对距离
 */
-(CLLocationDistance)distanceFromCoordinate:(CLLocationCoordinate2D)startCoordinate
                 toTargetCoordinate:(CLLocationCoordinate2D) targetCoordinate;

/**
 计算当前位置到目标位置的相对距离(km)
 
 @param targetCoordinate 目标位置
 */
-(void)distanceFromCurrentLocationToTargetLocation:(CLLocationCoordinate2D) targetCoordinate callBack:(void(^)(CLLocationDistance distance))callBack;


@end
