//
//  CCTutorialPopover.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-16.
//
//

#import "CCTutorialPopover.h"

@implementation CCTutorialPopover
@synthesize textBackground;
@synthesize tutorialTextView;
@synthesize glowImageView;
@synthesize glowingPointerView;
@synthesize pointerView;
@synthesize buttonOverlay;

- (id) init
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"HelpPopoverView" owner:self options:nil] objectAtIndex:0];
    
    if (self)
    {
        textBackground.layer.cornerRadius = 7;
        didCancelFade = NO;
    }
    
    return self;
}

- (id)initWithMessage:(NSString *) message pointsDirection:(ccTutorialPopoverDirections) direction withTargetPoint:(CGPoint) targetPoint andParentView:(UIView *) targetView
{
    self = [self init];
    
    if (!self)
        return nil;
    
    self->parentView = targetView;
    
    [self setupViewWithText:message];
    
    CGPoint arrowPoint;
    
    switch (direction)
    {
        case ccTutorialPopoverDirectionDown:
        {
            [pointerView setImage:[UIImage imageNamed:@"indicator-down.png"]];
            
            arrowPoint = CGPointMake(glowingPointerView.frame.origin.x + glowingPointerView.frame.size.width/2, glowingPointerView.frame.origin.y + glowingPointerView.frame.size.height);
            
            tutorialTextView.frame = CGRectMake(tutorialTextView.frame.origin.x, tutorialTextView.frame.origin.y - 10, tutorialTextView.frame.size.width, tutorialTextView.frame.size.height);
            
            textBackground.frame = CGRectMake(textBackground.frame.origin.x, textBackground.frame.origin.y - 10, textBackground.frame.size.width, textBackground.frame.size.height);
            
            break;
        }
        case ccTutorialPopoverDirectionLeft:
        {
            [pointerView setImage:[UIImage imageNamed:@"CC_indicator-left.png"]];
            
            textBackground.frame = CGRectMake(textBackground.frame.origin.x, textBackground.frame.origin.y, textBackground.frame.size.width + 20, textBackground.frame.size.height);

            tutorialTextView.frame = CGRectMake(tutorialTextView.frame.origin.x + 5, tutorialTextView.frame.origin.y + 3, tutorialTextView.frame.size.width + 10, tutorialTextView.frame.size.height);
            
            glowingPointerView.frame = CGRectMake(0, textBackground.frame.origin.y + textBackground.frame.size.height/2 - glowingPointerView.frame.size.height/2, glowingPointerView.frame.size.height, glowingPointerView.frame.size.width);
            
            arrowPoint = CGPointMake(glowingPointerView.frame.origin.x, glowingPointerView.frame.origin.y + glowingPointerView.frame.size.height/2);
            break;
        }
        case ccTutorialPopoverDirectionRight:
        {
            break;
        }
        case ccTutorialPopoverDirectionUp:
        {
            [pointerView setImage:[UIImage imageNamed:@"CC_indicator-up.png"]];
            
            textBackground.frame = CGRectMake(textBackground.frame.origin.x - 20, textBackground.frame.origin.y + 15, textBackground.frame.size.width + 40, textBackground.frame.size.height - 30);
            
            tutorialTextView.frame = CGRectMake(tutorialTextView.frame.origin.x -20, tutorialTextView.frame.origin.y + 20, tutorialTextView.frame.size.width + 40, tutorialTextView.frame.size.height);
            
            glowingPointerView.frame = CGRectMake(glowingPointerView.frame.origin.x, textBackground.frame.origin.y - 24, glowingPointerView.frame.size.height, glowingPointerView.frame.size.width);
            
            arrowPoint = CGPointMake(glowingPointerView.frame.origin.x + glowingPointerView.frame.size.width/2, glowingPointerView.frame.origin.y);
            break;
        }
        case ccTutorialPopoverDirectionNone:
        {
            textBackground.frame = CGRectMake(textBackground.frame.origin.x, textBackground.frame.origin.y, textBackground.frame.size.width + 50, textBackground.frame.size.height - 30);
            
            tutorialTextView.frame = CGRectMake(tutorialTextView.frame.origin.x, tutorialTextView.frame.origin.y, tutorialTextView.frame.size.width + 50, tutorialTextView.frame.size.height);
            
            arrowPoint = CGPointMake(textBackground.frame.size.width/2 + textBackground.frame.origin.x, textBackground.frame.size.height/2 + textBackground.frame.origin.y);
            
            [glowingPointerView setHidden:YES];
            break;
        }
    }
    
    int xAdjust = targetPoint.x - arrowPoint.x;
    int yAdjust = targetPoint.y - arrowPoint.y;
    
    [self setFrame:CGRectMake(self.frame.origin.x + xAdjust, self.frame.origin.y + yAdjust, self.frame.size.width, self.frame.size.height)];
    
    return self;
}

- (void) dealloc
{
    [self setTextBackground:nil];
    [self setTutorialTextView:nil];
    [self setGlowImageView:nil];
    [self setGlowingPointerView:nil];
    [self setButtonOverlay:nil];
}

- (void) setupViewWithText:(NSString *) message
{
    [tutorialTextView setText:message];
    
    CGFloat bottomCorrect = ([tutorialTextView bounds].size.height - [tutorialTextView contentSize].height);

    CGFloat rightCorrect = ([tutorialTextView bounds].size.width - [tutorialTextView contentSize].width);
    
    [glowingPointerView setFrame:CGRectMake(glowingPointerView.frame.origin.x, glowingPointerView.frame.origin.y - bottomCorrect, glowingPointerView.frame.size.width, glowingPointerView.frame.size.height)];
    
    [textBackground setFrame:CGRectMake(textBackground.frame.origin.x, textBackground.frame.origin.x, textBackground.frame.size.width - rightCorrect, textBackground.frame.size.height - bottomCorrect)];
    
    [tutorialTextView setFrame:CGRectMake(tutorialTextView.frame.origin.x, tutorialTextView.frame.origin.x, tutorialTextView.frame.size.width - rightCorrect, tutorialTextView.frame.size.height - bottomCorrect)];
    
    [buttonOverlay setFrame:CGRectMake(buttonOverlay.frame.origin.x, buttonOverlay.frame.origin.x, buttonOverlay.frame.size.width - rightCorrect, buttonOverlay.frame.size.height - bottomCorrect)];
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.x, self.frame.size.width, self.frame.size.height - bottomCorrect)];
}

- (void) show
{
    [parentView addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
         [self setAlpha:1];
    } completion:^(BOOL finished) {
        [self startGlowing]; 
    }];
}

- (IBAction)didPressOverlay:(id)sender
{
    [self dismiss];
}

- (void) showInView:(UIView *) view
{
    [view addSubview:self];
    
    [self startGlowing];
}

- (void) dismiss
{
    didCancelFade = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:0];
    } completion:nil];
}

- (void) startGlowing
{
    NSCondition *fadeCompleteCondition = [[NSCondition alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!didCancelFade)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fadeInThenOutWithBlock:^(BOOL succeeded, NSError *error) {
                    [fadeCompleteCondition signal];
                }];
            });
            
            // Wait on the background thread
            [fadeCompleteCondition lock];
            [fadeCompleteCondition wait];
            [fadeCompleteCondition unlock];
        }
    });
}

- (void) fadeInThenOutWithBlock:(CCBooleanResultBlock) block
{
    [UIView transitionWithView:glowImageView duration:1 options:UIViewAnimationOptionCurveLinear animations:^{
        [glowImageView setAlpha:0];
    } completion:^(BOOL finished) {
        [UIView transitionWithView:glowImageView duration:1 options:UIViewAnimationOptionCurveLinear animations:^{
            [glowImageView setAlpha:1];
        } completion:^(BOOL finished) {
            block(YES, nil);
        }];
        
    }];
}

@end
