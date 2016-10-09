//
//  PostVideoForumViewController.h
//  iOS
//
//  Created by Desmond McNamee on 12-04-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerApi.h"
#import "FeedTableViewController.h"

@interface PostVideoForumViewController : UIViewController
@property (strong, nonatomic) NSString* moviePath; 
@property (strong, nonatomic) IBOutlet UITextField *tagsField;
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property int orientation;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)postVideo:(id)sender;

@end
