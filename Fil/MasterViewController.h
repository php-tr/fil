//
//  MasterViewController.h
//  Fil
//
//  Created by Firat Agdas on 9/11/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
