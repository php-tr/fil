//
//  MasterViewController.m
//  Fil
//
//  Created by Firat Agdas on 9/11/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import "MasterViewController.h"
#import "ReaderViewController.h"

@interface MasterViewController() <ReaderViewControllerDelegate>
{
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        if (UI_IDIOM_PAD)
        {
            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMagazineList:) name:NOTIFICATION_MAGAZINE_LIST_SYNCED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadComplete:) name:NOTIFICATION_MAGAZINE_DOWNLOAD_COMPLETE object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.font = [UIFont fontWithName:@"Highway" size:30];
    
    self.tableView.rowHeight = 84.f;
    // self.tableView.frame = CGRectMake(0.f, 20.f, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(10.f, 0.f, 0.f, 0.f);
    
    [self initRefreshButton];
    [self initBackgroundView];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Banner.png"] forBarMetrics:UIBarMetricsDefault];
    NSLog(@"View did loaded.");
}

- (void)initRefreshButton
{
    UIImage *refreshButtonBackground = [UIImage imageNamed:@"Refresh.png"];
    UIView *buttonContainer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, refreshButtonBackground.size.width, refreshButtonBackground.size.height + 5.f)];
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setFrame:CGRectMake(0.f, 5.f, refreshButtonBackground.size.width, refreshButtonBackground.size.height)];
    [refreshButton setImage:refreshButtonBackground forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshList:) forControlEvents:UIControlEventTouchUpInside];
    [buttonContainer addSubview:refreshButton];
    
    UIBarButtonItem *navRefreshButton = [[UIBarButtonItem alloc] initWithCustomView:buttonContainer];
    self.navigationItem.rightBarButtonItem = navRefreshButton;
}

- (void)initBackgroundView
{
    UIImage *backgroundImage = [UIImage imageNamed:@"TransBK.png"];
    
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, (CGRect){{0, 0}, backgroundImage.size});
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, backgroundImage.size.height);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, (CGRect){{0, 0}, backgroundImage.size}, [backgroundImage CGImage]);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.tableView setBackgroundColor: [UIColor colorWithPatternImage:image]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refreshList:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_REFRESH object:nil userInfo:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSInteger cellIdentifierSuffix = -1;
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell_%d", ++cellIdentifierSuffix];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagazineData *data = (MagazineData *)[_objects objectAtIndex:0];
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 5.f, cell.frame.size.width, cell.frame.size.height - 5.f)];
    customView.backgroundColor = UICOLOR_FROM_HEX(0x5398cf);
    customView.layer.masksToBounds = NO;
    
    NSURL *url = [NSURL URLWithString:data.imageUrl];
    UIImage *thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]]; // [UIImage imageNamed:@"Thumbnail.png"];
    [thumbnail stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:thumbnail];
    [imageView setFrame:CGRectMake(10.f, 5.f, thumbnail.size.width * 0.3f, thumbnail.size.height * 0.3f)];
    [customView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70.f, 25.f, 170.f, 30.f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:data.name];
    [label setFont:[UIFont fontWithName:@"TR Blue Highway" size:25]];
    [customView addSubview:label];

    [cell.contentView addSubview:customView];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagazineData *magazineData = (MagazineData *) _objects[indexPath.row];
    FIL_LOG(@"Release Id %d.", magazineData.releaseId);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (!magazineData.isPdfDownloaded)
    {
        NSDictionary *dict = @{@"magazineId": [NSNumber numberWithInt:magazineData.id]};
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_DOWNLOAD object:nil userInfo:dict];
    }
    else
    {
        [self openPdf:magazineData];
    }
    
    /*if (UI_IDIOM_PHONE)
    {
	    if (!self.detailViewController)
        {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    }
	    self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else
    {
        self.detailViewController.detailItem = object;
    }*/
}

- (void) handleMagazineList: (NSNotification *) notification
{
    NSDictionary *magazineList = notification.userInfo;
    if (!_objects)
    {
        _objects = [[NSMutableArray alloc] init];
    }
    
    [self.tableView beginUpdates];
    
    NSMutableArray *paths = [NSMutableArray array];
    NSUInteger start = [_objects count], i, len = [magazineList count];
    
    for (i = start; i < start + len; i++)
    {
        [_objects addObject:[magazineList objectForKey:[NSString stringWithFormat:@"%d", i - start]]];
        [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
}

- (void) handleDownloadComplete: (NSNotification *) notification
{
    [self openPdf:[notification.userInfo objectForKey:@"data"]];
}

- (void) openPdf: (MagazineData *) data
{
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:[[Util getDocumentPath] stringByAppendingPathComponent:data.pdfName] password:nil];
    ReaderViewController *viewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    viewController.delegate = self;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
