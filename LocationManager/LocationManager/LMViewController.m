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
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocation *oldLocation;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (        nonatomic) CLLocationDistance distance;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@property (strong, nonatomic) NSDate *startDate;

@property (assign, nonatomic) int stepsCount;
@property (assign, nonatomic) int seconds;
@property (assign, nonatomic) int minutes;
@property (assign, nonatomic) int hours;
@end

@implementation LMViewController

- (void)viewDidLoad
{
    self.seconds = -1;
    self.minutes = 0.0;
    self.hours = 0.0;
    
    if ([CMMotionActivityManager isActivityAvailable]) {
        self.motionActivityManager = [[CMMotionActivityManager alloc]init];
        [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
        }];
    }

    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.accelerometerUpdateInterval = 0.3;

    self.locationManager = [[CLLocationManager alloc]init];
    self.location = [[CLLocation alloc]init];
    
    self.oldLocation = nil;
    self.currentLocation = nil;
    self.startDate = nil;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    self.resetButton.hidden = YES;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Location Manager

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.motionManager.showsDeviceMovementDisplay = YES;
    
    self.oldLocation = self.currentLocation;
    self.currentLocation = locations.lastObject;
    
    if (self.startDate == nil) {
        self.startDate = self.currentLocation.timestamp;
         NSLog(@"%@",self.startDate);
    }
    
    self.distance += [self.currentLocation distanceFromLocation:self.oldLocation];
   
    [self printSpeedValue:self.currentLocation.speed];
    [self printDistanceValue:self.distance];
    
    [self printTimeValue:[self.currentLocation.timestamp timeIntervalSinceDate:self.startDate]];
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Print Values

- (void)printTimeValue:(NSTimeInterval)value {
    
    int minutes = floor(value/60);
    
    if (minutes != 0) {
        int intValue = roundf(value);
        int seconds = intValue%(60*minutes);
        if (seconds == 60) {
            seconds = 0;
        }
        self.timeLabel.text = [NSString stringWithFormat:@"%i : %i",minutes,seconds];
    } else {
         self.timeLabel.text = [NSString stringWithFormat:@"%i : %.0f",minutes,value];
    }
}

- (void)printSpeedValue:(float)value {
    
    if (value == -1.0f) {
        self.speedLabel.text = @"0.0";
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%.1f",value];
    }
}

- (void)printDistanceValue:(float)value {
    
    if (value == -1.0f) {
        self.distanceLabel.text = @"0.0";
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1f",value];
    }
}

#pragma mark - On Buttons

- (IBAction)onResetButton:(id)sender {
    
    self.stepsCount = 0;
    self.seconds = 0;
    self.minutes = 0;
    
    self.distance = 0.0f;
    
    self.currentLocation = nil;
    self.oldLocation = nil;
    self.startDate = nil;
    
    self.stepsLabel.text = @"0";
    self.distanceLabel.text= @"0.0";
    self.speedLabel.text = @"0.0";
    self.timeLabel.text = @"0 : 0";
}

- (IBAction)onStartButton:(id)sender {
    
    [self.locationManager startUpdatingLocation];
    if ([self.motionManager isAccelerometerAvailable]) {
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
            BOOL step = NO;
            BOOL jump = NO;
            
            if (ABS(accelerometerData.acceleration.x) > 1) {
                step = YES;
                self.label.text = @"Walk";
            }
            if (ABS(accelerometerData.acceleration.y) > 1) {
                step = YES;
                self.label.text = @"Walk";
            }
            if (ABS(accelerometerData.acceleration.z) > 1.2) {
                step = YES;
                self.label.text = @"Walk";
            }
            if (ABS(accelerometerData.acceleration.z) > 1.7) {
                jump = YES;
                self.label.text = @"Run";
            }
            if (ABS(accelerometerData.acceleration.x) > 1.7) {
                jump = YES;
                self.label.text = @"Run";
            }
            
            if (step) {
                self.motionManager.accelerometerUpdateInterval = 0.3;
                ++ self.stepsCount;
                self.stepsLabel.text = [NSString stringWithFormat:@"%i",self.stepsCount];
            }
            if (jump) {
                self.motionManager.accelerometerUpdateInterval = 0.2;
                ++self.stepsCount;
                self.stepsLabel.text = [NSString stringWithFormat:@"%i",self.stepsCount];
            }

            [UIApplication sharedApplication].applicationIconBadgeNumber = self.stepsCount;
            
        }];
    }

}

- (IBAction)onStopButton:(id)sender {
    
    [self.locationManager stopUpdatingLocation];
    [self.motionManager stopAccelerometerUpdates];
}
@end
