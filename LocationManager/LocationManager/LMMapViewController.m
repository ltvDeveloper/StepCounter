//
//  LMMapViewController.m
//  LocationManager
//
//  Created by Developer on 6/26/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMMapViewController.h"

#import "LMSportTracker.h"

#import <CoreLocation/CoreLocation.h>

@interface LMMapViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) GMSCameraPosition *camera;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSPolyline *pathLine;

@property (assign, nonatomic) NSInteger lapsCount;

@end

@implementation LMMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:15.0];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:self.camera];
    self.pathLine = [GMSPolyline polylineWithPath:self.path];
    
    self.pathLine.strokeColor = [UIColor greenColor];
    self.pathLine.strokeWidth = 5.0;
    self.pathLine.map = self.mapView;
    self.mapView.delegate = self;
    
    self.view = self.mapView;

}

-(void)viewDidDisappear:(BOOL)animated {
    
    self.mapView = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
