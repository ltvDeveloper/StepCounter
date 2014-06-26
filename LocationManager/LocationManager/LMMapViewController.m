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
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view

    self.camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:17.0];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:self.camera];
    self.pathLine = [GMSPolyline polylineWithPath:self.path];
    
    self.pathLine.strokeColor = [UIColor greenColor];
    self.pathLine.strokeWidth = 5.0;
    self.pathLine.map = self.mapView;
    self.mapView.delegate = self;
    
    self.view = self.mapView;
    
}

-(NSInteger )lapCount {
    if (self.originLocation == self.currentLocation) {
        ++self.lapsCount;
    }
    
    return self.lapsCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
