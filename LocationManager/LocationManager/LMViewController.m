//
//  LMViewController.m
//  LocationManager
//
//  Created by Developer on 6/18/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMViewController.h"
#import "LMMapViewController.h"
#import "LMSettingsViewController.h"

#import "LMSportTracker.h"

@interface LMViewController ()

@property (strong, nonatomic) LMSportTracker *sportTracker;
@property (strong, nonatomic) LMMapViewController *mapViewController;
@property (strong, nonatomic) LMSettingsViewController *settingsViewController;

@property (strong, nonatomic) NSTimer *trackerUpdateTimer;

@property (strong, nonatomic) NSString *weight;
@property (strong, nonatomic) NSString *gender;

@property (nonatomic) NSInteger age;
@property (nonatomic) NSInteger height;

@property (nonatomic) CGFloat waistline;
@property (nonatomic) CGFloat hips;

@end

@implementation LMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((self.sportTracker == nil)) {
        self.sportTracker = [[LMSportTracker alloc]initTrackerWithAccuracy:kCLLocationAccuracyBest];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(proximityChanged:) name:UIDeviceProximityStateDidChangeNotification object:[UIDevice currentDevice]];

}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![self.trackerUpdateTimer isValid]) {
        if (self.sportTracker != nil) {
            [self.sportTracker exitBackground];
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    if (self.sportTracker != nil) {
        [self.sportTracker enterBackground];
    }
    
}

- (void)trackerUpdate {
    
    if (self.sportTracker.distance/1000 != -1.0) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f",self.sportTracker.distance/1000];
    }
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f",self.sportTracker.speed * 3.6];
    
    if (self.sportTracker.seconds != 0) {
        self.timeLabel.text = [self intervalToTime:self.sportTracker.seconds];
    }
    
    self.accCountLabel.text = [NSString stringWithFormat:@"%li",(long)self.sportTracker.steps];
    
    if (self.sportTracker.laps != -1) {
        self.lapLabel.text = [NSString stringWithFormat:@"%li",(long)self.sportTracker.laps];
    }
    
    self.burnedCaloriesLabel.text = [NSString stringWithFormat:@"%.1f",[self.sportTracker caloriesBurned:[self.weight floatValue] gender:self.genderControl.selectedSegmentIndex]];
    self.consumptionWaterLabel.text = [NSString stringWithFormat:@"%.1f",[self.sportTracker waterConsumption:[self.weight floatValue]]];
    self.fatLabel.text = [NSString stringWithFormat:@"%.2f",[self.sportTracker fatBurned:[self.sportTracker caloriesBurned:[self.weight floatValue] gender:self.genderControl.selectedSegmentIndex]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Enter/Exit Background

- (void)proximityChanged:(NSNotificationCenter *)center {
    
    if ([UIDevice currentDevice].proximityState == YES) {
        if (self.sportTracker != nil) {
            [self.sportTracker enterBackground];
        }
    } else {
        if (self.sportTracker != nil) {
            [self.sportTracker exitBackground];
        }
    }
}

#pragma mark - Convert Interval to Time

- (NSString *)intervalToTime:(NSTimeInterval)interval {
    
    NSInteger minutes = floor(interval/60);
    NSInteger intInterval = interval;
    NSString *time = @"";
    
    if (minutes != 0) {
        NSInteger seconds = intInterval%(60*minutes);
        if (seconds == 60) {
            seconds = 0;
        }
        if (seconds < 10) {
            time = [NSString stringWithFormat:@"%li : 0%@",(long)minutes, [NSString stringWithFormat:@"%li",(long)seconds]];
        } else
            time = [NSString stringWithFormat:@"%li : %li",(long)minutes, (long)seconds];
    } else {
        if (interval < 10) {
            time = [NSString stringWithFormat:@"%li : 0%@",(long)minutes, [NSString stringWithFormat:@"%li",(long)interval]];
        } else
            time = [NSString stringWithFormat:@"%li : %li",(long)minutes, (long)interval];
    }
    
    return time;

}

#pragma mark - On Buttons

- (IBAction)onResetButton:(id)sender {

    [self.sportTracker resetTracker];
   
    self.distanceLabel.text = @"0.00";
    self.speedLabel.text = @"0.0";
    self.timeLabel.text = @"0 : 00";
    self.accCountLabel.text = @"0";
    self.lapLabel.text = @"0";
    self.burnedCaloriesLabel.text = @"0.0";
    self.consumptionWaterLabel.text = @"0.0";
    self.fatLabel.text = @"0.00";
    self.biologicalAgeLabel.text = @"0";
    self.agingFactorLabel.text = @"0.0";
    self.weightTextField.text = @"";
    self.ageTextField.text = @"";
    self.waistlineTextField.text = @"";
    self.hipsTextField.text = @"";
    self.heightTextField.text = @"";
    
}

- (IBAction)onStartButton:(id)sender {

    [self.sportTracker startTracker];
    
    if (![self.trackerUpdateTimer isValid]) {
        self.trackerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(trackerUpdate) userInfo:nil repeats:YES];
    }
    
}

- (IBAction)onStopButton:(id)sender {
    
    [self.sportTracker stopTacker];
    [self.trackerUpdateTimer invalidate];
}

- (void)onMapButton:(id)sender {
    
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    self.mapViewController.currentLocation = self.sportTracker.currentLocation;
    [self.navigationController pushViewController:self.mapViewController animated:YES];
}

- (IBAction)onSettingsButton:(id)sender {
        
    if (self.settingsView.hidden) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.2;
        transition.type = kCATransitionPush;
        [self.settingsView.layer addAnimation:transition forKey:nil];
    }
    
    self.settingsView.hidden = NO;
    
}

- (IBAction)onOKButton:(id)sender {
    
    self.weight = self.weightTextField.text;
    self.age = [self.ageTextField.text integerValue];
    self.height = [self.heightTextField.text floatValue];
    self.waistline = [self.waistlineTextField.text floatValue];
    self.hips = [self.hipsTextField.text floatValue];
    [self.settingsView endEditing:YES];
    self.settingsView.hidden = YES;
    
    NSInteger bAge = [self.sportTracker biologicalAge:self.genderControl.selectedSegmentIndex age:self.age weight:[self.weight integerValue] height:self.height waistline:self.waistline hips:self.hips];
    self.biologicalAgeLabel.text = [NSString stringWithFormat:@"%li",(long)bAge];
    self.agingFactorLabel.text = [NSString stringWithFormat:@"%.1f",self.sportTracker.agingFactor];
}


- (IBAction)onMetabolismButton:(id)sender {
    
    if (self.metabolismView.hidden) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.2;
            transition.type = kCATransitionPush;
            [self.metabolismView.layer addAnimation:transition forKey:@"transition"];
        
        self.metabolismView.hidden = NO;
    } else {
        
            CATransition *transition = [CATransition animation];
            transition.duration = 0.2;
            transition.type = kCATransitionPush;
            [self.metabolismView.layer addAnimation:transition forKey:@"transition"];
        
        self.metabolismView.hidden = YES;
    }
    
}

@end