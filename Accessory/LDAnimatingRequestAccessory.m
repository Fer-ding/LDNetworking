//
//  YTKAnimatingRequestAccessory.m
//  Ape_uni
//
//  Created by Chenyu Lan on 10/30/14.
//  Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "LDAnimatingRequestAccessory.h"
#import "MBProgressHUD+PKX.h"


@implementation LDAnimatingRequestAccessory

- (id)initWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText {
    self = [super init];
    if (self) {
        _animatingView = animatingView;
        _animatingText = animatingText;
    }
    return self;
}

- (id)initWithAnimatingView:(UIView *)animatingView {
    self = [super init];
    if (self) {
        _animatingView = animatingView;
    }
    return self;
}

+ (id)accessoryWithAnimatingView:(UIView *)animatingView {
    return [[self alloc] initWithAnimatingView:animatingView];
}

+ (id)accessoryWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText {
    return [[self alloc] initWithAnimatingView:animatingView animatingText:animatingText];
}

- (void)requestWillStart:(id)request {
    if (_animatingText) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: show loading
            NSLog(@" loading start");
            [MBProgressHUD showLoadingWithMessage:self.animatingText];
        });
    }
}

- (void)requestWillStop:(id)request {
    if (_animatingText) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: hide loading
            NSLog(@" loading finished");
            [MBProgressHUD hideHUD];
        });
    }
}

@end
