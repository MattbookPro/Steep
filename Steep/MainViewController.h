//
//  MainViewController.h
//  Steep
//
//  Created by Matthew on 4/19/13.
//  Copyright (c) 2013 MattbookPro Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *blackButton;
@property (nonatomic, strong) IBOutlet UIButton *greenButton;
@property (nonatomic, strong) IBOutlet UIButton *herbalButton;
@property (nonatomic, strong) IBOutlet UIButton *oolongButton;
@property (nonatomic, strong) IBOutlet UIButton *whiteButton;
@property (nonatomic, strong) IBOutlet UIButton *yellowButton;
@property (nonatomic, strong) IBOutlet UIImageView *footerImage;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) BOOL started;
@property (nonatomic) BOOL paused;

@property (nonatomic, strong) IBOutlet UIButton *timerButton;

- (void)cancelTimer;
- (void)pauseTimerAtTime:(int)time;
- (void)resumeTimerWith:(int)time;
- (int)getCounter;

@end
