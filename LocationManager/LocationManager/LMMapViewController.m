//
//  LMMapViewController.m
//  LocationManager
//
//  Created by Developer on 6/26/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMMapViewController.h"

#import "LMSportTracker.h"
#import "Session.h"
#import "LogPoint.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import <GoogleMaps/GoogleMaps.h>

@interface LMMapViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSMutablePath *sessionPath;
@property (strong, nonatomic) GMSMutablePath *drivingPath;

@property (strong, nonatomic) GMSPolyline *greenPathLine;
@property (strong, nonatomic) GMSPolyline *grayPathLine;

@property (strong, nonatomic) LMSportTracker *sportTracker;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSTimer *pathUpdateTimer;

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
    
    if (![self.pathUpdateTimer isValid]) {
        self.pathUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onPathUpdateTimer) userInfo:nil repeats:YES];
    }
    
    GMSCameraPosition *camera;
    
    camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:15.0];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    if (self.fetchedResultsController.fetchedObjects.count != 0) {
        Session *session = [[self.fetchedResultsController fetchedObjects]firstObject];
        [self drawPathWithData:session.sessionPath];
        [self drawDrivingPathWithData:session.sessionPath];
        [self drawLogPoints:[session.logPoint allObjects]];
    }
    
    self.mapView.delegate = self;
    self.view = self.mapView;
    
}

#pragma mark - private
#pragma mark - Draw

- (void)onPathUpdateTimer {
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:[NSEntityDescription entityForName:@"Session" inManagedObjectContext:context]];
    NSArray *res = [context executeFetchRequest:request error:nil];
    Session *ss = [res lastObject];
    
    [self drawPathWithData:ss.sessionPath];
    [self drawDrivingPathWithData:ss.drivingPath];
    
}

- (void)drawPathWithData:(NSData *)data  {
    
    self.sessionPath = [[GMSMutablePath alloc]init];
    NSMutableArray *pathArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray *longitudes = [[NSMutableArray alloc]init];
    NSMutableArray *latitudes = [[NSMutableArray alloc]init];
        
    for (NSInteger i = 0; i < [pathArray count]; ++i) {
        if (i%2 == 0) {
            [longitudes addObject:pathArray[i]];
        } else {
            [latitudes addObject:pathArray[i]];
        }
    }
        
    for (NSInteger j = 0; j < longitudes.count; ++j) {
        
        NSNumber *latitude = latitudes[j];
        NSNumber *longitude = longitudes[j];
            
        [self.sessionPath addLatitude:[latitude floatValue] longitude:[longitude floatValue]];
    }
        
    self.greenPathLine = [GMSPolyline polylineWithPath:self.sessionPath];
    self.greenPathLine.strokeColor = [UIColor greenColor];
    self.greenPathLine.strokeWidth = 3.0;
    self.greenPathLine.map = self.mapView;

}

- (void)drawDrivingPathWithData:(NSData *)data {
    
    for (NSMutableArray *gArray in [NSKeyedUnarchiver unarchiveObjectWithData:data]) {
        
        self.drivingPath = [[GMSMutablePath alloc]init];
        NSMutableArray *longitudes = [[NSMutableArray alloc]init];
        NSMutableArray *latitudes = [[NSMutableArray alloc]init];
        
        for (NSInteger i = 0; i < [gArray[0] count]; ++i) {
            if (i%2 == 0) {
                [longitudes addObject:gArray[0][i]];
            } else {
                [latitudes addObject:gArray[0][i]];
            }
        }
        
        for (NSInteger j = 0; j < longitudes.count; ++j) {
            
            NSNumber *latitude = latitudes[j];
            NSNumber *longitude = longitudes[j];
            
            [self.drivingPath addLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        }
        
        GMSPolyline *grayPathLine = [GMSPolyline polylineWithPath:self.drivingPath];
        
        grayPathLine = [GMSPolyline polylineWithPath:self.drivingPath];
        grayPathLine.strokeColor = [UIColor grayColor];
        grayPathLine.strokeWidth = 3.2;
        grayPathLine.map = self.mapView;
        
    }
}

- (void)drawLogPoints:(NSArray *)logPoints {
    
    for (LogPoint *logPoint in logPoints) {
        GMSMarker *newMarker = [[GMSMarker alloc]init];
        newMarker.title = [NSString stringWithFormat:@"Average speed: %.1f",[logPoint.speed floatValue]];
        newMarker.snippet = [NSString stringWithFormat:@"Time: %@",logPoint.time];
        CLLocationCoordinate2D newMarkerPosition = CLLocationCoordinate2DMake([logPoint.latitude floatValue], [logPoint.longitude floatValue]);
        newMarker.position = newMarkerPosition;
        newMarker.map = self.mapView;
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    
    self.mapView = nil;
    [self.pathUpdateTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:40];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
    
	if (![self.fetchedResultsController performFetch:&error]) {
	    abort();
	}
    
    return _fetchedResultsController;
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
