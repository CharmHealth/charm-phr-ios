//
//  MDTextView.m
//  ChARM_Kiosk
//
//  Created by ZOHOCORP\perumal-0055 on 03/06/13.
//  Copyright (c) 2013 test. All rights reserved.
//

#import "MDTextView.h"





@interface DefaultTextViewDelegationHandler : NSObject <UITextViewDelegate>


@property (nonatomic, unsafe_unretained) id<MDTextViewDelegate> mdDelegate;
@property (nonatomic, unsafe_unretained) id<MDTextViewDelegate> mdTextViewDelegateForScrollView;


@end



@implementation DefaultTextViewDelegationHandler




#pragma mark -
#pragma mark UITextViewDelegate methods


- (BOOL) textViewShouldBeginEditing:(MDTextView *)mdTextView
{
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextViewShouldBeginEditing:)] )
    {
        return [self.mdDelegate mdTextViewShouldBeginEditing:mdTextView];
    }
    
    return YES;
}




- (void) textViewDidBeginEditing:(MDTextView *)mdTextView
{
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextViewDidBeginEditing:)] )
    {
        [self.mdDelegate mdTextViewDidBeginEditing:mdTextView];
    }
    
    if ( [self.mdTextViewDelegateForScrollView conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdTextViewDelegateForScrollView respondsToSelector:@selector(mdTextViewDidBeginEditing:)] )
    {
        [self.mdTextViewDelegateForScrollView mdTextViewDidBeginEditing:mdTextView];
    }

}




-  (BOOL) textViewShouldEndEditing:(MDTextView *)mdTextView
{
    
    if ( mdTextView.maxLength != -1 && [mdTextView.text length] > mdTextView.maxLength )
    {
        return NO;
    }
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextViewShouldEndEditing:)] )
    {
        return [self.mdDelegate mdTextViewShouldEndEditing:mdTextView];
    }
    
    return YES;
}




- (void) textViewDidEndEditing:(MDTextView *)mdTextView
{
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextViewDidEndEditing:)] )
    {
        [self.mdDelegate mdTextViewDidEndEditing:mdTextView];
    }
    
}




- (BOOL) textView:(MDTextView *)mdTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    
    if ( replacementText && [replacementText length] == 0 )
    {
        if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextView:shouldChangeCharactersInRange:replacementString:)] )
        {
            return [self.mdDelegate mdTextView:mdTextView shouldChangeCharactersInRange:range replacementString:replacementText];
        }
        else
        {
            return YES;
        }
    }
    
    if ( mdTextView.maxLength != -1 )
    {
    
        if (  [mdTextView.text length] >= mdTextView.maxLength )
        {
            return NO;
        }
        
        NSString *text = mdTextView.text;
        NSString *replacedText = [text stringByReplacingCharactersInRange:range withString:replacementText];
        if ( [replacedText length] > mdTextView.maxLength )
        {
            return NO;
        }
        
    }
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextView:shouldChangeCharactersInRange:replacementString:)] )
    {
        return [self.mdDelegate mdTextView:mdTextView shouldChangeCharactersInRange:range replacementString:replacementText];
    }
    
    
    return TRUE;
}




- (void) textViewDidChange:(MDTextView *)mdTextView
{
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextViewDidChange:)] )
    {
        [self.mdDelegate mdTextViewDidChange:mdTextView];
    }
    
}




- (void) mdTextViewDidChangeSelection:(MDTextView *)mdTextView
{
    
    if ( [self.mdDelegate conformsToProtocol:@protocol(MDTextViewDelegate)] && [self.mdDelegate respondsToSelector:@selector(mdTextViewDidChangeSelection:)] )
    {
        [self.mdDelegate mdTextViewDidChangeSelection:mdTextView];
    }
    
}




@end







@interface MDTextView ()

@property (nonatomic, strong) DefaultTextViewDelegationHandler *delegationHandler;

@end


@implementation MDTextView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Initialization code
        self.maxLength = -1;
        self.minLength = -1;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        self.maxLength = -1;
        self.minLength = -1;
    }
    
    return self;
}



- (void) setDelegate:(id<MDTextViewDelegate>)delegate
{
    if ( !self.delegationHandler )
    {
        self.delegationHandler = [[DefaultTextViewDelegationHandler alloc] init];
        super.delegate = self.delegationHandler;
    }
    
    self.delegationHandler.mdDelegate = delegate;
}

-(void) setMdTextViewDelegateForScrollView:(id<MDTextViewDelegate>)mdTextViewDelegateForScrollView
{
    
    if ( ! self.delegationHandler )
    {
        self.delegationHandler = [[DefaultTextViewDelegationHandler alloc] init];
        super.delegate = self.delegationHandler;
    }
    
    self.delegationHandler.mdTextViewDelegateForScrollView = mdTextViewDelegateForScrollView;
}


@end
