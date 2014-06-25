//
//  LMSportTracker.h
//  LocationManager
//
//  Created by Developer on 6/25/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMSportTracker : NSObject

- (id)initTrackerWithDistanceLabel:(UILabel *)distanceLabel speedLabel:(UILabel *)speedLabel timeLabel:(UILabel *)timeLabel stepsLabel:(UILabel *)stepsLabel;
- (void)startTracker;
- (void)stopTacker;
- (void)resetTracker;
@end
