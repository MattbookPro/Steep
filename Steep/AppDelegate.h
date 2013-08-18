//
//  AppDelegate.h
//  Steep
//
//  Created by Matthew on 4/19/13.
//  Copyright (c) 2013 MattbookPro Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    MainViewController *mainViewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

- (void)createLocalNotification;

@end
