//
//  ViewController.m
//  LDNetworking
//
//  Created by YueHui on 17/1/9.
//  Copyright © 2017年 LeapDing. All rights reserved.
//

#import "ViewController.h"
#import "RegisterApi.h"
#import "UploadimageApi.h"
#import "LDBatchRequest.h"
#import "testApi.h"

@interface ViewController ()<LDBaseRequestCallBackDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    RegisterApi *api = [[RegisterApi alloc] init];
//    api.delegate = self;
//    api.paramSource = self;
    
//    [api loadData];
    
    testApi *testApi2 = [[testApi alloc] init];
    [testApi2 loadDataWithUserName:@"huige" pwd:@"123456"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


///// Send batch request
//- (void)sendBatchRequest {
//    RegisterApi *a = [[RegisterApi alloc] init];
//    RegisterApi *b = [[RegisterApi alloc] init];
//    RegisterApi *c = [[RegisterApi alloc] init];
//    UploadimageApi *d = [[UploadimageApi alloc] init];
//    LDBatchRequest *batchRequest = [[LDBatchRequest alloc] initWithRequestArray:@[a, b, c, d]];
//    [batchRequest loadDataWithCompletionBlockWithSuccess:^(LDBatchRequest *batchRequest) {
//        NSLog(@"succeed");
//        NSArray *requests = batchRequest.requestArray;
//        RegisterApi *a = (RegisterApi *)requests[0];
//        RegisterApi *b = (RegisterApi *)requests[1];
//        RegisterApi *c = (RegisterApi *)requests[2];
//        UploadimageApi *user = (UploadimageApi *)requests[3];
//        // deal with requests result ...
//        NSLog(@"%@, %@, %@, %@", a, b, c, user);
//    } failure:^(LDBatchRequest *batchRequest) {
//        NSLog(@"failed");
//    }];
//}

@end
