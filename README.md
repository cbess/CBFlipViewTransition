CBFlipViewTransition
====================

Flip transition, think iTunes App Store artwork flip to details.

```objc
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
```