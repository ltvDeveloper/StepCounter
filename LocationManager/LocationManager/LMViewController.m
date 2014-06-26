//
//  LMViewController.m
//  LocationManager
//
//  Created by Developer on 6/18/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMViewController.h"
#import "LMMapViewController.h"

#import "LMSportTracker.h"

@interface LMViewController ()

@property (strong, nonatomic) LMSportTracker *sportTracker;
@property (strong, nonatomic) LMMapViewController *mapViewController;

@property (strong, nonatomic) NSTimer *trackerUpdateTimer;

@end

@implementation LMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(proximityChanged:) name:UIDeviceProximityStateDidChangeNotification object:[UIDevice currentDevice]];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    if (self.sportTracker != nil) {
        [self.sportTracker backgroundMode:NO];
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

#pragma mark - On Buttons

- (IBAction)onResetButton:(id)sender {

    [self.sportTracker resetTracker];
    
    self.distanceLabel.text = @"0.00";
    self.speedLabel.text = @"0.0";
    self.timeLabel.text = @"0 : 0";
    self.accCountLabel.text = @"0";
}

- (IBAction)onStartButton:(id)sender {

    if ((self.sportTracker == nil)) {
        self.sportTracker = [[LMSportTracker alloc]initTrackerWithAccuracy:kCLLocationAccuracyBest];
    }
    
    [self.sportTracker startTracker];
    
    self.trackerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(trackerUpdate) userInfo:nil repeats:YES];
    [self.trackerUpdateTimer fire];
}

- (IBAction)onStopButton:(id)sender {
    
    [self.sportTracker stopTacker];
    [self.trackerUpdateTimer invalidate];
}


-(void)onMapButton:(id)sender {
    
    self.mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    self.mapViewController.path = self.sportTracker.path;
    self.mapViewController.currentLocation = self.sportTracker.currentLocation;
    
    [self.navigationController pushViewController:self.mapViewController animated:YES];
}

@end