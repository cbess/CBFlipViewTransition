//
//  CBFlipViewTransition.m
//
//  Copyright (c) 2014 C. Bess. MIT.
//

#import "CBFlipViewTransition.h"

@interface CBFlipViewTransition () <CAAnimationDelegate> {
    CALayer *_frontLayer;
    CALayer *_backLayer;
}
@property (nonatomic, copy) dispatch_block_t completion;
@end

@implementation CBFlipViewTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = .25f;
        _zDistance = 1400;
        _removeOnCompletion = YES;
    }
    return self;
}

- (void)performTransitionWithCompletion:(dispatch_block_t)completion {
    self.completion = completion;

    /// setup the layers

    CALayer *frontLayer = [CALayer layer];
    _frontLayer = frontLayer;
    CALayer *backLayer = [CALayer layer];
    _backLayer = backLayer;

    // determine rotation, direction and set perspective
    NSString *rotationKeyPath = @"transform.rotation.y";
    CATransform3D perspective = CATransform3DIdentity;
    switch (self.flipDirection) {
        case CBFlipDirectionDown:
            rotationKeyPath = @"transform.rotation.x";
        case CBFlipDirectionLeft:
            perspective.m34 = -1.f / self.zDistance;
            break;

        case CBFlipDirectionUp:
            rotationKeyPath = @"transform.rotation.x";
        case CBFlipDirectionRight:
            perspective.m34 = 1.f / self.zDistance;
            break;
    }

    // front
    self.frontView.hidden = NO; // show to get screenshot
    frontLayer.doubleSided = NO;
    frontLayer.frame = self.frontView.bounds;
    frontLayer.position = self.frontView.center;
    frontLayer.contents = (id)[[self imageFromView:self.frontView force:NO] CGImage]; // should be on screen
    frontLayer.transform = perspective;

    // back
    self.backView.hidden = NO;
    backLayer.doubleSided = NO;
    backLayer.frame = self.backView.bounds;
    backLayer.position = self.frontView.center;
    backLayer.contents = (id)[[self imageFromView:self.backView force:YES] CGImage]; // may not be shown
    backLayer.transform = perspective;

    [self.containerView.layer addSublayer:frontLayer];
    [self.containerView.layer addSublayer:backLayer];

    self.frontView.hidden = YES;
    self.backView.hidden = YES;

    /// setup the animations

    NSMutableArray *animations = [NSMutableArray array];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = self.duration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    // front
    // position
    CABasicAnimation *frontAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    frontAnimation.toValue = [NSValue valueWithCGPoint:self.endingCenter];
    [animations addObject:frontAnimation];
    // rotate
    frontAnimation = [CABasicAnimation animationWithKeyPath:rotationKeyPath];
    frontAnimation.fromValue = @0;
    frontAnimation.toValue = @(-M_PI);
    [animations addObject:frontAnimation];
    // scale, to size of back layer
    frontAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    frontAnimation.toValue = [NSValue valueWithCGRect:backLayer.bounds];
    [animations addObject:frontAnimation];
    // animate
    animationGroup.animations = animations;
    [frontLayer addAnimation:animationGroup forKey:@"cbflip"];
    [animations removeAllObjects];

    // back
    // position
    CABasicAnimation *backAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    backAnimation.toValue = [NSValue valueWithCGPoint:self.endingCenter];
    [animations addObject:backAnimation];
    // rotate
    backAnimation = [CABasicAnimation animationWithKeyPath:rotationKeyPath];
    backAnimation.fromValue = @(M_PI);
    backAnimation.toValue = @0;
    [animations addObject:backAnimation];
    // scale, from front to back layer size
    backAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    backAnimation.fromValue = [NSValue valueWithCGRect:frontLayer.bounds];
    backAnimation.toValue = [NSValue valueWithCGRect:backLayer.bounds];
    [animations addObject:backAnimation];
    // animate
    animationGroup.animations = animations;
    animationGroup.delegate = self; // only assign here to prevent multiple completion calls
    [backLayer addAnimation:animationGroup forKey:@"cbflip"];
    [animations removeAllObjects];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.removeOnCompletion) {
        [_frontLayer removeFromSuperlayer];
        [_backLayer removeFromSuperlayer];
    }

    self.frontView.hidden = NO;
    self.backView.hidden = NO;

    if (self.completion) {
        self.completion();
    }
}

#pragma mark - Misc

- (UIImage *)imageFromView:(UIView *)view force:(BOOL)force {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);

    if (!force && [view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
