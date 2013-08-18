//
//  AppDelegate.m
//  Steep
//
//  Created by Matthew on 4/19/13.
//  Copyright (c) 2013 MattbookPro Apps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize mainViewController;

UILocalNotification *localNotification;
int counterValueWhenEnteredBackground = 0;
NSDate *timeAtEnteringBackground;
int timeElapsed = 0;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // This is a simple comment to make sure that Xcode and Github are loving each other
    
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Check if the timer is even running before creating a localNotification
    if ([self.mainViewController timer]) {
        [self.mainViewController cancelTimer];
        counterValueWhenEnteredBackground = [self.mainViewController getCounter];
        timeAtEnteringBackground = [NSDate date];
        
        if (self.mainViewController.paused == FALSE) {
            [self createLocalNotification];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // If a localNotification has been created, kill it.
    UIApplication *app = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
    
    // Compute the time left on the timer by getting the current time, subtracting the timeAtEnteringBackground
    // which is the seconds elapsed while out of the app. Then subtract that time from counterValueWhenEnteredBackground
    NSDate *timeAtEnteringForeground = [NSDate date];
    timeElapsed = [timeAtEnteringForeground timeIntervalSince1970] - [timeAtEnteringBackground timeIntervalSince1970];
    
    int timeLeftOnTimer = counterValueWhenEnteredBackground - timeElapsed;
    
    if ([self.mainViewController timer]) {
        if (self.mainViewController.paused == TRUE) {
            [self.mainViewController pauseTimerAtTime:counterValueWhenEnteredBackground];
        } else if (self.mainViewController.paused == FALSE) {
            [self.mainViewController resumeTimerWith:timeLeftOnTimer];
        }
    }
}

-(void)createLocalNotification {
    // create a NSDate from the string using our formatter
	NSDate *alertTime = [NSDate date];
    
	// get an instance of our UIApplication
	UIApplication *app = [UIApplication sharedApplication];
    
    // create the notification and then set it's parameters
	localNotification = [[UILocalNotification alloc] init];
    if (localNotification)
    {
        localNotification.fireDate = [alertTime dateByAddingTimeInterval:counterValueWhenEnteredBackground];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.repeatInterval = 0;
		localNotification.alertBody = @"Your tea has steeped. You can now safely enjoy it.";
		
		// this will schedule the notification to fire at the fire date
		[app scheduleLocalNotification:localNotification];
        NSLog(@"%@",@"Notification created.");
    }
}

@end
