//
//  ViewController.m
//  LDNetworking
//
//  Created by YueHui on 17/1/9.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "ViewController.h"
#import "RegisterApi.h"

@interface ViewController ()<LDBaseRequestCallBackDelegate,LDBaseRequestParamDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RegisterApi *api = [[RegisterApi alloc] init];
    api.delegate = self;
    api.paramSource = self;
    
    [api loadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)paramsForRequest:(LDBaseRequest *)request {
    return @{
             @"username": @"yuehui",
             @"password": @"123456"
             };
}

@end
