//
//  TPAAppEventMessage.h
//  ThePerfectApp
//
//  Created by Julian Król on 16/10/15.
//  Copyright © 2015 Trifork GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

DEPRECATED_MSG_ATTRIBUTE("Use TPAManager for tracking of all events")
@interface TPAAppEventMessage : NSObject

@property (copy, nonatomic, readonly, nullable) NSString * category;
@property (copy, nonatomic, readonly, nullable) NSString * name;
@property (copy, nonatomic, readonly, nullable) NSDictionary * metaInfo;


/**
 * Creates TPAAppEventMessage according to the passed attributes
 *
 * @param checkpointName name of the check point, can not be 0 length string
 * @param metaInfo optional dictionary of NSData and NSStrings used to send extra information
 *
 * @return instance of TPAAppEventMessage, can return nil
 */
+ (nullable TPAAppEventMessage *)createCheckpointReachedMessage:(nonnull NSString *)checkpointName
                                                       metaInfo:(nullable NSDictionary *)metaInfo DEPRECATED_MSG_ATTRIBUTE("Use trackEventWithCategory:name: or trackEventWithCategory:name:tags: in TPAManager instead");

/**
 * Creates TPAAppEventMessage according to the passed attributes
 *
 * @param actionName required name of the action, can not be 0 length string
 * @param categoryName required name of the action's category, can not be 0 length string
 * @param metaInfo optional dictionary of NSData and NSStrings used to send extra information
 *
 * @return instance of TPAAppEventMessage, can return nil
 */
+ (nullable TPAAppEventMessage *)createActionMessage:(nonnull NSString *)actionName
                                            category:(nonnull NSString *)categoryName
                                            metaInfo:(nullable NSDictionary *)metaInfo DEPRECATED_MSG_ATTRIBUTE("Use trackEventWithCategory:name: or trackEventWithCategory:name:tags: in TPAManager instead");

/**
 * Creates TPAAppEventMessage according to the passed attributes
 *
 * @param screenTitle title of the screen that is appearing, can not be 0 length string
 * @param metaInformation optional additional information to the screen appearing (can be NSString or NSData)
 *
 * @return instance of TPAAppEventMessage, can return nil
 */
+ (nullable TPAAppEventMessage *)createScreenDidAppearMessageForScreen:(nonnull NSString *)screenTitle
                                                              metaInfo:(nullable NSDictionary *)metaInformation DEPRECATED_MSG_ATTRIBUTE("Use trackScreenAppearing: or trackScreenAppearing:tags: in TPAManager instead");

/**
 * Creates TPAAppEventMessage according to the passed attributes
 *
 * @param screenTitle title of the screen that is disappearing, can not be 0 length string
 * @param metaInformation optional additional information to the screen disappearing (can be NSString or NSData)
 *
 * @return instance of TPAAppEventMessage, can return nil
 */
+ (nullable TPAAppEventMessage *)createScreenDidDisappearMessageForScreen:(nonnull NSString *)screenTitle
                                                                 metaInfo:(nullable NSDictionary *)metaInformation DEPRECATED_MSG_ATTRIBUTE("Use trackScreenDisappearing: or trackScreenDisappearing:tags: in TPAManager instead");

@end
