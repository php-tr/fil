//
//  Constant.h
//  Fil
//
//  Created by Firat Agdas on 9/14/13.
//  Copyright (c) 2013 Firat Agdas. All rights reserved.
//

#ifndef Fil_Constant_h
#define Fil_Constant_h

#define DATABASE_FILE @"Fil.db"
// #define CHECK_URL @"http://fil.php-tr.com/mobile.php?type=pdf_list&token=iyeO0/tpdSKkpelwO1l1Jd01t2Qvr4nMek3TC43xEYw="
#define CHECK_URL @"http://localhost/l.php"

#define DATABASE_SCHEMA_MAGAZINE @"CREATE TABLE IF NOT EXISTS magazine (magazine_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, name TEXT NOT NULL, image_url TEXT NOT NULL, image_name TEXT NOT NULL, pdf_url TEXT NOT NULL, pdf_name TEXT NOT NULL, release_id INTEGER DEFAULT '0', release_date UNSIGNED INTEGER DEFAULT '0', is_pdf_downloaded INTEGER DEFAULT '0', is_image_downloaded INTEGER DEFAULT '0',download_dateline UNSIGNED INTEGER DEFAULT '0', sync_dateline UNSIGNED INTEGER DEFAULT '0', size UNSIGNED BIG INT);"

#define DATABASE_SCHEMAS @[DATABASE_SCHEMA_MAGAZINE]

#define NOTIFICATION_MAGAZINE_LIST_SYNCED @"notificationMagazineListSynced"
#define NOTIFICATION_MAGAZINE_REFRESH @"notificationMangazineRefresh"
#define NOTIFICATION_MAGAZINE_DOWNLOAD @"notificationMagazineDownload"
#define NOTIFICATION_MAGAZINE_DOWNLOAD_COMPLETE @"notificationMagazineDownloadComplete"
#define NOTIFICATION_MAGAZINE_DOWNLOAD_FAILED @"notificationMagazineDownloadFailed"
#define NOTIFICATION_MAGAZINE_DOWNLOAD_PROGRESS @"notificationMagazineDownloadProgress"
#define NOTIFICAITON_MAGAZINE_IMAGE_DONWLOAD_COMPLETE @"notificationMagazineImageDownloadComplete"

#define FONT_NAME @"TR Blue Highway"

#endif
