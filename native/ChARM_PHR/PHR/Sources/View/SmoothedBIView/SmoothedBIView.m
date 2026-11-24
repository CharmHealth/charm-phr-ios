//
//  SmoothedBIView.m
//  FreeHandDrawingTut
//
//  Created by ZOHOCORP\durai-0824 on 16/04/13.
//  Copyright (c) 2013 MedicalMine. All rights reserved.
//

#import "SmoothedBIView.h"


@implementation SmoothedBIView
{
    UIBezierPath *path;
    CGPoint pts[5];
    uint ctr;
    BOOL hasMoved;
    UILabel *signaturePlaceholder;
//    UIButton *clearBtn;
}

@synthesize incrementalImage = _incrementalImage;
@synthesize placeholder = _placeholder;

/*
- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0f];
    }
    
    return self;
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
        //
        signaturePlaceholder = [[UILabel alloc] initWithFrame:self.bounds];
        signaturePlaceholder.text = NSLocalizedString(@"com.charmphr.questionnaire.signature.placeHolder", "");
        signaturePlaceholder.font = [UIFont fontWithName:@"HelveticaNeue" size:22.0f];
        signaturePlaceholder.textAlignment = NSTextAlignmentCenter;
        signaturePlaceholder.textColor = [UIColor lightGrayColor];
        signaturePlaceholder.userInteractionEnabled = NO;
        [self addSubview:signaturePlaceholder];
        //
//        clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [clearBtn setFrame:CGRectMake(self.bounds.size.width-75, 5, 70, 30)];
//       // [clearBtn setBackgroundImage:[ApplicationDelegate imageFromColor:UIColorFromRGB(0xe3e3e3) forSize:clearBtn.frame.size] forState:UIControlStateNormal];
//        [clearBtn setTitle:NSLocalizedString(@"com.charmehr.kiosk.consent.sign.view.clear.action.key", @"Clear") forState:UIControlStateNormal];
//     //   [clearBtn setTitleColor:UIColorFromRGB(0x2b2b2b) forState:UIControlStateNormal];
//       // clearBtn.titleLabel.font = [UIFont fontWithName:FONT_FAMILY_NORMAL size:16.0f];
//        [clearBtn addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:clearBtn];
        //
    }
    return self;
}

- (void) setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    signaturePlaceholder.text = _placeholder;
}


- (void) drawRect:(CGRect)rect
{
    [self.incrementalImage drawInRect:rect];
    [path stroke];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    signaturePlaceholder.hidden = YES;
    hasMoved = FALSE;
    ctr = 0;
    pts[ctr] = [[touches anyObject] locationInView:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    hasMoved = TRUE;
    pts[++ctr] = [[touches anyObject] locationInView:self];
    if(ctr == 4) //i.e reached the first control point of next segment
    {
        pts[3] = CGPointMake((pts[2].x+pts[4].x)/2.0f, (pts[2].y+pts[4].y)/2.0f);
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        [self setNeedsDisplay];
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}
*/
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!hasMoved)
    {
        [path moveToPoint:pts[0]];
        [path addLineToPoint:[[touches anyObject] locationInView:self]];
    }
    else
    {
    }
    [self drawBitMap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
    hasMoved = FALSE;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void) drawBitMap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0f);
    [[UIColor blackColor] setStroke];
    if(!self.incrementalImage)
    {
        UIBezierPath *bzPath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [bzPath fill];
    }
    [self.incrementalImage drawAtPoint:CGPointZero];
    [path stroke];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void) clear
{
    self.incrementalImage = nil;
    [self setNeedsDisplay];
    signaturePlaceholder.hidden = NO;
}
/*
{
    UIBezierPath *path;
    UIImage *incrementalImage;
    CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
    uint ctr;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:2.0];
    }
    return self;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [incrementalImage drawInRect:rect];
    [path stroke];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}
- (void)drawBitmap
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    if (!incrementalImage) // first time; paint background white
    {
        UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds];
        [[UIColor whiteColor] setFill];
        [rectpath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [[UIColor blackColor] setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
*/
@end
