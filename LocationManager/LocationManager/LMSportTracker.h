//
//  LMSportTracker.h
//  LocationManager
//
//  Created by Developer on 6/25/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef NS_ENUM(NSUInteger, Gender)
{
    Male = 0,
    Female = 1
};

typedef NS_ENUM(NSUInteger, Activity)
{
    Walking = 0,
    Running = 1,
    Cycling = 2
};

@interface LMSportTracker : NSObject

@property (nonatomic, readonly) NSInteger steps;
@property (nonatomic, readonly) NSInteger laps;
@property (nonatomic, readonly) NSInteger seconds;

@property (nonatomic, readonly) CGFloat speed;
@property (nonatomic, readonly) CGFloat agingFactor;

@property (nonatomic, readonly) CGFloat distance;
@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, readonly) CLLocation *originLocation;

//lifecycle
- (id)initTrackerWithAccuracy:(CLLocationAccuracy)accuracy;
- (void)startTracker;
- (void)stopTacker;
- (void)resetTracker;

//Public methods
- (void)enterBackground;
- (void)exitBackground;
- (void)startMeasuringHeartRate;
- (CGFloat)caloriesBurned:(CGFloat)weight gender:(Gender)gender activityType:(Activity)activity;
- (CGFloat)waterConsumption:(CGFloat)weight;
- (CGFloat)fatBurned:(CGFloat)calories;
- (NSInteger)biologicalAge:(Gender)gender age:(NSInteger)age weight:(CGFloat)weight height:(CGFloat)height waistline:(CGFloat)waistline hips:(CGFloat)hips;

//accessors
- (void)setAccuracy:(CLLocationAccuracy)accuracy;

@end
