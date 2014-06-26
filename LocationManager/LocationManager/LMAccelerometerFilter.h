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
    
    float filterConstant;
  //  UIAccelerationValue lastX, lastY, lastZ;
}

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;
- (void)addAcceleration:(CMAccelerometerData*)accel;

@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) float z;

@property (nonatomic, getter=isAdaptive) BOOL adaptive;

@end
