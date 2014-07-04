//
//  LMSportTracker.h
//  LocationManager
//
//  Created by Developer on 6/25/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LMSportTracker : NSObject


@property (nonatomic, readonly) GMSMutablePath *path;

@property (nonatomic, readonly) NSInteger steps;
@property (nonatomic, readonly) NSInteger laps;
@property (nonatomic, readonly) NSString *time;

@property (nonatomic, readonly) float speed;
@property (nonatomic, readonly) float agingFactor;

@property (nonatomic, readonly) CLLocationDistance distance;
@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, readonly) CLLocation *originLocation;


- (id)initTrackerWithAccuracy:(CLLocationAccuracy)accuracy;

- (void)backgroundMode:(BOOL)on;
- (void)startTracker;
- (void)stopTacker;
- (void)resetTracker;
- (void)setAccuracy:(CLLocationAccuracy)accuracy;

- (float)caloriesBurned:(float)weight gender:(NSString *)gender;
- (float)waterConsumption:(float)weight;
- (float)fatBurned:(float)calories;
- (NSInteger)biologicalAge:(NSString *)gender age:(NSInteger)age weight:(float)weight growth:(float)growth waistline:(float)waistline hips:(float)hips;

@end
