//
//  TimerView.m
//  Steep
//
//  Created by Matthew on 4/30/13.
//  Copyright (c) 2013 MattbookPro Apps. All rights reserved.
//

#import "TimerView.h"
#import "MainViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation TimerView

@synthesize timerDisplay,
            tapText,
            factTextBox,
            temperatureRectInnerText,
            timeRectInnerText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor grayColor]];
        
        // Add the TopBar
        topBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TopBar.png"]];
        [topBar setFrame:CGRectMake(frame.origin.x + 35, frame.origin.y + 0, 250, 1)];
        [self addSubview:topBar];
        
        // Add TemperatureRect
        temperatureRect = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + 35, frame.origin.y + 31, 110, 40)];
        [temperatureRect setImage:[UIImage imageNamed:@"TempRect.png"]];
        [self addSubview:temperatureRect];
                
        CGRect temperatureRectInnerTextFrame = CGRectMake(frame.origin.x + 55, frame.origin.y + 33, 88, 36);
        temperatureRectInnerText = [[UILabel alloc] initWithFrame:temperatureRectInnerTextFrame];
        [temperatureRectInnerText setFont:[UIFont fontWithName:@"Futura" size:18]];
        [temperatureRectInnerText setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [temperatureRectInnerText setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [temperatureRectInnerText setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:temperatureRectInnerText];
        
        // Add TimeRect
        timeRect = [[UIImageView alloc] initWithFrame:CGRectMake(frame.origin.x + 175, frame.origin.y + 31, 110, 40)];
        [timeRect setImage:[UIImage imageNamed:@"TimeRect.png"]];
        [self addSubview:timeRect];
        
        // Get and add text for TimeRect
        CGRect timeRectInnerTextFrame = CGRectMake(frame.origin.x + 210, frame.origin.y + 33, 73, 36);
        timeRectInnerText = [[UILabel alloc] initWithFrame:timeRectInnerTextFrame];
        [timeRectInnerText setFont:[UIFont fontWithName:@"Futura" size:18]];
        [timeRectInnerText setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [timeRectInnerText setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [timeRectInnerText setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:timeRectInnerText];
        
        // Setup timerDisplay
        self.timerDisplay = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 25, frame.origin.y + 94, 270, 110)];
        [self.timerDisplay setFont:[UIFont fontWithName:@"Carton" size:102]];
        [self.timerDisplay setTextAlignment:NSTextAlignmentCenter];
        [self.timerDisplay setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [self.timerDisplay setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [self.timerDisplay setText:@"00:00"];
        [self addSubview:timerDisplay];
        
        // Setup TapText
        self.tapText = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 25, frame.origin.y + 180, 270, 44)];
        [self.tapText setFont:[UIFont fontWithName:@"GillSans" size:16]];
        [self.tapText setTextAlignment:NSTextAlignmentCenter];
        [self.tapText setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [self.tapText setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [self.tapText setText:NSLocalizedString(@"TAP TIMER TO START", "TAP TIMER TO START")];
        [self.tapText setNumberOfLines:0];
        [self addSubview:tapText];
        
        // Setup and add FactsTextBox
        self.factTextBox = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + 15, frame.origin.y + 230, 290, 115)];
        [self.factTextBox setFont:[UIFont fontWithName:@"Merriweather-Italic" size:13]];
        [self.factTextBox setTextAlignment:NSTextAlignmentCenter];
        [self.factTextBox setLineBreakMode:NSLineBreakByWordWrapping];
        [self.factTextBox setNumberOfLines:0];
        [self.factTextBox setTextColor:[UIColor colorWithWhite:1.0f alpha:0.6f]];
        [self.factTextBox setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [self addSubview:factTextBox];
    }
    return self;
}

- (void)fillTimerViewWithTeaFrom:(NSDictionary *)teaDictionary
{
    // Get color for background
    NSDictionary *colorDictionary = [[NSDictionary alloc] initWithDictionary:[teaDictionary objectForKey:@"color"]];
    NSString *redString = [colorDictionary objectForKey:@"red"];
    float redFloat = redString.floatValue;
    NSString *greenString = [colorDictionary objectForKey:@"green"];
    float greenFloat = greenString.floatValue;
    NSString *blueString = [colorDictionary objectForKey:@"blue"];
    float blueFloat = blueString.floatValue;
    
    UIColor *color = [UIColor colorWithRed:redFloat/255 green:greenFloat/255 blue:blueFloat/255 alpha:1.0f];
    [self setBackgroundColor:color];
    
    NSString *timeString = [teaDictionary objectForKey:@"time-string"];
    [self.timeRectInnerText setText:timeString];
    
    // Get and add text for TemperatureRect
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *tempUnits = [defaults valueForKey:@"tempUnits"];
    
    NSString *temperature;
    if (tempUnits.integerValue == 1) {
        temperature = [teaDictionary objectForKey:@"temperature-c"];
    } else if (tempUnits.integerValue == 0) {
        temperature = [teaDictionary objectForKey:@"temperature-f"];
    }
    [self.temperatureRectInnerText setText:temperature];
    
    // Get fact from plist
    NSArray *factsArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"facts", "facts plist") ofType:@"plist"]];
    int r = arc4random() % factsArray.count;
    //r = 0;
    NSString *factToDisplay = [factsArray objectAtIndex:r];
    [self.factTextBox setText:factToDisplay];

}

@end
