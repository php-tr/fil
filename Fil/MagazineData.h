//
//  MagazinData.h
//  Fil
//
//  Created by Firat Agdas on 9/14/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MagazineData : NSObject

@property (strong) NSString *name;
@property (assign) NSInteger id;
@property (strong) NSString *imageUrl;
@property (strong) NSString *pdfUrl;
@property (assign) NSInteger releaseId;
@property (strong) NSDate *releaseDate;
@property (assign) BOOL isDownloaded;

@end
