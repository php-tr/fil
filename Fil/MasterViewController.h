//
//  MasterViewController.h
//  Fil
//
//  Created by Firat Agdas on 9/11/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "DetailViewController.h"
#import "Util.h"
#import "MagazineData.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UIBarButtonItem *refreshButton;
@property (strong, nonatomic) UIFont *font;

@end
