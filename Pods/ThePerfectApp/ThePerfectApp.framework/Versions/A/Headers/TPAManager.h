//
//  TPAManager.h
//  ThePerfectAppLib
//
//  Created by Peder Toftegaard Olsen on 05/06/12.
//  Copyright (c) 2012 Trifork GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef HAS_THE_PERFECT_APP_LIBRARY
#define HAS_THE_PERFECT_APP_LIBRARY 1
#endif


typedef NS_OPTIONS(NSUInteger, TPALoggingDestination)
{
    TPALoggingDestinationNone = 0x00,
    TPALoggingDestinationConsole = 1 << 0,
    TPALoggingDestinationRemote = 1 << 1,
};

typedef NS_ENUM(NSUInteger, TPACrashReporting)
{
    /** Crash reporting is disabled. */
    TPACrashReportingDisabled,
    /** User is asked before sending a crash report. */
    TPACrashReportingAlwaysAsk,
    /** Crash reports will be sent without asking the user. */
    TPACrashReportingAlwaysSend,
};

typedef NS_ENUM(NSUInteger, TPAFeedbackInvocation)
{
    TPAFeedbackInvocationDisabled = 0,
    TPAFeedbackInvocationEnabled = 1 << 0,
    TPAFeedbackInvocationEventShake = TPAFeedbackInvocationEnabled | 1 << 1,
};

/**
 * The TPAManager is responsible for handling update notifications and crash reporting to a TPA server.
 * To enable either a baseURL and projectUuid must be specified.
 */
@interface TPAManager : NSObject

/** Get the one and only TPAManager instance. */
+(TPAManager * _Nonnull)sharedManager;


#pragma mark - TPA server configuration

/**
 * Starts the TPA Manager. No properties of the manager can be modified after calling this method.
 *
 * If a debugger is attached to the app, or the app is executing in the iOS simulator, the
 * TPAManager will not start.
 *
 * @param baseUrl The base URL of the TPA server. Usually of the form https://server/.
 * @param projectUuid Project UUID as it is known to the TPA server.
 */
- (void)startManagerWithBaseUrl:(NSString * _Nonnull)baseUrl projectUuid:(NSString * _Nonnull)projectUuid NS_SWIFT_NAME(start(baseUrl:projectUuid:));


#pragma mark - Update notifications

/** 
 * Enable update notifications by polling the TPAW server when the app becomes active.
 *
 * Cannot be enabled for apps distributed via the App Store.
 * Cannot be enabled for extensions.
 *
 * Disabled by default.
 */
@property (nonatomic, readwrite, getter = isUpdateNotificationsEnabled) BOOL updateNotificationsEnabled;


#pragma mark - Crash reporting

/**
 * Enable crash reporting by uploading crash reports to the TPAW server on next restart of the app after a crash.
 *
 * Only TPACrashReportingDisabled and TPACrashReportingAlwaysSend are valid for extensions.
 *
 * TPACrashReportingDisabled by default.
 */
@property (nonatomic, assign) TPACrashReporting crashReporting;

/**
 * Trap fatal signals via a Mach exception server.
 *
 * Disabled by default.
 */
@property (nonatomic, assign, getter=isMachExceptionHandlerEnabled) BOOL enableMachExceptionHandler;

#pragma mark - Session Recording

/**
 * If enabled, session start/end events will be sent to the TPA server containing basic information about the device.
 *
 * Disabled by default.
 */
@property (nonatomic, getter = isSessionRecordingEnabled) BOOL sessionRecordingEnabled;

/**
 * If enabled, analytics data will be sent to the server
 *
 * Enabled by default
 */
@property (nonatomic, assign, getter=isAnalyticsEnabled) BOOL analyticsEnabled;

#pragma mark - Remote Logging

/**
 * Logging destinations.
 *
 * Value cannot be changed for apps distrbuted via the App Store.
 * Only TPALoggingDestinationNone and TPALoggingDestinationConsole are valid for extensions.
 *
 * Defaults to TPALoggingDestinationConsole, except for apps distributed via the App Store where it is TPALoggingDestinationNone.
 */
@property (nonatomic) TPALoggingDestination loggingDestinations;


#pragma mark - Feedback

/**
 *
 * Disabled by default.
 */
@property (nonatomic, assign) TPAFeedbackInvocation feedbackInvocation;

/**
 * Programmatically invoke the feedback UI.
 */
- (void)invokeFeedback;


#pragma mark - Logging

/**
 * Log message to loggingDestinations.
 */
- (void)logMessage:(NSString *_Nonnull)message;

/**
 * Log message to loggingDestinations.
 */
- (void)log:(NSString *_Nonnull)format, ...;

/**
 * Log message to loggingDestinations.
 */
- (void)log:(NSString *_Nonnull)format args:(va_list _Nonnull)args;


#pragma mark - Timed Events

/**
 * Start a timed event registration.
 *
 * @param category   The category of the event
 * @param name       The name of the timing event
 * @return Event used in trackTimingEvent
 */
- (id _Nonnull)startTimingEventWithCategory:(NSString * _Nonnull)category
                                       name:(NSString * _Nonnull)name
NS_SWIFT_NAME(startTimingEvent(category:name:));


/**
 * Track a previously started timing.
 * The event will be registered as having a time stamp equal to the time at which
 * startTimingEvent was called.
 * Duration is calculated as the time interval between calling startTimingEventWithCategory
 * and calling this method.
 *
 * @param event     Event from startTimingEventWithCategory
 */
- (void)trackTimingEvent:(id _Nonnull)event;

/**
 * Track a previously started timing.
 * The event will be registered as having a time stamp equal to the time at which
 * startTimingEvent was called.
 * Duration is calculated as the time interval between calling startTimingEventWithCategory
 * and calling this method.
 *
 * @param event     Event from startTimingEventWithCategory
 * @param tags      Tags that can be used to filter events on TPA.
 */
- (void)trackTimingEvent:(id _Nonnull)event
                    tags:(NSDictionary * _Nullable)tags
NS_SWIFT_NAME(trackTimingEvent(_:tags:));

/**
 * Track a previously started timing.
 * The event will be registered as having a time stamp equal to the time at which
 * startTimingEvent was called.
 *
 * @param event     Event from startTimingEventWithCategory
 * @param duration  Duration in milliseconds
 */
- (void)trackTimingEvent:(id _Nonnull)event
                duration:(NSUInteger)duration
NS_SWIFT_NAME(trackTimingEvent(_:duration:));

/**
 * Track a previously started timing.
 * The event will be registered as having a time stamp equal to the time at which
 * startTimingEventWithCategory was called.
 *
 * @param event     Event from startTimingEventWithCategory
 * @param duration  Duration in milliseconds
 * @param tags      Tags that can be used to filter events on TPA.
 */
- (void)trackTimingEvent:(id _Nonnull)event
                duration:(NSUInteger)duration
                    tags:(NSDictionary * _Nullable)tags
NS_SWIFT_NAME(trackTimingEvent(_:duration:tags:));


#pragma mark - App Events

/**
 * Tracks an app event with a category. All app events with the same
 * category will be grouped on TPA.
 *
 * @param category  The category of the event
 * @param name     The event name to track
 */
- (void)trackEventWithCategory:(NSString * _Nonnull)category name:(NSString * _Nonnull)name
NS_SWIFT_NAME(trackEvent(category:name:));

/**
 * Tracks an app event with a category and tags. All app events with the same
 * category will be grouped on TPA. Tags can be used to filter events on TPA.
 *
 * @param name      The event name to track
 * @param category  The category of the event
 * @param tags      Tags that can be used to filter events on TPA.
 */
- (void)trackEventWithCategory:(NSString * _Nonnull)category name:(NSString * _Nonnull)name tags:(NSDictionary * _Nullable)tags
NS_SWIFT_NAME(trackEvent(category:name:tags:));

/**
 * Tracks a screen appearing event. It is recommended to track screen
 * appearing events in viewDidAppear.
 *
 * @param screenTitle  The title of the screen that is appearing.
 */
- (void)trackScreenAppearing:(NSString * _Nonnull)screenTitle;

/**
 * Tracks a screen appearing event with tags. It is recommended to track screen
 * appearing events in viewDidAppear. Tags can be used to filter events on TPA.
 *
 * @param screenTitle  The title of the screen that is appearing.
 * @param tags         Tags that can be used to filter events on TPA.
 */
- (void)trackScreenAppearing:(NSString * _Nonnull)screenTitle tags:(NSDictionary * _Nullable)tags;

/**
 * Tracks a screen disappearing event. It is recommended to track screen
 * appearing events in viewDidDisappear.
 *
 * @param screenTitle  The title of the screen that is disappearing.
 */
- (void)trackScreenDisappearing:(NSString * _Nonnull)screenTitle;

/**
 * Tracks a screen disappearing event with tags. It is recommended to track screen
 * disappearing events in viewDidDisappear. Tags can be used to filter events on TPA.
 *
 * @param screenTitle  The title of the screen that is disappearing.
 * @param tags         Tags that can be used to filter events on TPA.
 */
- (void)trackScreenDisappearing:(NSString * _Nonnull)screenTitle tags:(NSDictionary * _Nullable)tags;

#pragma mark - Esoteric stuff

/**
 * Enable debug logging. Will output extra information about the TPA library to the destinations specified in loggingDestinations.
 * Cannot be enabled for apps distributed via the App Store.
 *
 * Disabled by default.
 */
@property (nonatomic, readwrite, getter = isDebugLoggingEnabled) BOOL debugLoggingEnabled;

/**
 * Validate TPA server certificate.
 * Disable validation if using a self-signed certificate.
 *
 * Enabled by default.
 */
@property (nonatomic, readwrite) BOOL validateServerCertificate;
@end


/**
 * Logs message to the destinations specified by [TPAManager loggingDestinations].
 */
extern void TPALog(NSString * _Nonnull format, ...);

/**
 * Logs message to the destinations specified by [TPAManager loggingDestinations].
 */
extern void TPALogv(NSString * _Nonnull format, va_list _Nonnull args);
