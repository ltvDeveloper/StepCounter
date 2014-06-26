//
//  LMMapViewController.h
//  LocationManager
//
//  Created by Developer on 6/26/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface LMMapViewController : UIViewController

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *originLocation;

@property (strong, nonatomic) GMSMutablePath *path;

-(NSInteger)lapCount;

@end
