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



#define kUpdateFrequency	60.0

@interface LMSportTracker () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *oldLocation;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) LMAccelerometerFilter *filter;

@property (assign, nonatomic) NSInteger seconds;
@property (assign, nonatomic) NSInteger minutes;




@end

@implementation LMSportTracker

@synthesize distance, time, steps, path, speed, currentLocation, originLocation;

-(id)initTrackerWithAccuracy:(CLLocationAccuracy)accuracy {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.timer = nil;
    
    self.seconds = -1;
    self.minutes = 0.0;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = accuracy;
    self.locationManager.delegate = self;
    
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.accelerometerUpdateInterval = 0.3;
    
    self.oldLocation = nil;
    currentLocation = nil;
    originLocation = nil;
    self.startDate = nil;
    
    self.filter = [[LMAccelerometerFilter alloc]initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
    
    path = [GMSMutablePath path];
    
    return self;
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.motionManager.showsDeviceMovementDisplay = YES;
    
    if (originLocation == nil) {
        originLocation = locations.lastObject;
    }
    
    self.oldLocation = self.currentLocation;
    currentLocation = locations.lastObject;
    
    if (self.startDate == nil) {
        self.startDate = self.currentLocation.timestamp;
    }
    
    [path addLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    
    distance += [self.currentLocation distanceFromLocation:self.oldLocation];
    speed = self.currentLocation.speed;
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
    
    if (self.timer == nil) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
    }
    
    [self.locationManager startUpdatingLocation];
    
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
            [self.filter addAcceleration:accelerometerData];
            NSLog(@"X -- %f",self.filter.x);
             NSLog(@"Y -- %f",self.filter.y);
             NSLog(@"Z -- %f",self.filter.z);
            
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            float acc = sqrtf(accelerometerData.acceleration.x * accelerometerData.acceleration.x + accelerometerData.acceleration.y * accelerometerData.acceleration.y + accelerometerData.acceleration.z * accelerometerData.acceleration.z);
            if (acc > 1.1) {
                ++steps;
                [UIApplication sharedApplication].applicationIconBadgeNumber = steps;
            }
        }];
    }
}

-(void)stopTacker {
    
    [self.timer invalidate];
    [self.locationManager stopUpdatingLocation];
    [self.motionManager stopAccelerometerUpdates];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

-(void)resetTracker {
    
    steps = 0;
    self.seconds = 0;
    self.minutes = 0;
    
    distance = 0.0f;
    speed = 0.0f;
    
    currentLocation = nil;
    self.oldLocation = nil;
    self.startDate = nil;
    
    time = @"0 : 0";
    
    
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
        time = [NSString stringWithFormat:@"%i : %i",minutes, seconds];
    } else {
        time = [NSString stringWithFormat:@"%i : %i",minutes, self.seconds];
    }
}

@end
