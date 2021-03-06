//
//  ATDTutorialFinalView.m
//  ATODE
//
//  Created by 平松　亮介 on 2014/07/29.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "ATDTutorialFinalView.h"

@implementation ATDTutorialFinalView

+ (instancetype)view {
    NSString *className = NSStringFromClass([self class]);
    return [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:0] firstObject];
}

- (void)awakeFromNib {
    _doneButton.layer.cornerRadius = 4.0f;
    _doneButton.layer.masksToBounds = YES;
}

- (void)setIsFirstTutorial:(BOOL)isFirstTutorial {
    _isFirstTutorial = isFirstTutorial;
    if (_isFirstTutorial) {
        [_doneButton setTitle:@"使ってみる" forState:UIControlStateNormal];
    }
    else {
        [_doneButton setTitle:@"閉じる" forState:UIControlStateNormal];
    }
}

- (IBAction)doneBtnTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(didTouchDoneBtn)]) {
        [_delegate didTouchDoneBtn];
    }
}


@end
