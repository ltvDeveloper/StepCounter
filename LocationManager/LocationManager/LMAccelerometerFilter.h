//
//  LMAccelerometerFilter.h
//  LocationManager
//
//  Created by Developer on 6/26/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface LMAccelerometerFilter : NSObject {
    
    CGFloat filterConstant;
}

- (id)initWithSampleRate:(CGFloat)rate cutoffFrequency:(CGFloat)freq;
- (void)addAcceleration:(CMAccelerometerData*)accel;

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;
@property (nonatomic, readonly) CGFloat z;

@property (nonatomic, getter=isAdaptive) BOOL adaptive;

@end
