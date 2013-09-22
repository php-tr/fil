//
//  FilMagazine.h
//  Fil
//
//  Created by Firat Agdas on 9/14/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "AFNetworking.h"
#import "CJSONDeserializer.h"
#import "Util.h"
#import "MagazineData.h"

@interface FilMagazine : NSObject
{
    NSDictionary *magazineList;
    NSUInteger magazineCount;
}

@property (nonatomic, readonly, strong) NSMutableDictionary *magazineList;
@property (readonly) NSUInteger magazineCount;
@property (assign) BOOL isRefreshInProgress;

+ (FilMagazine *) sharedInstance;

- (void) acquireRemoteData;
- (void) syncDatabase: (NSArray *) data;

@end
