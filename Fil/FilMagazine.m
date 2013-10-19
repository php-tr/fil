//
//  FilMagazine.m
//  Fil
//
//  Created by Firat Agdas on 9/14/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import "FilMagazine.h"
#import <CoreFoundation/CFDictionary.h>

@implementation FilMagazine

@synthesize magazineList = _magazineList;
@synthesize magazineCount = _magazineCount;
@synthesize isRefreshInProgress = _isRefreshInProgress;

+ (FilMagazine *) sharedInstance
{
    static FilMagazine *instance;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FilMagazine alloc] init];
    });
    
    return instance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshRequest:) name:NOTIFICATION_MAGAZINE_REFRESH object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadRequest:) name:NOTIFICATION_MAGAZINE_DOWNLOAD object:nil];
        
        _isRefreshInProgress = NO;
        _magazineList = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *list = [NSMutableDictionary dictionary];
        
        FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
        
        [db open];
        
        NSUInteger i = 0;
        FMResultSet *results = [db executeQuery:@"SELECT * FROM magazine ORDER BY release_id DESC"];
        while ([results next])
        {
            MagazineData *data = [[MagazineData alloc] init];
            data.id = [results intForColumn:@"magazine_id"];
            data.name = [results stringForColumn:@"name"];
            data.imageUrl = [results stringForColumn:@"image_url"];
            data.imageName = [results stringForColumn:@"image_name"];
            data.pdfUrl = [results stringForColumn:@"pdf_url"];
            data.pdfName = [results stringForColumn:@"pdf_name"];
            data.releaseId = [results intForColumn:@"release_id"];
            data.releaseDate = [NSDate dateWithTimeIntervalSince1970:[results unsignedLongLongIntForColumn:@"release_date"]];
            data.isPdfDownloaded = [results intForColumn:@"is_pdf_downloaded"] ? YES : NO;
            data.isImageDownloaded = [results intForColumn:@"is_image_downloaded"] ? YES : NO;
            data.size = [results longLongIntForColumn:@"size"];
            data.downloadDateline = [results longLongIntForColumn:@"download_dateline"] == 0 ? 0 : [[NSDate alloc] initWithTimeIntervalSince1970:[results longLongIntForColumn:@"download_dateline"]];
            data.syncDateline = [[NSDate alloc] initWithTimeIntervalSince1970:[results longLongIntForColumn:@"sync_dateline"]];
            data.isPdfDownloadActive = NO;
            data.isViewInited = NO;
            data.downloadProgressPercent = 0;
            
            [_magazineList setObject:data forKey:[NSString stringWithFormat:@"%d", data.releaseId]];
            [list setObject:data forKey:[NSString stringWithFormat:@"%d", i++]];
            
            _magazineCount++;
        }
        
        [db close];
        
        FIL_LOG(@"Loaded Magazine Data: %@", self.magazineList);
        if (_magazineCount > 0)
        {
           [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_LIST_SYNCED object:nil userInfo:list];
        }
    }
    
    return self;
}


- (void) acquireRemoteData
{
    if (_isRefreshInProgress)
    {
        FIL_LOG(@"Refresh is in progress.");
        return;
    }
    _isRefreshInProgress = YES;
    
    NSURL *url = [NSURL URLWithString:CHECK_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    /*AFJSONRequestOperation *process = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", JSON);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];*/
    
    AFHTTPRequestOperation *process = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [process setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        FIL_LOG(@"Data retrieved successfully: %@", [operation responseString]);
        NSData *data = [[operation responseString] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:&error];
        if (error)
        {
            FIL_LOG(@"JSON Parse Error: %@", error);
            return;
        }
        
        FIL_LOG(@"Parsed Data: %@", dictionary);
        if (![dictionary objectForKey:@"success"])
        {
            FIL_LOG(@"Data retrieved with no success: %@", [dictionary objectForKey:@"message"]);
            return;
        }
        
        NSArray *response = [dictionary objectForKey:@"response"];
        NSInteger i, listCount = 0, len = [response count];
        NSMutableDictionary *list = [[NSMutableDictionary alloc] init];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
        db.traceExecution = YES;
        [db open];
        
        dispatch_queue_t imageLoadQueue = dispatch_queue_create("imageLoadQueue", DISPATCH_QUEUE_SERIAL);
        
        for (i = len - 1; i >= 0; i--)
        {
            NSDictionary *responseData = [response objectAtIndex:i];
            
            NSInteger releaseId = (NSInteger) [[responseData objectForKey:@"sayi"] intValue];
            if ([_magazineList objectForKey:[NSString stringWithFormat:@"%d", releaseId]] != nil)
            {
                continue;
            }

            __block MagazineData *magazineData = [[MagazineData alloc] init];
            magazineData.name = [responseData objectForKey:@"ad"];
            magazineData.imageUrl = [responseData objectForKey:@"image"];
            magazineData.imageName = [NSString stringWithFormat:@"%d.png", releaseId];
            magazineData.pdfUrl = [responseData objectForKey:@"pdf"];
            magazineData.pdfName = [NSString stringWithFormat:@"%d.pdf", releaseId];
            magazineData.releaseId = releaseId;
            magazineData.isPdfDownloaded = NO;
            magazineData.isImageDownloaded = NO;
            magazineData.downloadDateline = nil;
            magazineData.size = [[responseData objectForKey:@"boyut"] longLongValue];
            magazineData.syncDateline = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            magazineData.isPdfDownloadActive = NO;
            magazineData.downloadProgressPercent = 0;
            
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            magazineData.releaseDate = [formatter dateFromString:[responseData objectForKey:@"tarih"]];
            
            [db executeUpdate:@"\
                INSERT INTO magazine \
                    (name, image_url, image_name, is_image_downloaded, pdf_url, pdf_name, is_pdf_downloaded, release_id, release_date, size, download_dateline, sync_dateline) \
                VALUES \
                    (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                magazineData.name,
                magazineData.imageUrl,
                magazineData.imageName,
                [NSNumber numberWithInt:magazineData.isImageDownloaded ? 1 : 0],
                magazineData.pdfUrl,
                magazineData.pdfName,
                [NSNumber numberWithInt:magazineData.isPdfDownloaded ? 1 : 0],
                [NSNumber numberWithInt:magazineData.releaseId],
                [NSNumber numberWithLongLong:[magazineData.releaseDate timeIntervalSince1970]],
                [NSNumber numberWithLongLong:magazineData.size],
                [NSNumber numberWithLongLong:magazineData.downloadDateline ? [magazineData.downloadDateline timeIntervalSince1970] : 0],
                [NSNumber numberWithLongLong:magazineData.syncDateline ? [magazineData.syncDateline timeIntervalSince1970] : 0]
            ];
            NSError *error = [db lastError];
            if (error.code)
            {
                FIL_LOG(@"There is an error: %@", error);
                continue;
            }
            
            magazineData.id = [db lastInsertRowId];
            
            [_magazineList setObject:magazineData forKey:[NSString stringWithFormat:@"%d", magazineData.releaseId]];
            [list setObject:magazineData forKey:[NSString stringWithFormat:@"%d", listCount++]];
            
            dispatch_async(imageLoadQueue, ^{
                NSURL *url = [NSURL URLWithString:magazineData.imageUrl];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                NSString *imagePath = [[Util getDocumentPath] stringByAppendingPathComponent:magazineData.imageName];
                operation.outputStream = [NSOutputStream outputStreamToFileAtPath:imagePath append:NO];
                [operation
                    setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                    {
                        FIL_LOG(@"Image Downloaded: %@, %d", magazineData.imageUrl, magazineData.id);
                        
                        magazineData.isImageDownloaded = YES;
                        
                        FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
                        db.traceExecution = YES;
                        [db open];
                        [db
                            executeUpdate:@"UPDATE magazine SET is_image_downloaded = ? WHERE magazine_id = ?",
                            [NSNumber numberWithInt:magazineData.isImageDownloaded ? 1 : 0],
                            [NSNumber numberWithInt:magazineData.id]
                        ];
                        [db close];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICAITON_MAGAZINE_IMAGE_DONWLOAD_COMPLETE object:nil userInfo:@{@"magazineData": magazineData}];
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        FIL_LOG(@"Image Download Failed: %@", magazineData.imageUrl);
                    }
                 ];
                [operation start];
            });
        }
        [db close];
        
        if (listCount > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_LIST_NEW object:nil userInfo:list];
        }

        _isRefreshInProgress = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _isRefreshInProgress = NO;
    }];
    
    [process start];
}

- (MagazineData *) getDataById: (int) magazineId
{
    NSString *i;
    MagazineData *data = nil;
    for (i in _magazineList)
    {
        data = (MagazineData *)[_magazineList objectForKey:i];
        if (data.id == magazineId)
        {
            return data;
        }
    }
    
    return nil;
}

- (void) syncDatabase: (NSArray *) data
{

}

- (void) handleRefreshRequest: (NSNotification *) notification
{
    [self acquireRemoteData];
}

- (void) handleDownloadRequest: (NSNotification *) notification
{
    __strong __block MagazineData *data = [self getDataById:[[notification.userInfo objectForKey:@"magazineId"] intValue]];
    if (!data.isPdfDownloaded)
    {
        NSString *pdfPath = [[Util getDocumentPath] stringByAppendingPathComponent:data.pdfName];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:pdfPath])
        {
            NSError *error = nil;
            [fm removeItemAtPath:pdfPath error:&error];
            if (error)
            {
                FIL_LOG(@"File could not delete: %@", error);
                return;
            }
        }
        
        NSURL *url = [NSURL URLWithString:data.pdfUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        __block int lastPercent = 0;
        data.isPdfDownloadActive = YES;
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            data.isPdfDownloadActive = NO;
            data.isPdfDownloaded = YES;
            data.downloadProgressPercent = 0;
            data.downloadDateline = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            
            FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
            [db open];
            [db
                executeUpdate:@"UPDATE magazine SET download_dateline = ?, is_pdf_downloaded = ? WHERE magazine_id = ?",
                [NSNumber numberWithLongLong:[data.downloadDateline timeIntervalSince1970]],
                [NSNumber numberWithInt:1],
                [NSNumber numberWithInt:data.id]
            ];
            [db close];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_DOWNLOAD_COMPLETE object:nil userInfo:@{@"data": data}];
            
            db = nil;
            
            FIL_LOG(@"Successfull download.");
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            data.isPdfDownloadActive = NO;
            data.downloadProgressPercent = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_DOWNLOAD_FAILED object:nil userInfo:@{@"data": data}];
            FIL_LOG(@"Failed download.");
        }];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
        {
            FIL_LOG(@"%u/%llu/%llu", bytesRead, totalBytesRead, totalBytesExpectedToRead);
            int percent = ((float)totalBytesRead) / totalBytesExpectedToRead * 100.f;
            if (lastPercent != percent)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_DOWNLOAD_PROGRESS object:nil userInfo:@{@"percentage": [NSNumber numberWithInt:lastPercent], @"magazineData":data}];
                lastPercent = percent;
                data.downloadProgressPercent = percent;
            }
        }];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:pdfPath append:NO];
        [operation start];
    }
}

@end
