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
        
        _magazineList = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *list = [NSMutableDictionary dictionary];
        
        FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
        
        [db open];
        
        NSUInteger i = 0;
        FMResultSet *results = [db executeQuery:@"SELECT * FROM magazine"];
        while ([results next])
        {
            MagazineData *data = [[MagazineData alloc] init];
            data.id = [results intForColumn:@"magazine_id"];
            data.name = [results stringForColumn:@"name"];
            data.imageUrl = [results stringForColumn:@"image_url"];
            data.pdfUrl = [results stringForColumn:@"pdf_url"];
            data.pdfName = [results stringForColumn:@"pdf_name"];
            data.releaseId = [results intForColumn:@"release_id"];
            data.releaseDate = [NSDate dateWithTimeIntervalSince1970:[results unsignedLongLongIntForColumn:@"release_date"]];
            data.isPdfDownloaded = [results intForColumn:@"is_pdf_downloaded"] ? YES : NO;
            data.isImageDownloaded = [results intForColumn:@"is_image_downloaded"] ? YES : NO;
            data.size = [results longLongIntForColumn:@"size"];
            data.downloadDateline = [results longLongIntForColumn:@"download_dateline"] == 0 ? 0 : [[NSDate alloc] initWithTimeIntervalSince1970:[results longLongIntForColumn:@"download_dateline"]];
            data.syncDateline = [[NSDate alloc] initWithTimeIntervalSince1970:[results longLongIntForColumn:@"sync_dateline"]];
            
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
        NSUInteger i, listCount = 0, len = [response count];
        NSMutableDictionary *list = [[NSMutableDictionary alloc] init];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
        [db open];
        
        for (i = 0; i < len; i++)
        {
            NSDictionary *responseData = [response objectAtIndex:i];
            
            NSInteger releaseId = (NSInteger) [[responseData objectForKey:@"sayi"] intValue];
            FIL_LOG(@"Release Id is: %d", releaseId);
            if ([_magazineList objectForKey:[NSString stringWithFormat:@"%d", releaseId]] != nil)
            {
                FIL_LOG(@"Data skipped. %d", releaseId);
                continue;
            }

            MagazineData *magazineData = [[MagazineData alloc] init];
            magazineData.name = [responseData objectForKey:@"ad"];
            magazineData.imageUrl = [responseData objectForKey:@"image"];
            magazineData.pdfUrl = [responseData objectForKey:@"pdf"];
            magazineData.pdfName = [NSString stringWithFormat:@"%d.pdf", releaseId];
            magazineData.releaseId = releaseId;
            magazineData.isPdfDownloaded = NO;
            magazineData.isImageDownloaded = NO;
            magazineData.downloadDateline = nil;
            magazineData.syncDateline = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            magazineData.releaseDate = [formatter dateFromString:[responseData objectForKey:@"tarih"]];
            
            db.traceExecution = YES;
            [db executeUpdate:@"INSERT INTO magazine (name, image_url, pdf_url, pdf_name, release_id, release_date, size, download_dateline, sync_dateline) VALUES (?, ?, ?, ?, ?, ?)",
             magazineData.name,
             magazineData.imageUrl,
             magazineData.pdfUrl,
             magazineData.pdfName,
             [NSNumber numberWithInt:magazineData.releaseId],
             [NSNumber numberWithLongLong:[magazineData.releaseDate timeIntervalSince1970]],
             [NSNumber numberWithLongLong:magazineData.size],
             [NSNumber numberWithLongLong:magazineData.downloadDateline ? [magazineData.downloadDateline timeIntervalSince1970] : 0],
             [magazineData.syncDateline timeIntervalSince1970]
            ];
            magazineData.id = [db lastInsertRowId];
            
            [_magazineList setObject:magazineData forKey:[NSString stringWithFormat:@"%d", magazineData.releaseId]];
            [list setObject:magazineData forKey:[NSString stringWithFormat:@"%d", listCount++]];
        }

        [db close];
        
        if (listCount > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_LIST_SYNCED object:nil userInfo:list];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
        NSString *pdfPath = [NSString stringWithFormat:@"%@/%d.pdf", [Util getDocumentPath], data.releaseId];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:pdfPath])
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_DOWNLOAD_COMPLETE object:nil userInfo:@{@"data": data}];
            return;
            
            NSError *error;
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
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            data.isPdfDownloaded = YES;
            data.downloadDateline = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            
            FMDatabase *db = [FMDatabase databaseWithPath:[Util getDbPath]];
            [db open];
            [db executeUpdate:@"UPDATE magazine SET download_dateline = ?, is_pdf_downloaded = ? WHERE magazine_id = ?", [NSNumber numberWithLongLong:[data.downloadDateline timeIntervalSince1970]], [NSNumber numberWithInt:1], [NSNumber numberWithInt:data.id]];
            [db close];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAGAZINE_DOWNLOAD_COMPLETE object:nil userInfo:@{@"data": data}];
            
            db = nil;
            
            FIL_LOG(@"Successfull download.");
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            FIL_LOG(@"Failed download.");
        }];
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
        {
            FIL_LOG(@"%u/%llu/%llu", bytesRead, totalBytesRead, totalBytesExpectedToRead);
        }];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:pdfPath append:NO];
        [operation start];
    }
}

@end
