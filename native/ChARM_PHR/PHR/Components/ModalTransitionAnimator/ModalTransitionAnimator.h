//
//  ModalTransitionAnimator.h
//  ChARM Chart Notes
//
//  Created by madhan-1786 on 24/09/14.
//  Copyright (c) 2014 MedicalMine Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ModalTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, getter = isPresenting) BOOL presenting;

@end
