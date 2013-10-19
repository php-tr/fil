//
//  MasterViewController.m
//  Fil
//
//  Created by Firat Agdas on 9/11/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import "MasterViewController.h"
#import "ReaderViewController.h"

#define VK_CELL_DATA @"cellData"
#define VK_CELL_CONTAINER @"cellContainer"
#define VK_CELL_IMAGE @"cellImage"
#define VK_CELL_INDICATOR @"cellIndicator"
#define VK_CELL_INDICATOR_TYPE @"cellIndicatorType"

#define INDICATOR_TYPE_DOWNLOAD @"download"
#define INDICATOR_TYPE_VIEW @"view"
#define INDICATOR_TYPE_PROGRESS @"progress"

#define TAG_VIEW_CONTAINER 100000
#define TAG_IMAGE 1000000
#define TAG_INDICATOR 10000000

@interface MasterViewController() <ReaderViewControllerDelegate>
{
    NSMutableArray *_magazineDataList;
    NSMutableDictionary *_viewList;
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
        
        _magazineDataList = [[NSMutableArray alloc] init];
        _viewList = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMagazineList:) name:NOTIFICATION_MAGAZINE_LIST_SYNCED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMagazineNew:) name:NOTIFICATION_MAGAZINE_LIST_NEW object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadComplete:) name:NOTIFICATION_MAGAZINE_DOWNLOAD_COMPLETE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImageDownloadComplete:) name:NOTIFICAITON_MAGAZINE_IMAGE_DONWLOAD_COMPLETE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadProgress:) name:NOTIFICATION_MAGAZINE_DOWNLOAD_PROGRESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadFailed:) name:NOTIFICATION_MAGAZINE_DOWNLOAD_FAILED object:nil];
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
    return _magazineDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MagazineData *data = (MagazineData *)[_magazineDataList objectAtIndex:indexPath.row];
    
    UIView *viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 5.f, cell.frame.size.width, cell.frame.size.height - 5.f)];
    [viewContainer setTag:TAG_VIEW_CONTAINER + data.releaseId];
    viewContainer.backgroundColor = UICOLOR_FROM_HEX(0x5398cf);
    viewContainer.layer.masksToBounds = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70.f, 25.f, 170.f, 30.f)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:data.name];
    [label setFont:[UIFont fontWithName:FONT_NAME size:25]];
    [viewContainer addSubview:label];
    
    NSMutableDictionary *viewDict = [[NSMutableDictionary alloc] initWithDictionary: @{
        VK_CELL_DATA: data,
        VK_CELL_CONTAINER: [NSNumber numberWithInt:TAG_VIEW_CONTAINER + data.releaseId],
        VK_CELL_IMAGE: [NSNull null],
        VK_CELL_INDICATOR: [NSNull null],
        VK_CELL_INDICATOR_TYPE: [NSNull null]
    }];
    FIL_LOG(@"View Dict: %@", viewDict);
    [_viewList setObject:viewDict forKey:[NSString stringWithFormat:@"%d", indexPath.row]];
    [cell.contentView addSubview:viewContainer];
    
    [self setIndicatorType:(data.isPdfDownloaded ? INDICATOR_TYPE_VIEW : (data.isPdfDownloadActive ? INDICATOR_TYPE_PROGRESS : INDICATOR_TYPE_DOWNLOAD)) to:viewDict];
    [self setImage:data to:viewDict];
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
    MagazineData *magazineData = (MagazineData *) _magazineDataList[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (magazineData.isPdfDownloadActive)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Downloading", nil) message:NSLocalizedString(@"Pdf is downloading. You cannot open it for the moment", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
    }
    else if (!magazineData.isPdfDownloaded)
    {
        NSMutableDictionary *viewDict = [_viewList objectForKey:[NSString stringWithFormat:@"%d", indexPath.row]];
        [self setIndicatorType:INDICATOR_TYPE_PROGRESS to:viewDict];
        [self setProgress:0 to:viewDict];
        
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
    
    FIL_LOG(@"Magazine List Updating. %d/%d", [magazineList count], [_magazineDataList count]);
    
    [self.tableView beginUpdates];
    
    NSMutableArray *paths = [NSMutableArray array];
    NSUInteger start = [_magazineDataList count], i, len = [magazineList count];
    
    for (i = start; i < start + len; i++)
    {
        FIL_LOG(@"Magazine data adding: %d", i - start);
        [_magazineDataList addObject:[magazineList objectForKey:[NSString stringWithFormat:@"%d", i - start]]];
        [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    FIL_LOG(@"Paths: %@", paths);
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
}

- (void) handleMagazineNew: (NSNotification *) notification
{
    NSDictionary *magazineList = notification.userInfo;
    
    FIL_LOG(@"Adding New magazines. %d", [magazineList count]);
    NSUInteger i, len = [magazineList count];
    NSMutableArray *newDataList = [NSMutableArray array];
    NSMutableArray *paths = [NSMutableArray array];
    NSMutableDictionary *newViewList = [NSMutableDictionary dictionary];
    
    for (i = 0; i < len; i++)
    {
        [newDataList addObject:[magazineList objectForKey:[NSString stringWithFormat:@"%d", i]]];
        [paths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    
    len = [_magazineDataList count];
    for (i = 0; i < len; i++)
    {
        [newDataList addObject:[_magazineDataList objectAtIndex:i]];
    }
    
    _magazineDataList = newDataList;
    
    NSString *key;
    len = [magazineList count];
    for (key in _viewList)
    {
        [newViewList setObject:[_viewList objectForKey:key] forKey:[NSString stringWithFormat:@"%d", [key intValue] + len]];
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void) handleDownloadComplete: (NSNotification *) notification
{
    MagazineData *data = [notification.userInfo objectForKey:@"data"];
    NSUInteger i, len = [_magazineDataList count];
    for (i = 0; i < len; i++)
    {
        NSMutableDictionary *cellData = [_viewList objectForKey:[NSString stringWithFormat:@"%d", i]];
        if (!cellData)
        {
            continue;
        }
        
        if (((MagazineData *)[_magazineDataList objectAtIndex:i]).id == data.id)
        {
            [self setIndicatorType:INDICATOR_TYPE_VIEW to:cellData];
            break;
        }
    }

    [self openPdf:data];
}

- (void) handleDownloadFailed: (NSNotification *) notification
{
    MagazineData *data = [notification.userInfo objectForKey:@"data"];
    NSUInteger i, len = [_magazineDataList count];
    for (i = 0; i < len; i++)
    {
        NSMutableDictionary *cellData = [_viewList objectForKey:[NSString stringWithFormat:@"%d", i]];
        if (!cellData)
        {
            continue;
        }
        
        if (((MagazineData *)[_magazineDataList objectAtIndex:i]).id == data.id)
        {
            [self setIndicatorType:INDICATOR_TYPE_DOWNLOAD to:cellData];
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Pdf download failed", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil] show];
            break;
        }
    }
}

- (void) handleImageDownloadComplete: (NSNotification *) notification
{
    MagazineData *data = [notification.userInfo objectForKey:@"magazineData"];
    NSUInteger i, len = [_magazineDataList count], viewLen = [_viewList count];
    for (i = 0; i < len; i++)
    {
        if (i >= viewLen - 1)
        {
            continue;
        }
        
        NSMutableDictionary *cellData = [_viewList objectForKey:[NSString stringWithFormat:@"%d", i]];
        if (((MagazineData *)[_magazineDataList objectAtIndex:i]).id == data.id)
        {
            [self setImage:data to:cellData];
            break;
        }
    }
}

- (void) handleDownloadProgress: (NSNotification *) notification
{
    MagazineData *data = [notification.userInfo objectForKey:@"magazineData"];
    NSUInteger i, len = [_magazineDataList count];
    for (i = 0; i < len; i++)
    {
        NSMutableDictionary *cellData = [_viewList objectForKey:[NSString stringWithFormat:@"%d", i]];
        if (!cellData)
        {
            continue;
        }
        
        if (((MagazineData *)[_magazineDataList objectAtIndex:i]).id == data.id)
        {
            [self setProgress:[[notification.userInfo objectForKey:@"percentage"] intValue] to:cellData];
            break;
        }
    }
}

- (void) openPdf: (MagazineData *) data
{
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:[[Util getDocumentPath] stringByAppendingPathComponent:data.pdfName] password:nil];
    ReaderViewController *viewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    viewController.delegate = self;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) setIndicatorType: (NSString *) type to: (NSMutableDictionary *) dict
{
    id indicatorType = [dict objectForKey:VK_CELL_INDICATOR_TYPE];
    if (![indicatorType isKindOfClass:[NSNull class]] && [(NSString *)indicatorType isEqualToString:type])
    {
        return;
    }
    
    UIView *viewContainer = [self.view viewWithTag:[[dict objectForKey:VK_CELL_CONTAINER] intValue]];
    
    id indicator = [dict objectForKey:VK_CELL_INDICATOR];
    if (![indicator isKindOfClass:[NSNull class]])
    {
        [[self.view viewWithTag:[indicator intValue]] removeFromSuperview];
    }
    
    MagazineData *data = [dict objectForKey:VK_CELL_DATA];
    NSInteger tag = TAG_INDICATOR + data.releaseId;
    
    [dict setObject:type forKey:VK_CELL_INDICATOR_TYPE];
    if ([type isEqualToString:INDICATOR_TYPE_DOWNLOAD])
    {
        UIImage *image = [UIImage imageNamed:@"Download"];
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        [view setFrame:CGRectMake(270.f, 25.f, image.size.width, image.size.height)];
        [view setTag:tag];
        [viewContainer addSubview:view];
        
        [dict setObject:[NSNumber numberWithInt:tag] forKey:VK_CELL_INDICATOR];
    }
    else if ([type isEqualToString:INDICATOR_TYPE_PROGRESS])
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(265.f, 26.f, 50.f, 30.f)];
        [view setBackgroundColor:[UIColor clearColor]];
        [view setTextColor:[UIColor whiteColor]];
        [view setText:[NSString stringWithFormat:@"%d%%", data.downloadProgressPercent]];
        [view setTextAlignment:NSTextAlignmentCenter];
        [view setFont:[UIFont fontWithName:FONT_NAME size:25]];
        [view setTag:tag];
        [viewContainer addSubview:view];
        
        [dict setObject:[NSNumber numberWithInt:tag] forKey:VK_CELL_INDICATOR];
    }
    else if ([type isEqualToString:INDICATOR_TYPE_VIEW])
    {
        UIImage *image = [UIImage imageNamed:@"View"];
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        [view setFrame:CGRectMake(270.f, 25.f, image.size.width, image.size.height)];
        [view setTag:tag];
        [viewContainer addSubview:view];
        
        [dict setObject:[NSNumber numberWithInt:tag] forKey:VK_CELL_INDICATOR];
    }
}

- (void) setProgress: (NSInteger) percent to: (NSMutableDictionary *) dict
{
    UILabel *label = (UILabel *)[self.view viewWithTag:[[dict objectForKey:VK_CELL_INDICATOR] intValue]];
    [label setText:[NSString stringWithFormat:@"%d%%", percent]];
}

- (void) setImage: (MagazineData *) data to: (NSMutableDictionary *) dict
{
    id thumbnail = [dict objectForKey:VK_CELL_IMAGE];
    if (![thumbnail isKindOfClass:[NSNull class]])
    {
        [[self.view viewWithTag:[[dict objectForKey:VK_CELL_IMAGE] intValue]] removeFromSuperview];
    }
    
    UIView *viewContainer = [self.view viewWithTag:[[dict objectForKey:VK_CELL_CONTAINER] intValue]];
    UIImage *image = nil;
    UIImageView *imageView = nil;
    NSInteger tag = TAG_IMAGE + ((MagazineData *)[dict objectForKey:VK_CELL_DATA]).releaseId;
    if (data.isImageDownloaded)
    {
        image = [UIImage imageWithContentsOfFile:[[Util getDocumentPath] stringByAppendingPathComponent:data.imageName]];
        [image stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setTag:tag];
        [imageView setFrame:CGRectMake(10.f, 5.f, image.size.width * 0.3f, image.size.height * 0.3f)];
    }
    else
    {
        image = [UIImage imageNamed:@"Thumbnail"];
        [image stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        imageView = [[UIImageView alloc] initWithImage:image];
        [imageView setTag:tag];
        [imageView setFrame:CGRectMake(10.f, 15.f, image.size.width, image.size.height)];
    }
    
    [viewContainer addSubview:imageView];
    [dict setObject:[NSNumber numberWithInt:tag] forKey:VK_CELL_IMAGE];
}

@end
