//
//  CCCrewIconView.m
//  Crewcam
//
//  Created by Ryan Brink on 2012-07-24.
//
//

#import "CCCrewIconView.h"

@implementation CCCrewIconView
@synthesize addCrewView;
@synthesize addCrewTextView;
@synthesize crewThumbnailView;
@synthesize titleOrangeBackgroundView;
@synthesize detialsBlueBackgroundView;
@synthesize crewDeleteView;
@synthesize crewNameLabel;
@synthesize numberOfVideosLabel;
@synthesize numberOfMembersLabel;
@synthesize numberOfUnwatchedVideosLabel;
@synthesize unwatchedVideosBadge;
@synthesize crew;
@synthesize crewDetailsView;
@synthesize crewTitleView;
@synthesize isShaking;
@synthesize outlineImageView;

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    UISwipeGestureRecognizer *panGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];

    panGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:panGesture];
    
    panGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    panGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPressGesture];

    
    [crewNameLabel setFont:[UIFont getSteelfishFontForSize:20]];
    [addCrewTextView setFont:[UIFont getSteelfishFontForSize:[addCrewTextView frame].size.height]];
    [numberOfVideosLabel setFont:[UIFont getSteelfishFontForSize:20]];
    [numberOfMembersLabel setFont:[UIFont getSteelfishFontForSize:20]];
    
    [[[[CCCoreManager sharedInstance] server] currentUser] addUserUpdateListener:self];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shake) name:@"startShaking" object:nil];
}

BOOL isLongPressInProgress = NO;
- (void)handleLongPress:(UILongPressGestureRecognizer *) recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        isLongPressInProgress = NO;
        return;
    }
    
    if (!recognizer.state == UIGestureRecognizerStateBegan)
        return;
    
    if (isLongPressInProgress)
        return;
    
    isLongPressInProgress = YES;
    
    if (isShaking)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_STOP_SHAKING_CREWS_NOTIFICATION object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_START_SHAKING_CREWS_NOTIFICATION object:nil];
    }    
}

static CCCrewIconView *lastFlippedCrew;
- (void)handleSwipe:(UISwipeGestureRecognizer *) recognizer
{
    if ([self crew] && [crewDetailsView isHidden] && lastFlippedCrew)
        [lastFlippedCrew flipToFrontWithForce:NO];
    
    [UIView transitionWithView:self duration:0.4 options:(recognizer.direction == UISwipeGestureRecognizerDirectionRight) ?UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight animations:^{
        
        if (!crew)
            return;
        
        [crewDetailsView setHidden:![crewDetailsView isHidden]];
        [crewTitleView setHidden:![crewTitleView isHidden]];
        [crewDeleteView setHidden:(![crewTitleView isHidden] && isShaking) ? NO : YES];
        
        if (![crewTitleView isHidden])
        {
            lastFlippedCrew = nil;
        }
        else
        {
            lastFlippedCrew = self;
            [self setNumberOfVideosLabelForced:YES];
            
            [self setNumberOfMembersLabelForced:YES];
        }
            
    } completion:nil];
}

- (void)dealloc
{
    [crew removeCrewUpdateListener:self];
    [crew removeListener:self];
    [[[[CCCoreManager sharedInstance] server] currentUser] removeUserUpdateListener:self]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    newCrewViewController = nil;
    [self setCrewNameLabel:nil];
    [self setNumberOfVideosLabel:nil];
    [self setNumberOfMembersLabel:nil];
    [self setNumberOfUnwatchedVideosLabel:nil];
    [self setUnwatchedVideosBadge:nil];
    [self setCrew:nil];    
}

- (IBAction)onCrewIconPressed:(id)sender
{
    if (crew == nil)
    {
        if (addCrewPopover != nil)
        {
            [addCrewPopover dismiss];
        }
        
        if (!newCrewViewController)
        {
            [[CCCoreManager sharedInstance] recordMetricEvent:CC_BUTTON_PRESS_ADD_CREW withProperties:nil];
            UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"CCMainStoryboard_iPhone" bundle:nil];
            newCrewViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"newCrewView"];
            [newCrewViewController setStoredNavigationController:parentNavigationController];
        }
        
        [parentNavigationController pushViewController:newCrewViewController animated:YES];
        
        return;
    }
    
    CCCrewViewController *crewView = [parentNavigationController.storyboard instantiateViewControllerWithIdentifier:@"crewFeedView"];
    
    [crewView initWithCrew:crew];

    [parentNavigationController pushViewController:crewView animated:YES];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    CCCrewcamAlertView *updateAlert = [[CCCrewcamAlertView alloc] initWithTitle: NSLocalizedStringFromTable(@"LEAVE_CREW", @"Localizable", nil)
                                                                        message: NSLocalizedStringFromTable(@"LEAVING_CREW_CONFIRMATION", @"Localizable", nil)
                                                                  withTextField: NO
                                                                       delegate: self
                                                              cancelButtonTitle: nil
                                                              otherButtonTitles:@"LEAVE CREW", nil];
    {
        [updateAlert show];
    }
}

- (void)alertView:(CCCrewcamAlertView *) alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [[[[CCCoreManager sharedInstance] server] currentUser] removeUserFromCrew:crew WithBlockOrNil:nil];
    }
}

- (void) setCrew:(id<CCCrew>) crewForCell andNavigationController:(UINavigationController *) navigationController andIsShaking:(BOOL) isShakingCurrently
{    
    parentNavigationController = navigationController;
    
    [self setUpViewWithCrew:crewForCell andIsShaking:isShakingCurrently];
}

- (void) shake
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithDouble: -M_PI/64]];
    [anim setFromValue:[NSNumber numberWithDouble:M_PI/64]];
    
    [anim setRepeatCount:NSUIntegerMax];
    [anim setAutoreverses:YES];
    
    
    [anim setDuration:((double)(arc4random()%8)/100.0)+0.07];
    [self.layer addAnimation:anim forKey:@"SpringboardShake"];
    if ([self crew])
        [[self crewDeleteView] setHidden:NO];
    
    [self setIsShaking:YES];
}

- (void) stopShaking
{
    [self.layer removeAnimationForKey:@"SpringboardShake"];
    [[self crewDeleteView] setHidden:YES];
    [self setIsShaking:NO];
}

- (void) setUpViewWithCrew:(id<CCCrew>) crewForCell andIsShaking:(BOOL) isShakingCurrently
{
    isShaking = isShakingCurrently;
    if (isShaking)
    {
        [crewDeleteView setHidden:NO];
    }
    else
    {
        [crewDeleteView setHidden:YES];
    }
    
    if (crew == crewForCell)
        return;        
    
    [crewDetailsView setHidden:YES];
    [crewDeleteView setHidden:[crewDetailsView isHidden]];
    [crewTitleView setHidden:NO];
    [addCrewView setHidden:YES];
    
    [crew removeCrewUpdateListener:self];
    [crew removeListener:self];
    
    crew = crewForCell;
    
    [crew addCrewUpdateListener:self];
    [crew addListener:self];    
    
    // Set up the crew's name
    crewNameLabel.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [crewNameLabel setText:[[crew getName] uppercaseString]];    
    CGFloat topCorrect = ([crewNameLabel bounds].size.height - [crewNameLabel contentSize].height);
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);

    if (crewNameLabel.contentInset.top != topCorrect)
        crewNameLabel.contentInset = UIEdgeInsetsMake(topCorrect, 0, 0, 0);
    
    if([crew numberOfNewVideos] > 0)
    {
        [[self numberOfUnwatchedVideosLabel] setText:[[NSString alloc] initWithFormat:@"%d", [crew numberOfNewVideos]]];
        [unwatchedVideosBadge setHidden:NO];
    }
    else
    {
        [[self numberOfUnwatchedVideosLabel] setText:@""];
        [unwatchedVideosBadge setHidden:YES];
    }
    
    [crewThumbnailView setImage:[crewForCell getCrewIcon]];
    [outlineImageView setHidden:YES];
    
    switch ([crew getCrewtype])
    {
        case CCFBLocation:
            [crewThumbnailView setFrame:CGRectMake(23, 13, 45, 45)];
            break;
        case CCFBSchool:
            [crewThumbnailView setFrame:CGRectMake(14, 2, 66, 66)];
            break;
        case CCFBWork:
            [crewThumbnailView setFrame:CGRectMake(23, 10, 45, 45)];
            break;
        case CCNormal:
            [crewThumbnailView setFrame:CGRectMake(0, 10, 91, 91)];
            break;
        case CCDeveloper:
            [crewNameLabel setText:@""];
            [outlineImageView setHidden:NO];
            [crewThumbnailView setFrame:CGRectMake(0, 10, 91, 91)];
            break;
        default:
            break;
    }
    
    [crewThumbnailView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self updateThumbnail];
}

- (void) updateThumbnail
{
    BOOL hadAlreadyLoadedAThumbnail = [crew hasLoadedThumbnail];
    
    __block id<CCCrew> crewForThumbnail = crew;    
    
    [crew getCrewThumbnailInBackgroundWithBlock:^(UIImage *image, NSError *error) {
        if (crew == crewForThumbnail)
        {
            if (!image)
                return;                        
            
            if (image == crewThumbnailView.image)
                return;
            
            [crewThumbnailView setFrame:CGRectMake(0, 10, 91, 91)];
            [crewThumbnailView setContentMode:UIViewContentModeScaleAspectFill];
            
            [crewThumbnailView setImage:image];
            
            if (image && !hadAlreadyLoadedAThumbnail)
                [self flipToFrontWithForce:YES];
        }
    }];
}

- (void) addedNewVideosAtIndexes:(NSArray *)newVideoIndexes andRemovedVideosAtIndexes:(NSArray *)deletedVideoIndexes
{
    [self updateThumbnail];
}

- (void) setUpForAddCrewWithNavigationController:(UINavigationController *) navigationController
{
    crew = nil;
    
    if ([[[[CCCoreManager sharedInstance] server] currentUser] isUserNewlyActivated] && !addCrewPopover)
    {
        addCrewPopover = [[CCTutorialPopover alloc] initWithMessage:@"Click to add your own crew" pointsDirection:ccTutorialPopoverDirectionLeft withTargetPoint:CGPointMake(91, 53) andParentView:[self superview]];
            
        [addCrewPopover show];
    }
    
    parentNavigationController = navigationController;
    
    [addCrewView setHidden:NO];
    
    [crewDetailsView setHidden:YES];
    [crewDeleteView setHidden:[crewDetailsView isHidden]];
    [crewTitleView setHidden:YES];
}

- (void) flipToFrontWithForce:(BOOL) forceFlip
{
    if (![crewTitleView isHidden] && !forceFlip)
        return;
    
    [UIView transitionWithView:self duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
        [crewDetailsView setHidden:YES];
        [crewDeleteView setHidden:!isShaking];
        [crewTitleView setHidden:NO];
        
    } completion:nil];
}

- (void)setNumberOfVideosLabelForced:(BOOL)forced
{
    __block NSString *videosString;
    
    [crew getNumberOfVideosWithBlock:^(int numberOfUnwatchedVideos, BOOL succeded, NSError *error) {
        if (numberOfUnwatchedVideos == 1)
        {
            videosString = [[NSString alloc] initWithFormat:@"1 VIDEO"];
        }
        else
        {
            videosString = [[NSString alloc] initWithFormat:@"%d VIDEOS", numberOfUnwatchedVideos];
        }                
        
        [numberOfVideosLabel setText:videosString];
        
    } andForced:forced];
}

- (void)setNumberOfMembersLabelForced:(BOOL)forced
{
    __block NSString *membersString;
    [crew getNumberOfMembersWithBlock:^(int numberOfUnwatchedVideos, BOOL succeded, NSError *error) {
        if(numberOfUnwatchedVideos  == 1)
        {
            membersString = [[NSString alloc] initWithFormat:@"1 MEMBER"];
        }
        else
        {
            membersString = [[NSString alloc] initWithFormat:@"%d MEMBERS",  numberOfUnwatchedVideos];
        }

        [numberOfMembersLabel setText:membersString];
        
    } andForced:forced];
}

- (void) finishedLoadingMembersCountWithSuccess:(BOOL)successful andError:(NSError *)error
{
    [self setNumberOfMembersLabelForced:NO];
}

- (void) finishedLoadingVideosWithSuccess:(BOOL)successful andError:(NSError *)error
{
    [self setNumberOfVideosLabelForced:NO];
}

- (void) finishedLoadingNumberOfNewVideos:(int) numberOfNewVideos
{   
    if (numberOfNewVideos == 0)
    {
        [unwatchedVideosBadge setHidden:YES];
        [[self numberOfUnwatchedVideosLabel] setText:[[NSString alloc] init]];
    }
    else
    {
        [unwatchedVideosBadge setHidden:NO];
        [[self numberOfUnwatchedVideosLabel] setText:[[NSString alloc] initWithFormat:@"%d", numberOfNewVideos]];
    }
}

@end
