//
//  ModalTransitionAnimator.m
//  ChARM Chart Notes
//
//  Created by madhan-1786 on 24/09/14.
//  Copyright (c) 2014 MedicalMine Inc. All rights reserved.
//

#import "ModalTransitionAnimator.h"


@implementation ModalTransitionAnimator

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.presenting = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.presenting = NO;
    return self;
}

# pragma mark -
# pragma mark UIViewControllerAnimatedTransitioning

- (void)animationEnded:(BOOL)transitionCompleted
{
    // reset state
    self.presenting = NO;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (CGRect) getDismissedStateRectForPresentedViewSize:(CGSize)presentedViewsize orientation:(UIInterfaceOrientation)interfaceOrientation andContainerViewSize:(CGSize)containerSize
{
   return CGRectMake((containerSize.width-presentedViewsize.width)/2, containerSize.height, presentedViewsize.width, presentedViewsize.height);
}

- (CGRect) getPresentedStateRectForSize:(CGSize)presentedViewsize orientation:(UIInterfaceOrientation)interfaceOrientation andContainerViewSize:(CGSize)containerSize
{
    return CGRectMake((containerSize.width-presentedViewsize.width)/2, (containerSize.height-presentedViewsize.height)/2, presentedViewsize.width, presentedViewsize.height);
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    if (self.presenting)
    {
        fromViewController.view.userInteractionEnabled = NO;
        
        //Code to add overlay view
        UIView *overlayView = [[UIView alloc] initWithFrame:containerView.bounds];
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.alpha = 0.3;
        [containerView addSubview:overlayView];
        
//        [containerView addSubview:fromViewController.view];
        [containerView addSubview:toViewController.view];
        
        toViewController.view.frame = [self getDismissedStateRectForPresentedViewSize:toViewController.view.frame.size orientation:fromViewController.interfaceOrientation andContainerViewSize:containerView.frame.size];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.frame = [self getPresentedStateRectForSize:toViewController.view.frame.size orientation:fromViewController.interfaceOrientation andContainerViewSize:containerView.frame.size];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;
        
//        [containerView addSubview:toViewController.view];
//        [containerView addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromViewController.view.frame = [self getDismissedStateRectForPresentedViewSize:fromViewController.view.frame.size orientation:toViewController.interfaceOrientation andContainerViewSize:containerView.frame.size];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

@end
