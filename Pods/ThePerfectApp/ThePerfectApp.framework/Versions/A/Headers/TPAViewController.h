//
//  TPAViewController.h
//  ThePerfectApp
//
//  Created by Julian Król on 28/09/15.
//  Copyright © 2015 Trifork GmbH. All rights reserved.
//

@import UIKit.UIViewController;

@interface TPAViewController : UIViewController

/**
 * If enabled, screen actions like appearing, disappearing, memory warnings will be logged
 *
 * Default YES
 */
@property (nonatomic, getter = isTrackingEnabled) BOOL trackingEnabled;

/**
 * Name that will be used to identify the screen while tracking actions, if not set then looks at self.title, if not set then returns class name
 */
@property (nonatomic, copy) NSString * trackingScreenTitle;

@end
