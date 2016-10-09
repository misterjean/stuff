//
//  CCCrewcamAlertView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-14.
//
//

#import "CCCrewcamAlertView.h"

@implementation CCCrewcamAlertView
@synthesize alertView;
@synthesize alertTextView;
@synthesize alertCloseButton;
@synthesize mainButton;
@synthesize secondaryButton;
@synthesize backgroundView;
@synthesize alertViewTitleLabel;
@synthesize buttonsView;
@synthesize alertTextField;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (id) init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"CustomAlertView" owner:self options:nil] objectAtIndex:0];
    
    if (self)
    {
        alertView.layer.cornerRadius = 7;
        [alertTextView setFont:[UIFont getSteelfishFontForSize:20]];
        [alertViewTitleLabel setFont:[UIFont getSteelfishFontForSize:30]];
        [mainButton setFont:[UIFont getSteelfishFontForSize:30]];
        [secondaryButton setFont:[UIFont getSteelfishFontForSize:30]];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message withTextField:(BOOL) withTextField delegate:(id<CCCrewcamAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self init];
    
    if (self)
    {
        if (withTextField)
        {
            [alertTextField setHidden:NO];
        }
        else
        {
            [alertTextField setHidden:YES];
        }
        
        [alertView setHidden:YES];
        
        if (title)
            [alertViewTitleLabel setText:[title uppercaseString]];
        
        [alertTextView setText:message];
        
        CGFloat bottomCorrect;
        if (withTextField)
        {
            bottomCorrect = 220;
        }
        else
        {
            bottomCorrect = ([alertTextView bounds].size.height - [alertTextView contentSize].height);
        }
        
        alertView.frame = CGRectMake(alertView.frame.origin.x, alertView.frame.origin.y, alertView.frame.size.width, alertView.frame.size.height - bottomCorrect);
        
        buttonsView.frame = CGRectMake(buttonsView.frame.origin.x, buttonsView.frame.origin.y - bottomCorrect, buttonsView.frame.size.width, buttonsView.frame.size.height);
        
        if (otherButtonTitles && cancelButtonTitle)
        {
            // We have to show two buttons
            [secondaryButton setHidden:NO];
            [mainButton setTitle:[otherButtonTitles uppercaseString] forState:UIControlStateNormal];
            [secondaryButton setTitle:[cancelButtonTitle uppercaseString] forState:UIControlStateNormal];
            [alertCloseButton setHidden:YES];
            buttonsView.frame = CGRectMake(buttonsView.frame.origin.x, buttonsView.frame.origin.y + 7, buttonsView.frame.size.width, buttonsView.frame.size.height);

        }
        else
        {
            if (otherButtonTitles)
                [mainButton setTitle:[otherButtonTitles uppercaseString] forState:UIControlStateNormal];
            else if (cancelButtonTitle)
                [mainButton setTitle:[cancelButtonTitle uppercaseString] forState:UIControlStateNormal];
            else
                [mainButton setHidden:YES];
        
            // Center the button, and make it laaarge
            mainButton.frame = CGRectMake(0, mainButton.frame.origin.y, buttonsView.frame.size.width, mainButton.frame.size.height);
        }
        
        alertDelegate = delegate;
    }
    
    return self;
}

- (void) dealloc
{
    [self setAlertView:nil];
    [self setAlertTextView:nil];
    [self setAlertCloseButton:nil];
    [self setMainButton:nil];
    [self setSecondaryButton:nil];
    [self setBackgroundView:nil];
    [self setAlertViewTitleLabel:nil];
    [self setButtonsView:nil];
    [self setAlertTextField:nil];
    
    alertDelegate = nil;
}

- (void)show
{
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    [window addSubview:self];
    
    // Resign any first responders
    for (UIView *subview in [window subviews]) {        
        [subview endEditing:YES];
    }
    
    [self animateInStepOne];
}

- (IBAction)didPressSecondaryButton:(id)sender {
    [self animateOutStepOne];
    
    if (alertDelegate)
        [alertDelegate alertView:self clickedButtonAtIndex:0];
}

- (IBAction)didPressMainButton:(id)sender {
    [self animateOutStepOne];
    
    if (alertDelegate)
        [alertDelegate alertView:self clickedButtonAtIndex:1];
}

- (void)animateInStepOne {    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:FADE_TIME];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateInStepTwo)];
    backgroundView.alpha = 1;
    [UIView commitAnimations];
}

- (void)animateInStepTwo {
    
    [UIView transitionWithView:alertView duration:FLIP_TIME options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
        [alertView setHidden:NO];
        
        if (![alertTextField isHidden])
            [alertTextField becomeFirstResponder];
        
    } completion:nil];
}

- (void)animateOutStepOne {
    [UIView transitionWithView:alertView duration:FLIP_TIME options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
        [alertView setHidden:YES];
        
    } completion:^(BOOL finished) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:FADE_TIME];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        backgroundView.alpha = 0;
        [UIView commitAnimations];
    }];
}

- (IBAction)didPressCloseButton:(id)sender {
    [self animateOutStepOne];
    
    if (alertDelegate)
        [alertDelegate alertView:self clickedButtonAtIndex:0];
}

- (UITextField *) getTextField
{
    return alertTextField;
}

@end
