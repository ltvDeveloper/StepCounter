//
//  LMViewController.h
//  LocationManager
//
//  Created by Developer on 6/18/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface LMViewController : UIViewController

- (IBAction)onResetButton:(id)sender;
- (IBAction)onStartButton:(id)sender;
- (IBAction)onStopButton:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *stepsLabel;
@property (strong, nonatomic) IBOutlet UILabel *stepsNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UILabel *motion;

@end
