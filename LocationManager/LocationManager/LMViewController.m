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
@property (nonatomic) NSInteger growth;

@property (nonatomic) float waistline;
@property (nonatomic) float hips;

@property (assign, nonatomic) BOOL isStop;

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

-(void)viewDidAppear:(BOOL)animated {
    
    if (!self.isStop) {
        if (self.sportTracker != nil) {
            [self.sportTracker backgroundMode:NO];
        }
    }
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
    if (self.sportTracker != nil) {
        [self.sportTracker backgroundMode:YES];
    }
    
}

- (void)trackerUpdate {
    
    if (self.sportTracker.distance/1000 != -1.0) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f",self.sportTracker.distance/1000];
    }
    
    self.speedLabel.text = [NSString stringWithFormat:@"%.1f",self.sportTracker.speed * 3.6];
    
    if (self.sportTracker.time != nil) {
        self.timeLabel.text = self.sportTracker.time;
    }
    
    self.accCountLabel.text = [NSString stringWithFormat:@"%li",(long)self.sportTracker.steps];
    
    if (self.sportTracker.laps != -1) {
        self.lapLabel.text = [NSString stringWithFormat:@"%i",self.sportTracker.laps];
    }
    
    self.burnedCaloriesLabel.text = [NSString stringWithFormat:@"%.1f",[self.sportTracker caloriesBurned:[self.weight floatValue] gender:self.gender]];
    self.consumptionWaterLabel.text = [NSString stringWithFormat:@"%.1f",[self.sportTracker waterConsumption:[self.weight floatValue]]];
    self.fatLabel.text = [NSString stringWithFormat:@"%.2f",[self.sportTracker fatBurned:[self.sportTracker caloriesBurned:[self.weight floatValue] gender:self.gender]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Proximity State Change Notification

- (void)proximityChanged:(NSNotificationCenter *)center {
    
    if ([UIDevice currentDevice].proximityState == YES) {
        if (self.sportTracker != nil) {
            [self.sportTracker backgroundMode:YES];
        }
    } else {
        if (self.sportTracker != nil) {
            [self.sportTracker backgroundMode:NO];
        }
    }
}

#pragma mark - Battery Level Change Notification

- (void)batteryLevelChanged:(NSNotificationCenter *)center {
    
    if ([UIDevice currentDevice].batteryLevel <= 5.0f) {
        [self.sportTracker setAccuracy:kCLLocationAccuracyKilometer];
    }
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
    self.consumptionWaterLabel.text = @"0.000";
    self.fatLabel.text = @"0.00";
}

- (IBAction)onStartButton:(id)sender {

    
    
    self.isStop = NO;
    
    [self.sportTracker startTracker];
    
    self.trackerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(trackerUpdate) userInfo:nil repeats:YES];
}

- (IBAction)onStopButton:(id)sender {
    
    self.isStop = YES;
    
    [self.sportTracker stopTacker];
    [self.trackerUpdateTimer invalidate];
}

-(void)onMapButton:(id)sender {
    
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    self.mapViewController.path = self.sportTracker.path;
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
    self.growth = [self.growthTextField.text floatValue];
    self.waistline = [self.waistlineTextField.text floatValue];
    self.hips = [self.hipsTextField.text floatValue];
    [self.settingsView endEditing:YES];
    self.settingsView.hidden = YES;
    
    NSInteger bAge = [self.sportTracker biologicalAge:self.gender age:self.age weight:[self.weight integerValue] growth:self.growth waistline:self.waistline hips:self.hips];
    self.biologicalAgeLabel.text = [NSString stringWithFormat:@"%i",bAge];
    self.agingFactorLabel.text = [NSString stringWithFormat:@"%.1f",self.sportTracker.agingFactor];
}

- (IBAction)onGenderControl:(id)sender {
    
    switch (self.genderControl.selectedSegmentIndex) {
        case 0:
            self.gender = @"Male";
            break;
        case 1:
            self.gender = @"Female";
            break;
    }
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