//
//  MDFLTextField.m
//  ChARM Chart Notes
//
//  Created by Dhanuprasanya P on 19/06/17.
//  Copyright © 2017 MedicalMine Inc. All rights reserved.
//

#import "MDFLTextField.h"
#import "NSStringExtension.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static CGFloat const kFloatingLabelShowAnimationDuration = 0.3f;
static CGFloat const kFloatingLabelHideAnimationDuration = 0.3f;

@implementation MDFLTextField
{
    BOOL _isFloatingLabelFontDefault;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    //TODO:
    [super setFrame:frame];
    
    self.line.frame = CGRectMake(0,frame.size.height-1 ,frame.size.width, 1);
}

- (void)commonInit
{
    _floatingLabel = [UILabel new];
    _floatingLabel.alpha = 0.0f;
    [self addSubview:_floatingLabel];
    
    // some basic default fonts/colors
    
      _floatingLabelFont = [self defaultFloatingLabelFont];
      _floatingLabel.font = _floatingLabelFont;
      _floatingLabelTextColor = UIColorFromRGB(0x333333FF);
      _floatingLabel.textColor = _floatingLabelTextColor;

    
    _floatingLabelReductionRatio = 80;
    _animateEvenIfNotFirstResponder = NO;
    _floatingLabelShowAnimationDuration = kFloatingLabelShowAnimationDuration;
    _floatingLabelHideAnimationDuration = kFloatingLabelHideAnimationDuration;
    [self setFloatingLabelText:self.placeholder];
    _adjustsClearButtonRect = YES;
    _isFloatingLabelFontDefault = YES;
    _floatingLabelActiveTextColor = UIColorFromRGB(0x333333FF);
    _placeholderColor = UIColorFromRGB(0x333333AD);
    //TODO:
    _isMandatoryField = NO;
    //TODO: changed to YES
    _keepBaseline = NO;
    self.contentVerticalAlignment =  UIControlContentVerticalAlignmentBottom;
}

- (CALayer *)line
{
    if (!_line)
    {
        _line = [[CALayer alloc]init];
        _line.backgroundColor = UIColorFromRGB(0xFFFFFFFF).CGColor;

        [self.layer addSublayer:_line];
    }

    return _line;
}

-(void)setIsMandatoryField:(BOOL)isMandatoryField
{
    _isMandatoryField = isMandatoryField;
    if(isMandatoryField)
    {
        if(self.placeholder && ![self.placeholder isEmptyString] && ![self.placeholder hasSuffix:@"*"])
        {
            [self addStarAfterPlaceHolderText];
        }
//        if(self.floatingLabel.text && ![self.floatingLabel.text isEmptyString] && ![self.floatingLabel.text hasSuffix:@"*"])
//        {
//            [self addStarAfterFloatingLblText];
//        }
    }
    else
    {
        if(self.placeholder && ![self.placeholder isEmptyString] && [self.placeholder hasSuffix:@"*"])
        {
            [self removeStarAfterPlaceHolderText];
        }
//        if(self.floatingLabel.text && ![self.floatingLabel.text isEmptyString] && [self.floatingLabel.text hasSuffix:@"*"])
//        {
//            [self removeStarAfterFloatingLabelText];
//        }

    }
}

- (void) addStarAfterPlaceHolderText
{
    NSDictionary *textAttribDict = @{NSForegroundColorAttributeName:self.placeholderColor};
    NSDictionary *starAttribDict = @{NSForegroundColorAttributeName:[UIColor redColor]};
    NSMutableAttributedString *placeHolderStr = [[NSMutableAttributedString alloc] initWithString:self.placeholder attributes:textAttribDict];
    NSMutableAttributedString *starStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" *"] attributes:starAttribDict];
    [placeHolderStr appendAttributedString:starStr];
    [self setAttributedPlaceholder:placeHolderStr floatingTitle:self.placeholder];
}

- (void) addStarAfterFloatingLblText
{
    NSDictionary *textAttribDict = @{NSForegroundColorAttributeName:UIColorFromRGB(0x333333FF)};
    NSDictionary *starAttribDict = @{NSForegroundColorAttributeName:[UIColor redColor]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.floatingLabel.text attributes:textAttribDict];
    NSMutableAttributedString *starStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" *"] attributes:starAttribDict];
    [str appendAttributedString:starStr];
    self.floatingLabel.attributedText = str;
}
- (void) removeStarAfterPlaceHolderText
{
    NSMutableAttributedString *placeHolderStr = [[NSMutableAttributedString alloc] initWithString:self.placeholder];
    [placeHolderStr deleteCharactersInRange:NSMakeRange([placeHolderStr length]-2, 2)];
    [self setAttributedPlaceholder:placeHolderStr floatingTitle:self.placeholder];
}

- (void) removeStarAfterFloatingLabelText
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.floatingLabel.text];
    [str deleteCharactersInRange:NSMakeRange([str length]-2, 2)];
    self.floatingLabel.attributedText = str;
}

- (void)setIsAutocompleteTextField:(BOOL)isAutocompleteTextField
{
    [super setIsAutocompleteTextField:isAutocompleteTextField];
    if(self.rightView)
    {
        self.rightView.frame = CGRectMake(0, 0, 12, 8);
    }
    
}

#pragma mark -

- (UIFont *)defaultFloatingLabelFont
{
    UIFont *textFieldFont = nil;
    
    if (!textFieldFont && self.attributedPlaceholder && self.attributedPlaceholder.length > 0) {
        textFieldFont = [self.attributedPlaceholder attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont && self.attributedText && self.attributedText.length > 0) {
        textFieldFont = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    if (!textFieldFont) {
        textFieldFont = self.font;
    }
    
    return [UIFont fontWithName:textFieldFont.fontName size:roundf(textFieldFont.pointSize * (_floatingLabelReductionRatio/100))];
}

- (void)updateDefaultFloatingLabelFont
{
    UIFont *derivedFont = [self defaultFloatingLabelFont];
    
    if (_isFloatingLabelFontDefault) {
        self.floatingLabelFont = derivedFont;
    }
    else {
        // dont apply to the label, just store for future use where floatingLabelFont may be reset to nil
        _floatingLabelFont = derivedFont;
    }
}

- (UIColor *)labelActiveColor
{
    if (_floatingLabelActiveTextColor) {
        return _floatingLabelActiveTextColor;
    }
    else if ([self respondsToSelector:@selector(tintColor)]) {
        return [self performSelector:@selector(tintColor)];
    }
    return [UIColor blueColor];
}

- (void)setFloatingLabelFont:(UIFont *)floatingLabelFont
{
    if (floatingLabelFont != nil) {
        _floatingLabelFont = floatingLabelFont;
    }
    _floatingLabel.font = _floatingLabelFont ? _floatingLabelFont : [self defaultFloatingLabelFont];
    _isFloatingLabelFontDefault = floatingLabelFont == nil;
    [self invalidateIntrinsicContentSize];
}

- (void)showFloatingLabel:(BOOL)animated
{
    void (^showBlock)() = ^{
        _floatingLabel.alpha = 1.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                          _floatingLabelYPadding,
                                          _floatingLabel.frame.size.width,
                                          _floatingLabel.frame.size.height);
    };
    
    if (animated || 0 != _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelShowAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                         animations:showBlock
                         completion:nil];
    }
    else {
        showBlock();
    }
}

- (void)hideFloatingLabel:(BOOL)animated
{
    void (^hideBlock)() = ^{
        _floatingLabel.alpha = 0.0f;
        _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                          _floatingLabel.font.lineHeight + _placeholderYPadding,
                                          _floatingLabel.frame.size.width,
                                          _floatingLabel.frame.size.height);
        
    };
    
    if (animated || 0 != _animateEvenIfNotFirstResponder) {
        [UIView animateWithDuration:_floatingLabelHideAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:hideBlock
                         completion:nil];
    }
    else {
        hideBlock();
    }
}

- (void)setLabelOriginForTextAlignment
{
    CGRect textRect = [self textRectForBounds:self.bounds];
    
    CGFloat originX = textRect.origin.x;
    
    if (self.textAlignment == NSTextAlignmentCenter) {
        originX = textRect.origin.x + (textRect.size.width/2) - (_floatingLabel.frame.size.width/2);
    }
    else if (self.textAlignment == NSTextAlignmentRight) {
        originX = textRect.origin.x + textRect.size.width - _floatingLabel.frame.size.width;
    }
    //TODO: commented
    else if (self.textAlignment == NSTextAlignmentNatural) {
        //        JVTextDirection baseDirection = [_floatingLabel.text getBaseDirection];
        //        if (baseDirection == JVTextDirectionRightToLeft) {
        //            originX = textRect.origin.x + textRect.size.width - _floatingLabel.frame.size.width;
        //        }
    }
    
    _floatingLabel.frame = CGRectMake(originX + _floatingLabelXPadding, _floatingLabel.frame.origin.y,
                                      _floatingLabel.frame.size.width, _floatingLabel.frame.size.height);
}

- (void)setFloatingLabelText:(NSString *)text
{
    
//    if(text)
//    {
//    NSDictionary *textAttribDict = @{NSForegroundColorAttributeName: UIColorFromRGB(NAVIGATION_BAR_COLOR)};
//    NSDictionary *starAttribDict = @{NSForegroundColorAttributeName:[UIColor redColor]};
//    NSMutableAttributedString *attribStr = [[NSMutableAttributedString alloc] initWithString:text attributes:textAttribDict];
//    NSMutableAttributedString *starStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" *"] attributes:starAttribDict];
//    
//    [attribStr appendAttributedString:starStr];

    _floatingLabel.text = text;
    if (self.floatingLabel.text && [self.floatingLabel.text hasSuffix:@"*"]){
        [self removeStarAfterFloatingLabelText];
    }
  //  }
    [self setNeedsLayout];
}




#pragma mark - UITextField

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self updateDefaultFloatingLabelFont];
}

- (void)setFloatingLabelReductionRatio:(CGFloat)floatingLabelReductionRatio
{
    _floatingLabelReductionRatio = floatingLabelReductionRatio;
    _floatingLabelFont = [self defaultFloatingLabelFont];
    _floatingLabel.font = _floatingLabelFont;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self updateDefaultFloatingLabelFont];
}

- (CGSize)intrinsicContentSize
{
    CGSize textFieldIntrinsicContentSize = [super intrinsicContentSize];
    [_floatingLabel sizeToFit];
    return CGSizeMake(textFieldIntrinsicContentSize.width,
                      textFieldIntrinsicContentSize.height + _floatingLabelYPadding + _floatingLabel.bounds.size.height);
}

- (void)setCorrectPlaceholder:(NSString *)placeholder
{
    if (self.placeholderColor && placeholder) {
        NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                                    attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
        [super setAttributedPlaceholder:attributedPlaceholder];
    } else {
        [super setPlaceholder:placeholder];
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [self setCorrectPlaceholder:placeholder];
    [self setFloatingLabelText:placeholder];
    if(self.isMandatoryField)
    {
        [self addStarAfterPlaceHolderText];
    }
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    [super setAttributedPlaceholder:attributedPlaceholder];
    [self setFloatingLabelText:attributedPlaceholder.string];
    [self updateDefaultFloatingLabelFont];
}

- (void)setPlaceholder:(NSString *)placeholder floatingTitle:(NSString *)floatingTitle
{
    [self setCorrectPlaceholder:placeholder];
    [self setFloatingLabelText:floatingTitle];
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder floatingTitle:(NSString *)floatingTitle
{
    [super setAttributedPlaceholder:attributedPlaceholder];
    [self setFloatingLabelText:floatingTitle];
}


- (void)setPlaceholderColor:(UIColor *)color
{
    _placeholderColor = color;
    [self setCorrectPlaceholder:self.placeholder];
}
/*
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect rect = [super textRectForBounds:bounds];
//     if ([self.text length] || self.keepBaseline)
//    {
//        rect = [self insetRectForBounds:rect];
//    }
//    return CGRectIntegral(rect);
    rect = CGRectMake(rect.origin.x,rect.origin.y , rect.size.width, rect.size.height-4);
    return rect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    rect = CGRectMake(rect.origin.x,rect.origin.y , rect.size.width, rect.size.height-4);
    return rect;

//     if ([self.text length] || self.keepBaseline)
//    {
//        rect = [self insetRectForBounds:rect];
//    }
//    return CGRectIntegral(rect);
}

- (UIView*)setDisabledView
{
    self.disabledBgView = [[UIView alloc]init];
    [self.floatingLabel sizeToFit];
//    CGFloat y =  self.bounds.origin.y+self.floatingLabel.bounds.origin.y+self.floatingLabel.bounds.size.height+2;
    CGRect rect = CGRectMake(self.bounds.origin.x,self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height-3);
    self.disabledBgView.backgroundColor = UIColorFromRGB(GRAY_BACKGROUND_COLOR);//[UIColor redColor];
    self.disabledBgView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    [self addSubview:self.disabledBgView];
    return self.disabledBgView;
}

- (CGRect)insetRectForBounds:(CGRect)rect
{
    //TODO: modified this line to adjust placeholder text
    //    CGFloat topInset = ceilf(_floatingLabel.bounds.size.height + _placeholderYPadding);
    CGSize floatingLabelSize = [_floatingLabel sizeThatFits:_floatingLabel.superview.bounds.size];
    CGFloat topInset;
    //TODO:
    if(floatingLabelSize.height)
        topInset = ceilf(floatingLabelSize.height + _placeholderYPadding);
    else
        topInset = ceilf(self.frame.size.height-1);
    topInset = MIN(topInset, [self maxTopInset]);
    return CGRectMake(rect.origin.x, rect.origin.y + topInset / 2.0f, rect.size.width, rect.size.height);
}
*/
- (CGRect)clearButtonRectForBounds:(CGRect)bounds
{
    CGRect rect = [super clearButtonRectForBounds:bounds];
    if (0 != self.adjustsClearButtonRect
        //&& _floatingLabel.text.length // for when there is no floating title label text
        ) {
          //if ([self.text length] || self.keepBaseline)
        if(self.keepBaseline)
        {
            CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
            topInset = MIN(topInset, [self maxTopInset]);
            rect = CGRectMake(bounds.size.width-rect.size.width+2 , rect.origin.y + topInset / 2.0f, rect.size.width, rect.size.height);
            //NOTE: +2 just for allignment
        }
    }
    return CGRectIntegral(rect);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super leftViewRectForBounds:bounds];
    
    CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
    topInset = MIN(topInset, [self maxTopInset]);
    rect = CGRectOffset(rect, 0, topInset / 2.0f);
    
    return rect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rect = [super rightViewRectForBounds:bounds];
//    CGFloat topInset = ceilf(_floatingLabel.font.lineHeight + _placeholderYPadding);
//    topInset = MIN(topInset, [self maxTopInset]);
//    rect = CGRectOffset(rect, 0, topInset / 2.0f);
    rect = CGRectMake(rect.origin.x,self.bounds.size.height-rect.size.height-5, rect.size.width, rect.size.height);//-5 adjustment some space
    return rect;
}

- (CGFloat)maxTopInset
{
    return MAX(0, floorf(self.bounds.size.height - self.font.lineHeight - 4.0f));
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsLayout];
}

- (void)setAlwaysShowFloatingLabel:(BOOL)alwaysShowFloatingLabel
{
    _alwaysShowFloatingLabel = alwaysShowFloatingLabel;
    [self setNeedsLayout];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setLabelOriginForTextAlignment];
    
    CGSize floatingLabelSize = [_floatingLabel sizeThatFits:_floatingLabel.superview.bounds.size];
    _floatingLabel.frame = CGRectMake(_floatingLabel.frame.origin.x,
                                         _floatingLabel.frame.origin.y,
                                         floatingLabelSize.width,
                                          floatingLabelSize.height);
    
    if(!self.translatesAutoresizingMaskIntoConstraints)
    {
        self.line.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    }
    BOOL firstResponder = self.isFirstResponder;
    _floatingLabel.textColor = (firstResponder && self.text && self.text.length > 0 ?
                                self.labelActiveColor : self.floatingLabelTextColor);
    if ((!self.text || 0 == [self.text length]) && !self.alwaysShowFloatingLabel) {
        [self hideFloatingLabel:firstResponder];
    }
    else {
        [self showFloatingLabel:firstResponder];
    }
}


@end
