//
//  LMViewController.m
//  LocationManager
//
//  Created by Developer on 6/18/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMViewController.h"

@interface LMViewController ()<CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationDistance distance;
@property (nonatomic) CLLocationDistance tmpDistance;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocation *oldLocation;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) CMStepCounter *stepCounter;

@property (strong, nonatomic) NSDate *startDate;

@end

@implementation LMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    self.location = [[CLLocation alloc]init];
    
    if ([CMStepCounter isStepCountingAvailable]) {
        
        self.stepCounter = [[CMStepCounter alloc]init];
    } else {
        self.stepsNameLabel.hidden = YES;
        self.stepsLabel.hidden = YES;
        UIAlertView *stepCounterAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Step counting isn't available on your device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [stepCounterAlert show];
    }
    
    self.oldLocation = nil;
    self.currentLocation = nil;
    self.startDate = nil;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.delegate = self;
    self.resetButton.hidden = YES;
    
    NSLog(@"%@",self.locationManager.location);
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    
    NSLog(@"%f",self.currentLocation.speed);
    
    self.oldLocation = self.currentLocation;
    self.currentLocation = locations.lastObject;
    
    if (self.startDate == nil) {
        self.startDate = self.currentLocation.timestamp;
         NSLog(@"%@",self.startDate);
    }
    
    self.tmpDistance = [self.currentLocation distanceFromLocation:self.oldLocation];
    self.distance += self.tmpDistance;
   
    if (self.currentLocation.speed == -1.0f) {
        self.speedLabel.text = @"0.0";
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%.1f",self.currentLocation.speed];
    }
    
    if (self.distance == -1.0f) {
        self.distanceLabel.text = @"0.0";
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f",self.distance];
    }
    
    CLLocation *curLoc = locations.lastObject;
    NSDate *curDate = curLoc.timestamp;
    self.timeLabel.text = [NSString stringWithFormat:@"%.0f",[curDate timeIntervalSinceDate:self.startDate]];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Error --- %@",error.userInfo);
}

#pragma mark - On Buttons

- (IBAction)onResetButton:(id)sender {
    
    self.currentLocation = nil;
    self.oldLocation = nil;
    self.startDate = nil;
    self.distance = 0.0f;
    self.tmpDistance = 0.0f;
    self.distanceLabel.text= @"0.0";
    self.speedLabel.text = @"0.0";
    self.timeLabel.text = @"0";
}

- (IBAction)onStartButton:(id)sender {
    
    [self.locationManager startUpdatingLocation];
    
    [self.stepCounter startStepCountingUpdatesToQueue:[NSOperationQueue currentQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
        self.stepsLabel.text = [NSString stringWithFormat:@"%ld",(long)numberOfSteps];
    }];
}

- (IBAction)onStopButton:(id)sender {
    
    [self.locationManager stopUpdatingLocation];
    [self.stepCounter stopStepCountingUpdates];
}
@end
