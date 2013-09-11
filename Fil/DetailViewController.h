//
//  DetailViewController.h
//  Fil
//
//  Created by Firat Agdas on 9/11/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
