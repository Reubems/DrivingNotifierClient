//
//  TPAAnalitics.h
//  ThePerfectApp
//
//  Created by Julian Król on 02/10/15.
//  Copyright © 2015 Trifork GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TPAAppEventMessage.h"

#import <AvailabilityMacros.h>

DEPRECATED_MSG_ATTRIBUTE("Use TPAManager for tracking of all events")
@interface TPAAnalytics : NSObject

/**
 * Method used to get TPAAnalytics singleton
 *
 * @return singleton instance of Analytics
 */
+ (instancetype)sharedInstance;

/**
 * Method sending app event message to the server
 *
 * @param appEventMessage message that will be sent
 */
- (void)send:(TPAAppEventMessage *)appEventMessage;


@end
