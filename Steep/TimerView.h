//
//  TimerView.h
//  Steep
//
//  Created by Matthew on 4/30/13.
//  Copyright (c) 2013 MattbookPro Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TimerView : UIView {
    IBOutlet UIImageView *topBar;
    IBOutlet UIImageView *temperatureRect;
    IBOutlet UILabel *temperatureRectInnerText;
    IBOutlet UIImageView *timeRect;
    IBOutlet UILabel *timeRectInnerText;
    IBOutlet UILabel *timerDisplay;
    IBOutlet UILabel *tapText;
    IBOutlet UILabel *factTextBox;
}

@property (strong, nonatomic) IBOutlet UILabel *timerDisplay;
@property (strong, nonatomic) IBOutlet UILabel *tapText;
@property (strong, nonatomic) IBOutlet UILabel *factTextBox;
@property (strong, nonatomic) IBOutlet UILabel *temperatureRectInnerText;
@property (strong, nonatomic) IBOutlet UILabel *timeRectInnerText;


- (id)initWithFrame:(CGRect)frame;
- (void)fillTimerViewWithTeaFrom:(NSDictionary *)teaDictionary;

@end
