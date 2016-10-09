//
//  CCHelpViewPageController.h
//  Crewcam
//
//  Created by Gregory Flatt on 12-08-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCHelpViewPageController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;

- (id)initWithPageNumber:(int)page;

@end
