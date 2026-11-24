//
//  QuestEditSignatureViewController.m
//  ChARM_Kiosk
//
//  Created by madhan-1786 on 28/11/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import "QuestEditSignatureViewController.h"

#import "SmoothedBIView.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface QuestEditSignatureViewController ()

@property (nonatomic, strong) UIBarButtonItem *acceptButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIButton *clearButton;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation QuestEditSignatureViewController

- (instancetype)initWithDelegate:(QuestionnaireAnswerViewController*)questionnaireVC
{
    if (self = [super init])
    {
        _delegate = questionnaireVC;
    }
    return self;
}

- (void)loadView
{
//    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
//    parentView.backgroundColor = [UIColor grayColor];
//
//    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(50, 40, 280, 40)];
//    toolBar.barStyle = UIBarStyleDefault;
//    toolBar.translucent = NO;
//    [toolBar setTintColor:[UIColor grayColor]];
//   // [toolBar setBarTintColor:UIColorFromRGB(0x4074D9FF)];
//
//    self.acceptButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"com.charmphr.action.done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(acceptButtonTapped:)];
//
//  //  [self.acceptButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:FONT_FAMILY_BOLD size:17.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
//
//    self.cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"com.charmphr.action.cancel", @"Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonTapped:)];
// //   [self.cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:FONT_FAMILY_BOLD size:17.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];
//
//    UIBarButtonItem *flexibleSpaceBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//
//    [toolBar setItems:@[self.cancelButton, flexibleSpaceBtn, self.acceptButton]];
//    [parentView addSubview:toolBar];
//
//
//    self.signatureView = [[SmoothedBIView alloc] initWithFrame:CGRectMake(50, 80, 280, 250)];
//    self.signatureView.layer.borderWidth = 1.0f;
// //   self.signatureView.layer.borderColor = UIColorFromRGB(0xC2C2C2).CGColor;
//    self.signatureView.placeholder = @"Sign Here..";
//    [parentView addSubview:self.signatureView];
//
//
//    //To add the Signature image view on the top if needed
//    if ( self.presentingImageView.image )
//    {
//        self.bigSignatureImageView = [[UIImageView alloc] initWithFrame:self.signatureView.frame];
//        self.bigSignatureImageView.image = self.presentingImageView.image;
//        self.bigSignatureImageView.layer.borderWidth = 1.0f;
////        self.bigSignatureImageView.layer.borderColor = UIColorFromRGB(0xC2C2C2).CGColor;
//        [parentView addSubview:self.bigSignatureImageView];
//        self.bigSignatureImageView.userInteractionEnabled = YES;
//
//        self.signatureView.userInteractionEnabled = NO;
//
//        self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.clearButton.frame = CGRectMake(self.bigSignatureImageView.frame.size.width-75, 5, 70, 30);
//       // [self.clearButton setBackgroundImage:[ApplicationDelegate imageFromColor:UIColorFromRGB(0xe3e3e3) forSize:self.clearButton.frame.size] forState:UIControlStateNormal];
//        [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
//        //[self.clearButton setTitleColor:UIColorFromRGB(0x2b2b2b) forState:UIControlStateNormal];
//        self.clearButton.backgroundColor = UIColor.redColor;
//        [self.clearButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
//       // self.clearButton.titleLabel.font = [UIFont fontWithName:FONT_FAMILY_NORMAL size:16.0f];
//
//        [self.clearButton addTarget:self action:@selector(clearSignaturePad:) forControlEvents:UIControlEventTouchUpInside];
//
//        [self.bigSignatureImageView addSubview:self.clearButton];
 //   }
    
    
   // self.view = parentView;
}

- (void)acceptButtonTapped:(id)sender
{
   // [self.delegate receiveWithSignatureImageView:self.signatureView.incrementalImage];
}

- (void)cancelButtonTapped:(id)sender
{
  // [self.delegate dismissPopOverAndModelViews];
}

- (void)clearSignaturePad:(id) sender {
    
    if ( self.bigSignatureImageView )
    {
        [self.bigSignatureImageView removeFromSuperview];
        self.bigSignatureImageView = NULL;
        self.clearButton = NULL;
        
        self.signatureView.userInteractionEnabled = YES;
    }
    else
    {
        [self.signatureView clear];
    }
}

- (void)disableTheView
{
    self.view.userInteractionEnabled = NO;
    
    [self.cancelButton setEnabled:NO];
    [self.acceptButton setEnabled:NO];
    
//    [self.clearButton setEnabled:NO];
    
}

- (void)enableTheView
{
    self.view.userInteractionEnabled = YES;
    
    [self.cancelButton setEnabled:YES];
    [self.acceptButton setEnabled:YES];
    
//    [self.clearButton setEnabled:YES];
}

#pragma Mark - Activity Indicator Show and Hide

-(void)showNetworkActivityIndicator
{
    if (!self.activityIndicatorView) {
        self.activityIndicatorView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.signatureView.frame.size.width/2 - 20, self.signatureView.frame.size.height/2 - 20, 40, 40)];
        self.activityIndicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
        [self.activityIndicatorView setColor:[UIColor blackColor]];
//        self.activityIndicatorView.alpha=0.4f;
        self.activityIndicatorView.layer.zPosition = 100;
        [self.signatureView addSubview:self.activityIndicatorView];
    }
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    
}

-(void)hideNetworkActivityIndicator
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    
}


@end
