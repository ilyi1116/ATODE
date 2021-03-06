//
//  ATDTutorialFinalView.h
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ATDTutorialFinalViewDelegate <NSObject>

- (void)didTouchDoneBtn;

@end


@interface ATDTutorialFinalView : UIView

@property (nonatomic, weak) id<ATDTutorialFinalViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, assign) BOOL isFirstTutorial;

+ (instancetype)view;


@end
