#include "Analytics.h"
#include <UIKit/UIKit.h>
#include "GAI.h"
#include "GAIDictionaryBuilder.h"
#include "GAIFields.h"
#include "ApplicationInfo.h"

#define _NS_STRING(x) [NSString stringWithUTF8String:(x).toUtf8().data()]
#define _NS_NUMBER(x) [NSNumber numberWithInt:x]

Analytics *Analytics::_instance = 0;

Analytics::Analytics(QObject *parent) :
    QObject(parent)
{
    _instance = this;

    [[GAI sharedInstance] trackerWithTrackingId:_NS_STRING(((ApplicationInfo *) this->parent())->config()->trackerId)];
    // [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
}

void Analytics::sendViewEvent(QString screenName)
{
    if (screenName.isEmpty())
    {
        return;
    }

    qWarning() << "Event Loading: " << screenName;
    [[[GAI sharedInstance] defaultTracker] send:[[[GAIDictionaryBuilder createAppView] set:_NS_STRING(screenName) forKey:kGAIScreenName] build]];
}

void Analytics::sendEvent(QString eventName, QString action, QString label, int value)
{
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:_NS_STRING(eventName)
                                                  action:_NS_STRING(action)
                                                   label:_NS_STRING(label)
                                                   value:_NS_NUMBER(value)] build]];
}
