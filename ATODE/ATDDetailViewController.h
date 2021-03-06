//
//  ATDDetailViewController.h
//  ATODE
//
//  Created by himara2 on 2014/07/13.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlaceMemo;


@protocol ATDDetailMemoProtocol <NSObject>

- (void)didChangeMemo:(PlaceMemo *)memo;

@end


@interface ATDDetailViewController : UIViewController

@property (nonatomic, strong) PlaceMemo *memo;

@end
