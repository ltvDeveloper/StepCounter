//
//  LMSportTracker.m
//  LocationManager
//
//  Created by Developer on 6/25/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

#import "LMSportTracker.h"

@interface LMSportTracker () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *stepsLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

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

@implementation LMSportTracker

-(id)initTrackerWithDistanceLabel:(UILabel *)distanceLabel speedLabel:(UILabel *)speedLabel timeLabel:(UILabel *)timeLabel stepsLabel:(UILabel *)stepsLabel {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.seconds = -1;
    self.minutes = 0.0;
    self.timerOn = false;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.accelerometerUpdateInterval = 0.3;
    
    self.oldLocation = nil;
    self.currentLocation = nil;
    self.startDate = nil;
    
    self.distanceLabel = distanceLabel;
    self.speedLabel = speedLabel;
    self.timeLabel = timeLabel;
    self.stepsLabel = stepsLabel;
    
    return self;
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.motionManager.showsDeviceMovementDisplay = YES;
    
    self.oldLocation = self.currentLocation;
    self.currentLocation = locations.lastObject;
    
    if (self.startDate == nil) {
        self.startDate = self.currentLocation.timestamp;
    }
    
    self.distance += [self.currentLocation distanceFromLocation:self.oldLocation];
    
    [self printDistanceValue:self.distance];
    [self printSpeedValue:self.currentLocation.speed];
}

#pragma mark - Print Methods

- (void)printSpeedValue:(float)value {
    
    if (value == -1.0f) {
        self.speedLabel.text = @"0.0";
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%.1f",value*3.6];
    }
}

- (void)printDistanceValue:(float)value {
    
    if (value == -1.0f) {
        self.distanceLabel.text = @"0.0";
    } else {
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f",value/1000];
    }
}

#pragma mark - Start, Stop, Reset Methods

-(void)startTracker {
    
    if (!self.timerOn) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        self.timerOn = YES;
    }
    
    [self.locationManager startUpdatingLocation];
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            float acc = sqrtf(accelerometerData.acceleration.x * accelerometerData.acceleration.x + accelerometerData.acceleration.y * accelerometerData.acceleration.y + accelerometerData.acceleration.z * accelerometerData.acceleration.z);
            if (acc > 1.1) {
                ++self.stepsCount;
                self.stepsLabel.text = [NSString stringWithFormat:@"%i",self.stepsCount];
                [UIApplication sharedApplication].applicationIconBadgeNumber = self.stepsCount;
            }
        }];
    }
}

-(void)stopTacker {
    
    [self.timer invalidate];
    self.timerOn = false;
    [self.locationManager stopUpdatingLocation];
    [self.motionManager stopAccelerometerUpdates];
}

-(void)resetTracker {
    
    self.stepsCount = 0;
    self.seconds = 0;
    self.minutes = 0;
    
    self.distance = 0.0f;
    
    self.currentLocation = nil;
    self.oldLocation = nil;
    self.startDate = nil;
    
    self.distanceLabel.text = @"0.00";
    self.speedLabel.text = @"0.0";
    self.timeLabel.text = @"0 : 0";
    self.stepsLabel.text = @"0";
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - Timer

-(void)startTimer {
    
    ++self.seconds;
    int minutes = floor(self.seconds/60);
    
    if (minutes != 0) {
        int seconds = self.seconds%(60*minutes);
        if (seconds == 60) {
            seconds = 0;
        }
        self.timeLabel.text = [NSString stringWithFormat:@"%i : %i",minutes,seconds];
    } else {
        self.timeLabel.text = [NSString stringWithFormat:@"%i : %i",minutes,self.seconds];
    }
}


@end
