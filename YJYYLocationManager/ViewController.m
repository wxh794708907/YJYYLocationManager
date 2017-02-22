//
//  ViewController.m
//  YJYYLocationManager
//
//  Created by 遇见远洋 on 17/2/22.
//  Copyright © 2017年 遇见远洋. All rights reserved.
//

#import "ViewController.h"
#import "YJYYLocationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //用户定位
    [[YJYYLocationManager sharedManager] updateLocationWithLocation:^(CLLocation *location) {
        NSLog(@"经度:%f========纬度:%f",location.coordinate.longitude,location.coordinate.latitude);
    } failureCB:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    //反编码后位置
    [[YJYYLocationManager sharedManager] updateReverseGeocodeLocation:^(NSString *placeName) {
        NSLog(@"%@",placeName);
    }];
    
    //速度回调
    [[YJYYLocationManager sharedManager] updateSpeedWithCallBack:^(CLLocationSpeed speed) {
        NSLog(@"%f",speed);
    }];
    
    //从当前位置到目标点的相对距离
    //测试经纬度--经度:116.304646========纬度:40.037789
    CLLocationCoordinate2D targetPoint = CLLocationCoordinate2DMake(41.37780, 117.304646);
    [[YJYYLocationManager sharedManager] distanceFromCurrentLocationToTargetLocation:targetPoint callBack:^(CLLocationDistance distance) {
        NSLog(@"%f",distance);
    }];
}


@end
