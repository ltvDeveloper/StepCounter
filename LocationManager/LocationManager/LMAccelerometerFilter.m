//
//  LMAccelerometerFilter.m
//  LocationManager
//
//  Created by Developer on 6/26/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMAccelerometerFilter.h"

@implementation LMAccelerometerFilter

@synthesize x, y, z, adaptive;

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0


double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}


- (id)initWithSampleRate:(CGFloat)rate cutoffFrequency:(CGFloat)freq
{
	self = [super init];
	if(self != nil)
	{
		CGFloat dt = 1.0 / rate;
		CGFloat RC = 1.0 / freq;
		filterConstant = dt / (dt + RC);
	}
	return self;
}

- (void)addAcceleration:(CMAccelerometerData *)accel
{
	CGFloat alpha = filterConstant;
	
	if(adaptive)
	{
		CGFloat d = Clamp(fabs(Norm(x, y, z) - Norm(accel.acceleration.x, accel.acceleration.y, accel.acceleration.z)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
	}
	
	x = accel.acceleration.x * alpha + x * (1.0 - alpha);
	y = accel.acceleration.y * alpha + y * (1.0 - alpha);
	z = accel.acceleration.z * alpha + z * (1.0 - alpha);
}

@end
