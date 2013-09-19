//
//  Util.h
//  Fil
//
//  Created by Firat Agdas on 9/14/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"
#import "FMDatabase.h"

#define UI_IDIOM_PAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define UI_IDIOM_PHONE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

#define UICOLOR_FROM_HEX_WITH_ALPHA(x, y) [UIColor colorWithRed:(((x)&0xFF0000)>>16)/255.0f green:(((x)&0xFF00)>>8)/255.0f blue:((x)&0xFF)/255.0f alpha:(y)]
#define UICOLOR_FROM_HEX(x) UICOLOR_FROM_HEX_WITH_ALPHA(x, 1.f)

#ifdef DEBUG
#define FIL_LOG(x, ...) NSLog(x, ##__VA_ARGS__)
#else
#define FIL_LOG(...)
#endif

@interface Util : NSObject

+ (NSString *) getDbPath;
+ (NSString *) getDocumentPath;

@end