//
//  MDTextView.h
//  ChARM_Kiosk
//
//  Created by ZOHOCORP\perumal-0055 on 03/06/13.
//  Copyright (c) 2013 test. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MDTextView;

/*
 *  @Version 1.0
 *
 *  @durai
 *
 *  The main purpose of the MDTextFieldDelegate is to type specific handlings including the maximum or minimum length checks.
 *  This MDTextField extends UIView. It has a UITextField as a member. This will be added over the UIView, but covers entire view.
 *  It is handled in the initWithFrame mehtod. So for external use it will behave as a full-fledged UITextField, but rellay it is
 *  a UIView which has a UITextField as a subview. To give the full support as if a UITextField here it declares all the attributes/members/variables declared by a UITextField. And also it defines all the setter and getter methods. Through those setter
 *  methods this MDTextField view set all the values to the actual UITextField sub-view. In all getter methods, this MDTextField get the value from the actual UITextField and then returns.
 *  Other than these default attributes MDTextField declares a few extra attributes such as MDTextFieldType, minLength, maxLength, pattern. These attributes are used to handle/restrict the data to specific data type, length contraints.
 *
 *
 */



@protocol MDTextViewDelegate <NSObject>

@optional

//  Editing the Text Field’s Text

- (BOOL)mdTextView:(MDTextView *)textView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)mdViewFieldShouldClear:(MDTextView *)textView;
- (BOOL)mdTextViewShouldReturn:(MDTextView *)textView;

//  Managing Editing
- (BOOL)mdTextViewShouldBeginEditing:(MDTextView *)textView;
- (void)mdTextViewDidBeginEditing:(MDTextView *)textView;
- (BOOL)mdTextViewShouldEndEditing:(MDTextView *)textView;
- (void)mdTextViewDidEndEditing:(MDTextView *)textView;
- (void)mdTextViewDidChange:(MDTextView *)textView;
- (void) mdTextViewDidChangeSelection:(MDTextView *)mdTextView;

@end

/*
//TODO:
// i) Add a new type called MDTextFieldTypeClearText - to handle the I18N (or) other languages problem
// ii) Add the following type(s): MDTextFieldEMail
// iii)                           MDTextFieldFax    -- Locale specific
// iv)                            MDTextFieldMobileNumber    -- Locale specific
// v)                             MDTextFieldFax    -- Locale specific
// vi)                            MDTextFieldPostalcode    -- Locale specific
// vii)                           MDTextFieldPhoneNumber    -- Locale specific
//
//Text assigned to the text ivar OR through setText method also should undergo the type/length validation
//
//

typedef enum MDTextViewType {
    
    MDTextViewTypeInteger, // (0-9)
    MDTextViewTypeFloat, // (0-9)(.)(0-9)
    MDTextViewTypeString, // (a-zA-Z)
    MDTextViewTypeAlphaNumeric, // (a-zA-Z)
    MDTextViewTypeAlphaNumericWithSpace, // (a-zA-Z)( )(a-zA-Z)
    MDTextViewEMail, // \b[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b
    MDTextViewTypeSpecificPattern, // any specific pattern defined by the member 'pattern'
    MDTextViewTypeFreeText //simply allows any type
} MDTextViewType;

*/


@interface MDTextView : UITextView <UITextViewDelegate>
////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// TDTextField - extra parameters /////////////////////////////////////


// defines the type of the data that can be entered in the text field
//@property (nonatomic) MDTextViewType TextViewType;

// If the text-field type is MDTextFieldTypeSpecificPattern, then this member-variable holds the respective pattern
//@property (nonatomic, strong) NSString *pattern;


// defines the maximum length limit of the text field - but this may not suit for the
// MDTextFieldTypeSpecificPattern. Because, the corrosponding pattern has to take care
// of the limit if needed. If the maxLength value not specified then it will be -1 OR no limit.
@property (nonatomic) int maxLength;

// defines the minimum length of the data inside the text field
@property (nonatomic) int minLength;

//@property(nonatomic, unsafe_unretained) id<MDTextViewDelegate> mdDelegate;
@property (nonatomic, unsafe_unretained) id<MDTextViewDelegate> mdTextViewDelegateForScrollView;



@end
