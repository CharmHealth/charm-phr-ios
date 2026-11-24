//
//  QuestEditSignatureViewController.h
//  ChARM_Kiosk
//
//  Created by madhan-1786 on 28/11/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuestionnaireAnswerViewController;
@class SmoothedBIView;

@interface QuestEditSignatureViewController : UIViewController

@property (nonatomic, unsafe_unretained) QuestionnaireAnswerViewController *delegate;

@property (nonatomic, strong) SmoothedBIView *signatureView;

@property (nonatomic, weak) UIImageView *presentingImageView;

@property (nonatomic, strong) UIImageView *bigSignatureImageView;

- (instancetype)initWithDelegate:(QuestionnaireAnswerViewController*)questionnaireVC;

-(void)showNetworkActivityIndicator;

-(void)hideNetworkActivityIndicator;

@end
