//
//  CBFlipViewTransition.h
//
//  Copyright (c) 2014 C. Bess. MIT.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CBFlipDirection) {
    CBFlipDirectionLeft,
    CBFlipDirectionRight,
    CBFlipDirectionUp,
    CBFlipDirectionDown
};

@interface CBFlipViewTransition : NSObject

@property (nonatomic, strong) UIView *frontView;
@property (nonatomic, strong) UIView *backView;
/**
 The container that will contain the transition for the front and back views.
 */
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) CGPoint endingCenter;
@property (nonatomic, assign) CFTimeInterval duration;
@property (nonatomic, assign) CBFlipDirection flipDirection;
@property (nonatomic, assign) BOOL removeOnCompletion;
@property (nonatomic, assign) CGFloat zDistance;

- (void)performTransitionWithCompletion:(dispatch_block_t)completion;

@end
