//
//  SmoothedBIView.h
//  FreeHandDrawingTut
//
//  Created by ZOHOCORP\durai-0824 on 16/04/13.
//  Copyright (c) 2013 MedicalMine. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SmoothedBIView : UIView

@property ( nonatomic , strong ) UIImage *incrementalImage;
@property ( nonatomic , strong ) NSString *placeholder;

- (void) clear;

@end


