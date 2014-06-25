//
//  LMViewController.m
//  LocationManager
//
//  Created by Developer on 6/18/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMViewController.h"
#import "LMSportTracker.h"

@interface LMViewController ()<CLLocationManagerDelegate>

@property (strong, nonatomic) LMSportTracker *sportTracker;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *oldLocation;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (        nonatomic) CLLocationDistance distance;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) int stepsCount;
@property (assign, nonatomic) int seconds;
@property (assign, nonatomic) int minutes;
@property (assign, nonatomic) BOOL timerOn;

@end

@implementation LMViewController

- (void)viewDidLoad
{    
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    self.sportTracker = [[LMSportTracker alloc]initTrackerWithDistanceLabel:self.distanceLabel speedLabel:self.speedLabel timeLabel:self.timeLabel stepsLabel:self.accCountLabel];
    
//    self.seconds = -1;
//    self.minutes = 0.0;
//    self.timerOn = false;
//    
//    self.motionManager = [[CMMotionManager alloc]init];
//    self.motionManager.accelerometerUpdateInterval = 0.3;
//
//    self.locationManager = [[CLLocationManager alloc]init];
//    
//    self.oldLocation = nil;
//    self.currentLocation = nil;
//    self.startDate = nil;
//    
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.delegate = self;
//    self.resetButton.hidden = YES;
    
    [super viewDidLoad];
}

//- (void)startTimer {
//    
//    ++self.seconds;
//    int minutes = floor(self.seconds/60);
//    
//    if (minutes != 0) {
//        int seconds = self.seconds%(60*minutes);
//        if (seconds == 60) {
//            seconds = 0;
//        }
//        self.timeLabel.text = [NSString stringWithFormat:@"%i : %i",minutes,seconds];
//    } else {
//        self.timeLabel.text = [NSString stringWithFormat:@"%i : %i",minutes,self.seconds];
//    }
//    
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Location Manager

//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    
//    self.motionManager.showsDeviceMovementDisplay = YES;
//    
//    self.oldLocation = self.currentLocation;
//    self.currentLocation = locations.lastObject;
//    
//    if (self.startDate == nil) {
//        self.startDate = self.currentLocation.timestamp;
//    }
//    
//    self.distance += [self.currentLocation distanceFromLocation:self.oldLocation];
//   
//    [self printSpeedValue:self.currentLocation.speed];
//    [self printDistanceValue:self.distance];
//    
//}

#pragma mark - Print Values

//- (void)printSpeedValue:(float)value {
//    
//    if (value == -1.0f) {
//        self.speedLabel.text = @"0.0";
//    } else {
//        self.speedLabel.text = [NSString stringWithFormat:@"%.1f",value*3.6];
//    }
//}
//
//- (void)printDistanceValue:(float)value {
//    
//    if (value == -1.0f || value == -0.0f) {
//        self.distanceLabel.text = @"0.00";
//    } else {
//        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f",value/1000];
//    }
//}

#pragma mark - On Buttons

- (IBAction)onResetButton:(id)sender {
    
//    self.stepsCount = 0;
//    self.seconds = 0;
//    self.minutes = 0;
//    
//    self.distance = 0.0f;
//    
//    self.currentLocation = nil;
//    self.oldLocation = nil;
//    self.startDate = nil;
//    
//    self.accCountLabel.text = @"0";
//    self.distanceLabel.text= @"0.00";
//    self.speedLabel.text = @"0.0";
//    self.timeLabel.text = @"0 : 0";
//    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self.sportTracker resetTracker];
}

- (IBAction)onStartButton:(id)sender {
    
//    if (!self.timerOn) {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
//        [self.timer fire];
//        self.timerOn = YES;
//    }
//    
//    [self.locationManager startUpdatingLocation];
//    if ([self.motionManager isAccelerometerAvailable]) {
//        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
//            
//            float acc = sqrtf(accelerometerData.acceleration.x * accelerometerData.acceleration.x +
//                              accelerometerData.acceleration.y * accelerometerData.acceleration.y +
//                              accelerometerData.acceleration.z * accelerometerData.acceleration.z);
//
//            if (acc > 1.1) {
//                NSLog(@"%f",acc);
//                ++self.stepsCount;
//                self.accCountLabel.text = [NSString stringWithFormat:@"%i",self.stepsCount];
//                [UIApplication sharedApplication].applicationIconBadgeNumber = self.stepsCount;
//            }
//
//        }];
//    }
    
    [self.sportTracker startTracker];
}

- (IBAction)onStopButton:(id)sender {
    
//    [self.timer invalidate];
//    self.timerOn = false;
//    [self.locationManager stopUpdatingLocation];
//    [self.motionManager stopAccelerometerUpdates];
    
    [self.sportTracker stopTacker];
}

@end