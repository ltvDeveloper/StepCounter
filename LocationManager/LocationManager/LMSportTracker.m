//
//  LMSportTracker.m
//  LocationManager
//
//  Created by Developer on 6/25/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <GoogleMaps/GoogleMaps.h>

#import "LMSportTracker.h"
#import "LMAccelerometerFilter.h"


#define kBurnedCaloriesRunningMan 11.4
#define kBurnedCaloriesRunningWoman 9.3
#define kBurnedFatRunning 9


@interface LMSportTracker () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *oldLocation;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSInteger seconds;
@property (assign, nonatomic) NSInteger minutes;

@property (assign, nonatomic) NSTimeInterval activityInterval;

@end

@implementation LMSportTracker

@synthesize distance, time, steps, path, speed, currentLocation, originLocation, laps, agingFactor;

-(id)initTrackerWithAccuracy:(CLLocationAccuracy)accuracy {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
        
    laps = 0;
    
    self.seconds = 0;
    self.minutes = 0;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = accuracy;
    self.locationManager.delegate = self;
    
    self.oldLocation = nil;
    currentLocation = nil;
    originLocation = nil;
    self.startDate = nil;
    
    return self;
}

#pragma mark - Set Accuracy

-(void)setAccuracy:(CLLocationAccuracy)accuracy {
    
    self.locationManager.desiredAccuracy = accuracy;
}


#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.motionManager.showsDeviceMovementDisplay = YES;
    
    if (originLocation == nil) {
        originLocation = locations.lastObject;
    }
    
    if (self.startDate == nil) {
        self.startDate = self.currentLocation.timestamp;
    }
    
    if (path == nil) {
        path = [GMSMutablePath path];
    } else {
        self.oldLocation = currentLocation;
        currentLocation = locations.lastObject;
        [path addLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    }
    
    if (originLocation.coordinate.longitude == currentLocation.coordinate.longitude && originLocation.coordinate.latitude == currentLocation.coordinate.latitude) {
        ++laps;
    }

    distance += ABS([currentLocation distanceFromLocation:self.oldLocation]);
    if (self.currentLocation.speed != -1.0f) {
        speed = self.currentLocation.speed;
    }
    
    if (distance > 10.0f) {
        self.activityInterval = [currentLocation.timestamp timeIntervalSinceDate:self.startDate];
    }
    
    
}

#pragma mark - Background Mode

-(void)backgroundMode:(BOOL)on {
    
    if (on) {
        [self.locationManager stopUpdatingLocation];
    } else {
        [self.locationManager startUpdatingLocation];
    }
    
}

#pragma mark - Start, Stop and Reset Methods

-(void)startTracker {
    
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.accelerometerUpdateInterval = 0.4;
    
    if (![self.timer isValid]) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
    }
    
    [self.locationManager startUpdatingLocation];
    
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {

            float acc = sqrtf(accelerometerData.acceleration.x * accelerometerData.acceleration.x +
                              accelerometerData.acceleration.y * accelerometerData.acceleration.y +
                              accelerometerData.acceleration.z * accelerometerData.acceleration.z);
            
            if (acc > 1.15) {
                ++steps;
                [UIApplication sharedApplication].applicationIconBadgeNumber = steps;
            }
        }];
    }
}

-(void)stopTacker {
    
    [self.locationManager stopUpdatingLocation];
    [self.motionManager stopAccelerometerUpdates];
    
    [self.timer invalidate];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

-(void)resetTracker {
    
    steps = 0;
    laps = 0;
    self.seconds = 0;
    self.minutes = 0;
    
    distance = 0.0f;
    speed = 0.0f;
    
    self.oldLocation = nil;
    self.startDate = nil;
    path = nil;
    currentLocation = nil;
    originLocation = nil;
    
    time = @"0 : 00";
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - Timer

-(void)startTimer {

    ++self.seconds;
    NSInteger minutes = floor(self.seconds/60);
    
    if (minutes != 0) {
        NSInteger seconds = self.seconds%(60*minutes);
        if (seconds == 60) {
            seconds = 0;
        }
        if (seconds < 10) {
            time = [NSString stringWithFormat:@"%li : 0%@",(long)minutes, [NSString stringWithFormat:@"%li",(long)seconds]];
        } else
            time = [NSString stringWithFormat:@"%li : %li",(long)minutes, (long)seconds];
    } else {
        if (self.seconds < 10) {
            time = [NSString stringWithFormat:@"%li : 0%@",(long)minutes, [NSString stringWithFormat:@"%li",(long)self.seconds]];
        } else
            time = [NSString stringWithFormat:@"%li : %li",(long)minutes, (long)self.seconds];
    }
}

- (float)caloriesBurned:(float)weight gender:(NSString *)gender {
    
    float calories = 0.0;
    
    if (distance > 10.0f) {
        if ([gender isEqualToString:@"Male"]) {
            calories = ((kBurnedCaloriesRunningMan * weight)/3600)*self.activityInterval;
        }
        if ([gender isEqualToString:@"Female"]) {
            calories = ((kBurnedCaloriesRunningWoman * weight)/3600)*self.activityInterval;
        }
    }
    
    return calories;
}

- (float)fatBurned:(float)calories {
    
    float fat = calories/kBurnedFatRunning;
    
    return fat;
}

- (float)waterConsumption:(float)weight {
    
    float water = 0.0;
    
    if (distance > 10.0f) {
        water =  ((weight/100)/3600)*self.activityInterval*1000;
    }
    
    return water;
}

-(NSInteger)biologicalAge:(NSString *)gender age:(NSInteger)age weight:(float)weight growth:(float)growth waistline:(float)waistline hips:(float)hips {
    
    NSInteger bAge = 0;
    
    if ([gender isEqualToString:@"Male"]) {
        agingFactor = (waistline * weight)/(hips * ((growth/100) * (growth/100)) * (17.2 + 0.31 * ABS(age - 21) + 0.0012 * ABS((age-21) * (age - 21))));
        bAge = roundf(agingFactor * ABS(age - 21) + 21);
        
    }
    if ([gender isEqualToString:@"Female"]) {
        agingFactor = (waistline * weight)/(hips * ((growth/100) * (growth/100)) * (14.7 + 0.26 * ABS(age - 18) + 0.001 * ABS((age - 18) * (age - 18))));
        bAge = roundf(agingFactor * ABS(age - 18) + 18);
    }
    
    return bAge;
}

@end
