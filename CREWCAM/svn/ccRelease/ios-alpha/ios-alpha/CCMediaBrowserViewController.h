//
//  CCMediaBrowserViewController.h
//  Crewcam
//
//  Created by Ryan Brink on 2012-08-27.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Utilities.h"
#import "CCPostVideoForumViewController.h"

@interface CCMediaBrowserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    ALAssetsLibrary *photoLibrary;
}
@property (weak, nonatomic) IBOutlet UITableView *mediaTableView;

@end
