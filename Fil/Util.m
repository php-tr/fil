//
//  Util.m
//  Fil
//
//  Created by Firat Agdas on 9/14/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *) getDbPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    
    NSString *databasePath = [documentDir stringByAppendingPathComponent:DATABASE_FILE];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:databasePath])
    {
        NSError *error = nil;
        [fm copyItemAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_FILE] toPath:databasePath error:&error];
        
        if (error)
        {
            FIL_LOG(@"Database could not copy: %@", error);
        }
    }
    
    return databasePath;
}

@end