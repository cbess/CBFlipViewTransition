//
//  FNViewController.m
//  FlipNow
//
//  Created by C. Bess on 5/7/14.
//  Copyright (c) 2014 C. Bess. All rights reserved.
//

#import "FNViewController.h"
#import "CBFlipViewTransition.h"

@interface FNViewController () {
    BOOL _flipped;
}

@property (weak, nonatomic) IBOutlet UIImageView *oneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *twoImageView;
@property (nonatomic, strong) CBFlipViewTransition *flipViewTransition;

@end

@implementation FNViewController

- (IBAction)flipButtonPressed:(id)sender {
    self.flipViewTransition = [CBFlipViewTransition new];
    
    if (!_flipped) {
        self.flipViewTransition.frontView = self.oneImageView;
        self.flipViewTransition.backView = self.twoImageView;
    } else {
        self.flipViewTransition.frontView = self.twoImageView;
        self.flipViewTransition.backView = self.oneImageView;
    }
    self.flipViewTransition.containerView = self.view;
    self.flipViewTransition.zDistance = 700;
    self.flipViewTransition.endingCenter = (_flipped ? self.oneImageView.center : self.twoImageView.center);
    self.flipViewTransition.flipDirection = (_flipped ? CBFlipDirectionLeft : CBFlipDirectionRight);
    self.flipViewTransition.duration = 1.5f;
    
    __typeof__(self) __weak weakSelf = self;
    [self.flipViewTransition performTransitionWithCompletion:^{
        weakSelf.flipViewTransition.frontView.hidden = YES;
        
        _flipped = !_flipped;
    }];
}

@end
