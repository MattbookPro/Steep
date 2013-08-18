//
//  MainViewController.m
//  Steep
//
//  Created by Matthew on 4/19/13.
//  Copyright (c) 2013 MattbookPro Apps. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "TimerView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface MainViewController ()

@property (nonatomic, strong) IBOutlet TimerView *timerView;
@property (nonatomic, strong) IBOutlet UIImageView *headerImage;
@property (nonatomic, strong) NSDictionary *teaData;

// Menu Methods
- (void)drawMainScreen;
- (IBAction)teaTypeButton:(id)sender;
- (void)openWindowTo:(id)sender;
- (void)closeWindowFrom:(id)sender;
- (void)addTimerView:(CGRect)timerRect;// teaDict:(NSDictionary *)teaDictionary;

// Timer Methods
- (void)setupTimer;
- (IBAction)startTimer;
- (IBAction)resetAndStartTimerAfterHold;
- (void)updateTimerLabel;
- (void)resetDisplay:(int)toTime;
- (void)timerCompleted;

// Utility Methods
- (UIColor *)retrieveColorFromDictionaryForTea:(NSDictionary *)dictionary;
- (void)playSoundFileNamed:(NSString *)fileName ofType:(NSString *)fileType;

@end

@implementation MainViewController

@synthesize timerView,
            headerImage,
            blackButton,
            greenButton,
            herbalButton,
            oolongButton,
            whiteButton,
            yellowButton,
            footerImage,
            teaData,
            timerButton;
@synthesize started,
            paused;

bool firstPress = TRUE;
bool secondPress = FALSE;
bool audioOn = TRUE;

// Timer Variables
NSDictionary *teaDictionary;
NSNumber *minTimeInMinutes;
NSNumber *maxTimeInMinutes;
int minTimeInSeconds;
int maxTimeInSeconds;
int minMaxDifferenceInSeconds;
int counter;

// Handle type of device screen size with adjustments to sizes and positions
NSInteger topElementOverlap;
NSInteger bottomElementYPos;
NSInteger timerViewHeight;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    AppDelegate *theAppDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    theAppDelegate.mainViewController = self;
    
    if (IS_WIDESCREEN) {
        topElementOverlap = 49;
        bottomElementYPos = 484;
    } else {
        topElementOverlap = 35;
        bottomElementYPos = 458;
    }
    timerViewHeight = 360;
    
    // Load tea-data.plist containing data on teas into teaData property
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"tea-data.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    [self setTeaData:plistData];
    
    [self addTimerView:CGRectMake(0, 0, 320, timerViewHeight)];
    
    [self drawMainScreen];
}

- (void)drawMainScreen
{
    if ( IS_WIDESCREEN ) {
        [self.headerImage setFrame:CGRectMake(0, 0, 320, 86)];
        [self.headerImage setImage:[UIImage imageNamed:@"header_4in.png"]];
        
        [self.greenButton setFrame:CGRectMake(0, 86, 320, 77)];
        [self.greenButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"green"]]];
        [self.greenButton setTitle:@"GREEN" forState:UIControlStateNormal];
        [self.greenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.greenButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.greenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.greenButton.titleLabel setFont:[UIFont fontWithName:@"Geared Slab" size:52.0]];
        [self.greenButton setTitleEdgeInsets:UIEdgeInsetsMake(42.0, 0.0, 30.0, 0.0)];
        [self.greenButton setRestorationIdentifier:@"green"];
        
        [self.whiteButton setFrame:CGRectMake(0, 163, 320, 77)];
        [self.whiteButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"white"]]];
        [self.whiteButton setTitle:@"WHITE" forState:UIControlStateNormal];
        [self.whiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.whiteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.whiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.whiteButton.titleLabel setFont:[UIFont fontWithName:@"Haymaker" size:52.0]];
        [self.whiteButton setTitleEdgeInsets:UIEdgeInsetsMake(36.0, 0.0, 14.0, 0.0)];
        [self.whiteButton setRestorationIdentifier:@"white"];
        
        [self.blackButton setFrame:CGRectMake(0, 240, 320, 77)];
        [self.blackButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"black"]]];
        [self.blackButton setTitle:@"BLACK" forState:UIControlStateNormal];
        [self.blackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.blackButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.blackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.blackButton.titleLabel setFont:[UIFont fontWithName:@"Retro Town" size:52.0]];
        [self.blackButton setTitleEdgeInsets:UIEdgeInsetsMake(25.0, 0.0, 15.0, 0.0)];
        [self.blackButton setRestorationIdentifier:@"black"];
        
        [self.herbalButton setFrame:CGRectMake(0, 317, 320, 77)];
        [self.herbalButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"herbal"]]];
        [self.herbalButton setTitle:@"Herbal" forState:UIControlStateNormal];
        [self.herbalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.herbalButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.herbalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.herbalButton.titleLabel setFont:[UIFont fontWithName:@"Lobster 1.3" size:53.0]];
        [self.herbalButton setTitleEdgeInsets:UIEdgeInsetsMake(27.0, 0.0, 14.0, 0.0)];
        [self.herbalButton setRestorationIdentifier:@"herbal"];
        
        [self.oolongButton setFrame:CGRectMake(0, 394, 320, 77)];
        [self.oolongButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"oolong"]]];
        [self.oolongButton setTitle:@"OOLONG" forState:UIControlStateNormal];
        [self.oolongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.oolongButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.oolongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.oolongButton.titleLabel setFont:[UIFont fontWithName:@"Folks-Bold" size:52.0]];
        [self.oolongButton setTitleEdgeInsets:UIEdgeInsetsMake(22.0, 0.0, 20.0, 0.0)];
        [self.oolongButton setRestorationIdentifier:@"oolong"];
        
        [self.yellowButton setFrame:CGRectMake(0, 471, 320, 77)];
        [self.yellowButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"yellow"]]];
        [self.yellowButton setImage:[UIImage imageNamed:@"yellow_4in_trans.png"] forState:UIControlStateNormal];
        [self.yellowButton setImage:[UIImage imageNamed:@"yellow_4in_trans.png"] forState:UIControlStateDisabled];
        [self.yellowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.yellowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.yellowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        /* [self.yellowButton setTitle:@"Yellow" forState:UIControlStateNormal];
        [self.yellowButton.titleLabel setFont:[UIFont fontWithName:@"Mission Script" size:52.0]];
        [self.yellowButton setTitleEdgeInsets:UIEdgeInsetsMake(20, 0.0, 14.0, 0.0)]; */
        [self.yellowButton setRestorationIdentifier:@"yellow"];
    } else {
        [self.headerImage setFrame:CGRectMake(0, 0, 320, 70)];
        [self.headerImage setImage:[UIImage imageNamed:@"header.png"]];
        
        [self.greenButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"green"]]];
        [self.greenButton setTitle:@"GREEN" forState:UIControlStateNormal];
        [self.greenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.greenButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.greenButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.greenButton.titleLabel setFont:[UIFont fontWithName:@"Geared Slab" size:50.0]];
        [self.greenButton setTitleEdgeInsets:UIEdgeInsetsMake(30.0, 0.0, 15.0, 0.0)];
        
        [self.whiteButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"white"]]];
        [self.whiteButton setTitle:@"WHITE" forState:UIControlStateNormal];
        [self.whiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.whiteButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.whiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.whiteButton.titleLabel setFont:[UIFont fontWithName:@"Haymaker" size:50.0]];
        [self.whiteButton setTitleEdgeInsets:UIEdgeInsetsMake(36.0, 0.0, 14.0, 0.0)];
        
        [self.blackButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"black"]]];
        [self.blackButton setTitle:@"BLACK" forState:UIControlStateNormal];
        [self.blackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.blackButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.blackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.blackButton.titleLabel setFont:[UIFont fontWithName:@"Retro Town" size:50.0]];
        [self.blackButton setTitleEdgeInsets:UIEdgeInsetsMake(25.0, 0.0, 15.0, 0.0)];
        
        [self.herbalButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"herbal"]]];
        [self.herbalButton setTitle:@"Herbal" forState:UIControlStateNormal];
        [self.herbalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.herbalButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.herbalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.herbalButton.titleLabel setFont:[UIFont fontWithName:@"Lobster 1.3" size:51.0]];
        [self.herbalButton setTitleEdgeInsets:UIEdgeInsetsMake(27.0, 0.0, 14.0, 0.0)];

        [self.oolongButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"oolong"]]];
        [self.oolongButton setTitle:@"OOLONG" forState:UIControlStateNormal];
        [self.oolongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.oolongButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.oolongButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.oolongButton.titleLabel setFont:[UIFont fontWithName:@"Folks-Bold" size:50.0]];
        [self.oolongButton setTitleEdgeInsets:UIEdgeInsetsMake(22.0, 0.0, 20.0, 0.0)];
        
        [self.yellowButton setBackgroundColor:[self retrieveColorFromDictionaryForTea:[teaData objectForKey:@"yellow"]]];
        [self.yellowButton setTitle:@"Yellow" forState:UIControlStateNormal];
        [self.yellowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.yellowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.yellowButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.yellowButton.titleLabel setFont:[UIFont fontWithName:@"Mission Script" size:50.0]];
        [self.yellowButton setTitleEdgeInsets:UIEdgeInsetsMake(22.0, 0.0, 15.0, 0.0)];
    }
}

- (IBAction)teaTypeButton:(id)sender
{
    if (firstPress) {
        [self openWindowTo:sender];
    }
    else if (!firstPress)
    {
        [self closeWindowFrom:sender];
    }
}

-(void)openWindowTo:(id)sender
{
    UIButton *senderCopy = sender;
    NSString *senderKey = senderCopy.restorationIdentifier;
    
    teaDictionary = [[NSDictionary alloc] initWithDictionary:[self.teaData objectForKey:senderKey]];
    
    [self.timerView setFrame:CGRectMake(0, senderCopy.frame.origin.y + senderCopy.frame.size.height, 320, timerViewHeight)];
    [self.timerView fillTimerViewWithTeaFrom:teaDictionary];
    
    [self setupTimer];
    
    NSInteger countOfSubviewsArray = [[self.view subviews] count];
    NSInteger countOfObjectsAboveSender = countOfSubviewsArray - (countOfSubviewsArray - [[self.view subviews] indexOfObject:sender]);
    NSInteger countOfObjectsAboveSenderGoingOffScreen = countOfObjectsAboveSender - 1;
    NSInteger cumulativeHeightOfElementsGoingOffScreen = 0;
    
    for (int i = 1; i <= countOfObjectsAboveSenderGoingOffScreen; i++) {
        CGRect currentIndexFrame = [[[self.view subviews] objectAtIndex:i] frame];
        cumulativeHeightOfElementsGoingOffScreen += currentIndexFrame.size.height;
    }
    
    NSInteger cumulativeHeightToSubtractFrom = cumulativeHeightOfElementsGoingOffScreen;
    __block NSMutableArray *arrayOfNewFrames = [[NSMutableArray alloc] init];
    
    // Change frames of objects above the object directly above the sender object
    for (int i = 1; i <= countOfObjectsAboveSenderGoingOffScreen; i++) {
        // Gets frame of object at the i index of the subviews array
        CGRect frameOfObjectAtCurrentIndex = [[[self.view subviews] objectAtIndex:i] frame];
        // Change the y origin to the appropriate value
        frameOfObjectAtCurrentIndex.origin.y = frameOfObjectAtCurrentIndex.origin.y - cumulativeHeightOfElementsGoingOffScreen;
        // Add the new frame to the arrayOfNewFrames array for use later
        [arrayOfNewFrames addObject:[NSValue valueWithCGRect:frameOfObjectAtCurrentIndex]];
        // Subtract the height of the current object from the cumulativeHeight;
        cumulativeHeightToSubtractFrom -= frameOfObjectAtCurrentIndex.size.height;
        [[[self.view subviews] objectAtIndex:i] setEnabled:NO];
    }
    
    // Get the index of the sender object in the subviews array
    NSInteger indexOfSender = [[self.view subviews] indexOfObject:sender];
    // Get the rect of the object above the sender
    CGRect rectOfObjectAboveSender = [[[self.view subviews] objectAtIndex:indexOfSender-1] frame];
    // Make the y origin of the object above the sender 0
    rectOfObjectAboveSender.origin.y = 0;
    // Add the new frame of the object above the sender to the end of the arrayOfNewFrames array
    [arrayOfNewFrames addObject:[NSValue valueWithCGRect:rectOfObjectAboveSender]];
    
    // Get the rect of the sender
    CGRect rectOfSender = [[[self.view subviews] objectAtIndex:indexOfSender] frame];
    // Change the value of the y origin
    rectOfSender.origin.y = topElementOverlap;
    // Add the new frame of the sender to the arrayOfNewFrames array
    [arrayOfNewFrames addObject:[NSValue valueWithCGRect:rectOfSender]];
    
    // Change frames of objects below sender
    int indexCounter = 0;
    for (int i = indexOfSender + 1; i < countOfSubviewsArray; i++) {
        // Gets frame of object at the i index of the subviews array
        // Change the y origin to the appropriate value
        // Add the new frame to the arrayOfNewFrames array for use later
        CGRect frameOfObjectAtCurrentIndex = [[[self.view subviews] objectAtIndex:i] frame];
        frameOfObjectAtCurrentIndex.origin.y = bottomElementYPos + (indexCounter * senderCopy.frame.size.height);
        [arrayOfNewFrames addObject:[NSValue valueWithCGRect:frameOfObjectAtCurrentIndex]];
        
        // Disable buttons below sender object
        [[[self.view subviews] objectAtIndex:i] setEnabled:NO];
        
        indexCounter++;
    }
    
    if (sender == self.yellowButton || sender == self.oolongButton) {
        UIImageView *footerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"footer.png"]];
        CGRect footerImageRect = CGRectMake(0, self.yellowButton.frame.origin.y + self.yellowButton.frame.size.height, 320, 100);
        [footerImageView setFrame:footerImageRect];
        
        self.footerImage = footerImageView;
        [self.view addSubview:footerImage];
    }
    
    // Animate the frames changing for the buttons
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self playSoundFileNamed:@"click" ofType:@"wav"]; // Play click.wav sound effect
                         
                         // Get the count of the newFramesArray
                         NSInteger countOfNewFramesArray = [arrayOfNewFrames count];
                         for (int i = 1; i < countOfNewFramesArray; i++) {
                             CGRect newFrame = [[arrayOfNewFrames objectAtIndex:i] CGRectValue];
                             [[[self.view subviews] objectAtIndex:i] setFrame:newFrame];
                         }
                         
                         CGRect newTimerFrame = CGRectMake(0, senderCopy.frame.origin.y + senderCopy.frame.size.height, 320, timerViewHeight);
                         [self.timerView setFrame:newTimerFrame];

                         if (sender == self.oolongButton) {
                             CGRect newFooterFrame = CGRectMake(0,
                                                                newTimerFrame.origin.y + newTimerFrame.size.height + senderCopy.frame.size.height - 1,
                                                                320,
                                                                100);
                             [self.footerImage setFrame:newFooterFrame];
                         } else if (sender == self.yellowButton) {
                             CGRect newFooterFrame = CGRectMake(0,
                                                                self.yellowButton.frame.origin.y + self.yellowButton.frame.size.height + timerViewHeight,
                                                                320,
                                                                100);
                             [self.footerImage setFrame:newFooterFrame];
                         }
                         
                     }
                     completion:^(BOOL finished){
                         // Create an invisible button to start and reset the timer
                         UIButton *tapButton = [[UIButton alloc] init];
                         [tapButton setFrame:CGRectMake(self.timerView.frame.origin.x + 25,
                                                        self.timerView.frame.origin.y + 90,
                                                        270,
                                                        90)];
                         [tapButton addTarget:self
                                       action:@selector(startTimer)
                             forControlEvents:UIControlEventTouchUpInside];
                         [tapButton setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
                         [self setTimerButton:tapButton];
                         
                         [self.view bringSubviewToFront:timerView];                         
                         [self.view insertSubview:timerButton aboveSubview:timerView];
                    }];
    
    firstPress = FALSE;
    self.paused = TRUE;
}

-(void)closeWindowFrom:(id)sender
{
    // Stop any timer that is running when closing
    [self.timer invalidate];
    
    UIButton *senderCopy = sender;
    
    CGRect oldHeaderImageFrame = self.headerImage.frame;
    CGRect oldGreenButtonFrame = self.greenButton.frame;
    CGRect oldWhiteButtonFrame = self.whiteButton.frame;
    CGRect oldBlackButtonFrame = self.blackButton.frame;
    CGRect oldHerbalButtonFrame = self.herbalButton.frame;
    CGRect oldOolongButtonFrame = self.oolongButton.frame;
    CGRect oldYellowButtonFrame = self.yellowButton.frame;
    CGRect oldFooterImageFrame = self.footerImage.frame;
    
    if (IS_WIDESCREEN) {
        oldHeaderImageFrame.origin.y = 0;
        oldHeaderImageFrame.size.height = 86;
        oldGreenButtonFrame.origin.y = 86;
        oldWhiteButtonFrame.origin.y = 163;
        oldBlackButtonFrame.origin.y = 240;
        oldHerbalButtonFrame.origin.y = 317;
        oldOolongButtonFrame.origin.y = 394;
        oldYellowButtonFrame.origin.y = 471;
        oldFooterImageFrame.origin.y = 548;
    } else {
        oldHeaderImageFrame.origin.y = 0;
        oldHeaderImageFrame.size.height = 70;
        oldGreenButtonFrame.origin.y = 70;
        oldWhiteButtonFrame.origin.y = 135;
        oldBlackButtonFrame.origin.y = 200;
        oldHerbalButtonFrame.origin.y = 265;
        oldOolongButtonFrame.origin.y = 330;
        oldYellowButtonFrame.origin.y = 395;
        oldFooterImageFrame.origin.y = 790;
    }
    
    [self.view sendSubviewToBack:timerView];
    [self.timerButton removeFromSuperview];
    
    // Animate the frame changing for the buttons
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self playSoundFileNamed:@"click" ofType:@"wav"];
                         
                         [self.headerImage setFrame:oldHeaderImageFrame];
                         [self.greenButton setFrame:oldGreenButtonFrame];
                         [self.whiteButton setFrame:oldWhiteButtonFrame];
                         [self.blackButton setFrame:oldBlackButtonFrame];
                         [self.herbalButton setFrame:oldHerbalButtonFrame];
                         [self.oolongButton setFrame:oldOolongButtonFrame];
                         [self.yellowButton setFrame:oldYellowButtonFrame];
                         
                         // Reenable all buttons that may have been disabled if under active button
                         [self.greenButton setEnabled:YES];
                         [self.whiteButton setEnabled:YES];
                         [self.blackButton setEnabled:YES];
                         [self.herbalButton setEnabled:YES];
                         [self.oolongButton setEnabled:YES];
                         [self.yellowButton setEnabled:YES];
                         
                         CGRect oldTimerFrame = CGRectMake(0, senderCopy.frame.origin.y + senderCopy.frame.size.height, 320, timerViewHeight);
                         [self.timerView setFrame:oldTimerFrame];
                         [self.footerImage setFrame:oldFooterImageFrame];
                     }
                     completion:^(BOOL finished){
                         [self.footerImage removeFromSuperview];
                     }];
    
    firstPress = TRUE;
}

- (void)addTimerView:(CGRect)timerRect
{
    self.timerView = [[TimerView alloc] initWithFrame:timerRect]; // teaDict:teaDictionary];
    [self.timerView setBounds:timerRect];
    
    [self.view addSubview:timerView];
    [self.view sendSubviewToBack:timerView];
}

// Timer Methods
- (void)setupTimer
{
    // Set timer variables
    // Get min and max times from teaDictionary as NSNumber
    minTimeInMinutes = [teaDictionary objectForKey:@"min-time"];
    maxTimeInMinutes = [teaDictionary objectForKey:@"max-time"];
    
    minTimeInSeconds = minTimeInMinutes.intValue * 60;
    maxTimeInSeconds = maxTimeInMinutes.intValue * 60;
    
    minMaxDifferenceInSeconds = maxTimeInSeconds - minTimeInSeconds;
    
    counter = maxTimeInSeconds;
    
    [self resetDisplay:counter];
}

- (IBAction)startTimer
{
    [self resetDisplay:counter];
    
    if (self.started == FALSE && self.paused == TRUE) {
        
        [self playSoundFileNamed:@"click" ofType:@"wav"];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
        
        // [self.timerView.tapText setText:NSLocalizedString(@"START STEEPIN'...", "START STEEPIN'...")];
        
        self.started = TRUE;
        self.paused = FALSE;
        
    } else if (self.started == TRUE && self.paused == FALSE) {
        [self pauseTimerAtTime:counter];
        self.started = FALSE;
        self.paused = TRUE;
    }
}

- (void)pauseTimerAtTime:(int)time
{
    // Hide "TAP TO PAUSE" label
    [self.timerView.tapText setHidden:NO];
    // Kill timer
    [self.timer invalidate];
    // Set timer display at time paused
    [self resetDisplay:time];
    
    // Change the text of the tapText label
    [self.timerView.tapText setText:NSLocalizedString(@"TAP TIMER AGAIN TO START\nOR HOLD DOWN TO RESTART", "TAP AND HOLD")];
    
    // Create long press gesture to restart timer at max time, send action to @selector resetAndStartTimerAfterHold:
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(resetAndStartTimerAfterHold)];
    // Set longPressGesture to 1 second
    [longPressGesture setMinimumPressDuration:1];
    // Add longPressGesture UIGestureRecognizer to the hidden timer button
    [self.timerButton addGestureRecognizer:longPressGesture];
}

- (IBAction)resetAndStartTimerAfterHold
{
    [self setupTimer];
    // Reset tapText to initial state
    [self.timerView.tapText setText:NSLocalizedString(@"TAP TIMER TO START", "TAP TIMER TO START")];
    // Remove the UIGestureRecognizer from the timerButton
    for (UIGestureRecognizer *recognizer in self.timerButton.gestureRecognizers) {
        [self.timerButton removeGestureRecognizer:recognizer];
    }
}

- (void)resumeTimerWith:(int)time
{
    // This method is called when the app is reappearing from the background.
    
    // Set the clock to the time received by the method call.
    // The time is typically the time when it was backgrounded
    counter = time;
    // These two booleans are for the startTimer: method to know how to handle the started/paused state when the timer
    self.started = FALSE;
    self.paused = TRUE;
    
    [self startTimer];
}

- (void)updateTimerLabel
{
    counter -= 1;
    
    [self resetDisplay:counter];
    [self playSoundFileNamed:@"tick" ofType:@"mp3"];
    
    if (counter <= minTimeInSeconds) // If the timer has reached the min time, display the pull text
    {
        [self.timerView.tapText setText:NSLocalizedString(@"MINIMUM STEEP TIME REACHED", "MINIMUM STEEP TIME REACHED")];
        [self.timerView.tapText setHidden:NO];
    } else {
        [self.timerView.tapText setText:NSLocalizedString(@"START STEEPIN'...", "START STEEPIN'...")];
    }
    if (counter == 0) { // If the timer has reached 0, stop the timer and reset the variables
        [self.timer invalidate];
        [self timerCompleted];
    }
}

- (void)resetDisplay:(int)toTime
{
    NSNumber *valueForDisplay = [NSNumber numberWithDouble:toTime];
    NSNumber *totalMinutes = [NSNumber numberWithInt:([valueForDisplay intValue] / 60)];
    NSNumber *totalSeconds = [NSNumber numberWithInt:([valueForDisplay intValue] % 60)];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPaddingPosition:NSNumberFormatterPadBeforePrefix];
    [numberFormatter setPaddingCharacter:@"0"];
    [numberFormatter setMinimumIntegerDigits:2];
    [numberFormatter setMaximumIntegerDigits:2];
    
    NSString *minutesDisplay = [numberFormatter stringFromNumber:totalMinutes];
    NSString *secondsDisplay = [numberFormatter stringFromNumber:totalSeconds];
    
    [self.timerView.timerDisplay setText:[NSString stringWithFormat:@"%@:%@",minutesDisplay,secondsDisplay]];
}

- (void)timerCompleted
{
    [self.timerView.timerDisplay setText:[NSString stringWithFormat:@"00:00"]];
    [self.timerView.tapText setText:NSLocalizedString(@"All done!", "All done!")];
    [self playSoundFileNamed:@"tri" ofType:@"wav"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"All done!", "All done!")
                                                    message:NSLocalizedString(@"Your tea has steeped.\nYou can now (safely) enjoy it.", "Your tea has steeped.\nYou can now (safely) enjoy it.")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", "OK")
                                          otherButtonTitles:nil];
    [alert show];
    [self closeWindowFrom:self.timerView];
}

- (void)cancelTimer
{
    if (self.timer) {
        [self.timer invalidate];
    }
}

- (int)getCounter
{
    return counter;
}

// Utility Methods
- (UIColor *)retrieveColorFromDictionaryForTea:(NSDictionary *)dictionary
{
    
    NSDictionary *colorDictionary = [[NSDictionary alloc] initWithDictionary:[dictionary objectForKey:@"color"]];
    
    NSString *redString = [colorDictionary objectForKey:@"red"];
    float redFloat = redString.floatValue;
    NSString *greenString = [colorDictionary objectForKey:@"green"];
    float greenFloat = greenString.floatValue;
    NSString *blueString = [colorDictionary objectForKey:@"blue"];
    float blueFloat = blueString.floatValue;
    
    UIColor *color = [UIColor colorWithRed:redFloat/255 green:greenFloat/255 blue:blueFloat/255 alpha:1.0f];
    
    return color;
}

- (void)playSoundFileNamed:(NSString *)fileName ofType:(NSString *)fileType
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool audioOn = [defaults boolForKey:@"soundEnabled"];
    
    if (audioOn == NO) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:soundPath]), &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
}

@end
