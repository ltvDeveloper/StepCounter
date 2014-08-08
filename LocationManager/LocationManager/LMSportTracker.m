

#import <CoreMotion/CoreMotion.h>
#import <CoreData/CoreData.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVFoundation.h>

#import "LMSportTracker.h"
#import "Session.h"
#import "LogPoint.h"
#import "LMAccelerometerFilter.h"

#define kBurnedFatRunning 9

#define kBurnedCaloriesWalkingMale 0.4f
#define kBurnedCaloriesCyclingMale 0.5f
#define kBurnedcaloriesRunningMale 1.f

#define kBurnedCaloriesWalkingFemale 0.3f
#define kBurnedCaloriesCyclingFemale 0.4f
#define kBurnedcaloriesRunningFemale 0.8f


@interface LMSportTracker () <CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) Session *sportSession;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *oldLocation;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@property (strong, nonatomic) NSDate *startDate;

@property (strong, nonatomic) NSTimer *sessionTimer;
@property (strong, nonatomic) NSTimer *heartTimer;
@property (strong, nonatomic) NSTimer *sprintTimer;

@property (strong, nonatomic) NSMutableArray *speedArray;

@property (assign, nonatomic) NSInteger heartRate;
@property (assign, nonatomic) NSInteger sprintTime;

@property (assign, nonatomic) CGFloat burnedCalories;
@property (assign, nonatomic) CGFloat water;
@property (assign, nonatomic) CGFloat lastSpeed;
@property (assign, nonatomic) CGFloat sumSprintSpeed;
@property (assign, nonatomic) CGFloat deltaValue;
@property (assign, nonatomic) CGFloat lastDeltaValue;
@property (assign, nonatomic) CGFloat lastValue;

@property (assign, nonatomic) BOOL isSprint;
@property (assign, nonatomic) BOOL isStepsBased;

@property (assign, nonatomic) NSTimeInterval activityInterval;

@property (assign, nonatomic) Activity activity;

@property (strong, nonatomic) GMSMutablePath *grayPath;
@property (strong, nonatomic) GMSPolyline *grayPathLine;
@property (strong, nonatomic) NSMutableArray *grayPathArray;
@property (assign, nonatomic) BOOL isGray;

@end

@implementation LMSportTracker
{
    AVCaptureSession *session;
}

@synthesize distance, seconds, steps, speed, currentLocation, originLocation, laps, agingFactor;

#pragma mark - public

#pragma mark - Initialize Tracker

- (id)initTrackerWithAccuracy:(CLLocationAccuracy)accuracy {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }

    seconds = 0;
    self.lastSpeed = 0.f;
    self.deltaValue = 0.f;
    self.lastDeltaValue = 0.f;
    self.lastValue = 0.f;
    
    self.oldLocation = nil;
    currentLocation = nil;
    originLocation = nil;
    self.startDate = nil;
    
    self.grayPath = [[GMSMutablePath alloc]init];
    self.grayPathArray = [[NSMutableArray alloc]init];
    
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = accuracy;
        self.locationManager.delegate = self;
    }
    
    self.speedArray = [[NSMutableArray alloc]init];
    
    //Creation or recovery of a new session
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        self.sportSession = [self newSession];
    } else {
        self.sportSession = [self recoverSession];
    }
    
    return self;
}

#pragma mark - Accessor

- (void)setAccuracy:(CLLocationAccuracy)accuracy {
    
    self.locationManager.desiredAccuracy = accuracy;
}

#pragma mark - Background

- (void)enterBackground {
    
    if ([CLLocationManager deferredLocationUpdatesAvailable]) {
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
    }
}

- (void)exitBackground {
    
    
    if ([CLLocationManager deferredLocationUpdatesAvailable]) {
        [self.locationManager disallowDeferredLocationUpdates];
    }
}

#pragma mark - Start, Stop and Reset Tracker

- (void)startTrackerWithActivityType:(Activity)activity {
    
    self.activity = activity;
    UIAlertView *activityAlert = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Choose your activity!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    switch (activity) {
        case Walking:
            self.isStepsBased = YES;
            [self startMotion];
            break;
        case Running:
            self.isStepsBased = YES;
            [self startMotion];
            break;
        case Cycling:
            self.isStepsBased = NO;
            [self startMotion];
            break;
        default:
            [activityAlert show];
            break;
    }
    
    
    
    }

- (void)stopTacker {
    
    [self closeSession];
    [self stopMotion];
    self.oldLocation = nil;
    currentLocation = nil;
    
}

- (void)resetTracker {
    
    [self cleanSession];
    
}

#pragma mark - Energy Consumption

- (CGFloat)caloriesBurned:(CGFloat)weight gender:(Gender)gender {
    
    switch (self.activity) {
        
        case Walking:
            switch (gender) {
                case Male:
                    if (speed > 0.f) {
                        self.burnedCalories += (((speed + kBurnedCaloriesWalkingMale) * weight)/3600.f) * 2.f;
                    }
                    break;
                case Female:
                    if (speed > 0.f) {
                        self.burnedCalories += (((speed + kBurnedCaloriesWalkingFemale) * weight)/3600.f) * 2.f;
                    }
                    break;
            }
            break;
            
        case Running:
            switch (gender) {
                case Male:
                    if (speed > 0.f) {
                        self.burnedCalories += (((speed + kBurnedcaloriesRunningMale) * weight)/3600.f) * 2.f;
                    }
                    break;
                case Female:
                    if (speed > 0.f) {
                        self.burnedCalories += (((speed + kBurnedcaloriesRunningFemale) * weight)/3600.f) * 2.f;
                    }
            }
            break;
            
        case Cycling:
            switch (gender) {
                case Male:
                    if (speed > 0.f) {
                        self.burnedCalories += (((speed + kBurnedCaloriesCyclingMale) * weight)/3600.f) * 2.f;
                    }
                    break;
                case Female:
                    if (speed > 0.f) {
                        self.burnedCalories += (((speed + kBurnedCaloriesCyclingFemale) * weight)/3600.f) * 2.f;
                    }
                    break;
            }
            break;

    }
    return self.burnedCalories;
    
}

- (CGFloat)fatBurned:(CGFloat)calories {
    
    if (speed != 0.f) {
        
        CGFloat fat = calories/kBurnedFatRunning;
        return fat;
    }
    
    return 0;
    
}

- (CGFloat)waterConsumption:(CGFloat)weight {
    
    if (speed != 0.f) {
        self.water +=  ((weight/100.f)/3600.f) * 1000.f;
        
        return self.water;
    }
    
    return 0;
}

#pragma mark - Biological Age & Aging Factor

- (NSInteger)biologicalAge:(Gender)gender age:(NSInteger)age weight:(CGFloat)weight height:(CGFloat)height waistline:(CGFloat)waistline hips:(CGFloat)hips {
    
    NSInteger bAge = 0;
    
    switch (gender) {
        case Male:
            
            agingFactor = (waistline * weight)/(hips * ((height/100.f) * (height/100.f)) * (17.2f + 0.31f * ABS(age - 21) + 0.0012f * ABS((age-21) * (age - 21))));
            bAge = roundf(agingFactor * ABS(age - 21) + 21);
            break;
        case Female:
            
            agingFactor = (waistline * weight)/(hips * ((height/100.f) * (height/100.f)) * (14.7f + 0.26f * ABS(age - 18) + 0.001f * ABS((age - 18) * (age - 18))));
            bAge = roundf(agingFactor * ABS(age - 18) + 18);
            break;
    }
    
    return bAge;
}

#pragma mark - Measuring Heart Rate

- (void)startMeasuringHeartRate {
    
    if (![self.heartTimer isValid]) {
        self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(onHeartTimer) userInfo:nil repeats:NO];
        [self measureHeartRate];
    }

}

#pragma mark - private

#pragma mark - Convert RGB color model to HSV

void RGBtoHSV( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v ) {
    
    CGFloat min, max, delta;
    min = MIN( r, MIN(g, b ));
    max = MAX( r, MAX(g, b ));
    *v = max;
    delta = max - min;
    
    if (max == min) {
        *h = 0;
    } else if (max == r && g>= b) {
        *h = 60 * (g-b)/delta + 0;
    } else if (max == r && g < b) {
        *h = 60 * (g - b)/delta + 360;
    } else if (max == g) {
        *h = 60 * (b - r)/delta +120;
    } else if (max == b) {
        *h = 60 * (r - g) + 240;
    }
    
    if (max == 0) {
        *s = 0;
    } else {
        *s = 1 - min/max;
    }
    
}

#pragma mark - Motion

- (void)startMotion {
    
    self.sportSession.startDate = [NSDate date];
    self.motionManager = [[CMMotionManager alloc]init];
    self.motionManager.accelerometerUpdateInterval = 0.4;
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    [self.managedObjectContext save:nil];
    [self.locationManager startUpdatingLocation];
    
    if (![self.sessionTimer isValid]) {
        
        self.sessionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    }
    
    if (self.isStepsBased) {
        if ([self.motionManager isAccelerometerAvailable]) {
            [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                [self acceleration:accelerometerData];
                
            }];
        }
    }
    
}

- (void)acceleration:(CMAccelerometerData *)accelerometerData {
    
    //Calculating motion vector, if vector's length > 1.15f the user stepped
    
    CGFloat squaredAccelerometerData = sqrtf(accelerometerData.acceleration.x * accelerometerData.acceleration.x + accelerometerData.acceleration.y * accelerometerData.acceleration.y + accelerometerData.acceleration.z * accelerometerData.acceleration.z);
    if (squaredAccelerometerData > 1.15f) {
        ++steps;
        [UIApplication sharedApplication].applicationIconBadgeNumber = steps;
    }
}

- (void)stopMotion {
    
    [self.locationManager stopUpdatingLocation];
    [self.motionManager stopAccelerometerUpdates];
    
    [self.sessionTimer invalidate];
    [self.sprintTimer invalidate];
    
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}

- (CGFloat)averageSpeed {
    
    //Calculating average speed by creating speed array and dividing it into count of array elements
    
    CGFloat sumSpeed = 0.f;
    CGFloat avSpeed = 0.f;
    
    if (self.currentLocation.speed > 0.f) {
        speed = self.currentLocation.speed;
        
        [self.speedArray addObject:@(speed * 3.6f)];
        
        if ([self.speedArray count] > 0) {
            for (NSInteger i = 0 ; i <= [self.speedArray count]-1; ++i) {
                sumSpeed += [self.speedArray[i] floatValue];
            }
            avSpeed = sumSpeed/[self.speedArray count];
        }
        
}
    
    return avSpeed;
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.motionManager.showsDeviceMovementDisplay = YES;
    
    if (originLocation == nil) {
        originLocation = locations.lastObject;
    }
    
    if (self.startDate == nil) {
        self.startDate = self.currentLocation.timestamp;
    }
    
    currentLocation = locations.lastObject;
    speed = currentLocation.speed;
    
    if (speed * 3.6f < 13.f) {
       
        distance += ABS([currentLocation distanceFromLocation:self.oldLocation]);
        self.isGray = NO;
        
    } else self.isGray = YES;
    
    
    if (self.sportSession) {
        
        //Creating and archiving path from NSMutableArray to NSData
        NSMutableArray *greenPathArray = [[NSMutableArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.sportSession.greenPath]];
        [greenPathArray addObjectsFromArray:@[@(currentLocation.coordinate.longitude),@(currentLocation.coordinate.latitude)]];
        NSData *greenPathData = [NSKeyedArchiver archivedDataWithRootObject:greenPathArray];
        
        //Save session's data to Core Data
        self.sportSession.kilometers = @(distance/1000.f);
        self.sportSession.calories = @(self.burnedCalories);
        self.sportSession.speed = @([self averageSpeed]);
        self.sportSession.time = @(seconds);
        self.sportSession.greenPath = greenPathData;
        self.sportSession.activityInterval = @(self.activityInterval);
        
        switch (self.activity) {
            case Walking:
                self.sportSession.activity = @"Walking";
                break;
            case Running:
                self.sportSession.activity = @"Runing";
                break;
            case Cycling:
                self.sportSession.activity = @"Cycling";
                break;
        }
        
        [self.managedObjectContext save:nil];
    }

    
    if (self.isGray) {
        
        [self.grayPathArray addObjectsFromArray:@[@(currentLocation.coordinate.longitude),@(currentLocation.coordinate.latitude)]];
        
    } else if (self.grayPathArray.count != 0) {
        
        NSMutableArray *grayArray = [[NSMutableArray alloc]initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:self.sportSession.grayPath]];
        [grayArray addObject:@[self.grayPathArray]];
        
        self.sportSession.grayPath = [NSKeyedArchiver archivedDataWithRootObject:grayArray];
        [self.managedObjectContext save:nil];
        
        [self.grayPathArray removeAllObjects];
    }
    
    if (distance > 100.f) {
        if (originLocation.coordinate.longitude == currentLocation.coordinate.longitude && originLocation.coordinate.latitude == currentLocation.coordinate.latitude) {
            ++laps;
        }
    }
    
    if (speed > 0.f) {
        [self handlingSprint];
    }
    
    self.oldLocation = currentLocation;
    
}

#pragma mark - Handling Sprint

- (void)onSprintTimer {
    
    ++self.sprintTime;
    self.sumSprintSpeed += speed * 3.6f;
}

- (void)handlingSprint {
    
    static CGFloat sprintSpeed = 0.f;
    
    // If the current speed is greater than previous, then sprintTimer is firing
    if (![self.sprintTimer isValid] && self.seconds > 5) {
        if (speed * 3.6f - self.lastSpeed * 3.6f > 3.f) {
            self.sprintTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(onSprintTimer) userInfo:nil repeats:YES];
            self.isSprint = YES;
            sprintSpeed = speed * 3.6f;
        }
    }
    
    // If the current speed is less than previous, then sprintTimer is invalidate
    if (speed * 3.6f < sprintSpeed && self.isSprint && self.sprintTime != 0) {
        [self.sprintTimer invalidate];
        CGFloat avSpeed = 0.f;
        avSpeed = self.sumSprintSpeed / self.sprintTime;
        
        //Creating a log point, and save it to the Core Data
        
        LogPoint *newLogPoint = [NSEntityDescription insertNewObjectForEntityForName:@"LogPoint" inManagedObjectContext:self.managedObjectContext];
        newLogPoint.speed = @(avSpeed);
        newLogPoint.time = @(self.sprintTime);
        newLogPoint.latitude = @(currentLocation.coordinate.latitude);
        newLogPoint.longitude = @(currentLocation.coordinate.longitude);
        [self.sportSession addLogPointObject:newLogPoint];
        [self.managedObjectContext save:nil];
        
        self.sumSprintSpeed = 0.f;
        self.sprintTime = 0;
        sprintSpeed = 0.f;
        self.isSprint = NO;
    }
    
    self.lastSpeed = speed;
}

#pragma mark - Sport Session

- (void)closeSession {
    
    self.sportSession.endDate = [NSDate date];
    [self.managedObjectContext save:nil];
    [self.sessionTimer invalidate];
}

- (void)cleanSession {
    
    if (self.sportSession != nil) {
        self.sportSession.greenPath = nil;
        self.sportSession.grayPath = nil;
        
        // Deleting all log points in current session
        
        for (LogPoint *logPoint in self.sportSession.logPoint) {
            [self.managedObjectContext deleteObject:logPoint];
        }
        
        [self.managedObjectContext save:nil];
        
    }
    
    steps = 0;
    laps = 0;
    seconds = 0;
    self.activityInterval = 0;
    self.sprintTime = 0;
    
    distance = 0.f;
    speed = 0.f;
    self.lastSpeed = 0.f;
    self.burnedCalories = 0.f;
    
    self.oldLocation = nil;
    self.startDate = nil;
    currentLocation = nil;
    originLocation = nil;
    
    self.heartRate = 0;
    
    [self.sprintTimer invalidate];
    [self.grayPathArray removeAllObjects];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (Session *)recoverSession {
    
    Session *recoveredSession = [self.fetchedResultsController.fetchedObjects firstObject];
    
    if (recoveredSession.endDate != nil) {
        recoveredSession = [self.fetchedResultsController.fetchedObjects lastObject];
    }
    
    // If last session have endDate, then creating new session
    if (recoveredSession.endDate != nil) {
        recoveredSession = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
        [self.managedObjectContext save:nil];
        
    } else { // If last session haven't endDate, then use last session
        distance += [recoveredSession.kilometers floatValue]*1000.f;
        seconds += [recoveredSession.time floatValue];
        self.burnedCalories = [recoveredSession.calories floatValue];
        self.activityInterval = [recoveredSession.activityInterval integerValue];
        
    }
    
    return recoveredSession;
}

- (Session *)newSession {
    
    Session *newSession = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:self.managedObjectContext];
    [self.managedObjectContext save:nil];
    
    return newSession;
}

#pragma mark - Calculate Time

- (void)onTimer {
    
    ++seconds;
    
    if (speed != 0.f) {
        ++self.activityInterval;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    //Measuring heart rate using camera
    
    CVImageBufferRef cvImgRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(cvImgRef, 0);
    
    NSInteger width = CVPixelBufferGetWidth(cvImgRef);
    NSInteger height = CVPixelBufferGetHeight(cvImgRef);
    
    uint8_t *buf=(uint8_t *) CVPixelBufferGetBaseAddress(cvImgRef);
    size_t bprow=CVPixelBufferGetBytesPerRow(cvImgRef);
    CGFloat r=0,g=0,b=0;
    
    for (NSInteger i = 0; i < height; i++) {
        for (NSInteger j = 0; j < width * 4; j+=4) {
            b += buf[j];
            g += buf[j+1];
            r += buf[j+2];
        }
        buf += bprow;
    }
    
    r /= 255*(CGFloat)(width * height);
    g /= 255*(CGFloat)(width * height);
    b /= 255*(CGFloat)(width * height);
    
    CGFloat h,s,v;
    
    RGBtoHSV(r, g, b, &h, &s, &v);
    
    self.deltaValue = v-self.lastValue;

    if (r < 0.5f) {
        UIAlertView *fingerAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Put your finger on camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [fingerAlert show];
    } else {
        if (![self.heartTimer isValid]) {
            [self startMeasuringHeartRate];
        }
        if (self.deltaValue > 0.f && self.lastDeltaValue < 0.f) {
            ++self.heartRate;
        }
    }
    
    if (![self.heartTimer isValid]) {
        [self startMeasuringHeartRate];
    }
    
    self.lastValue = v;
    self.lastDeltaValue = self.deltaValue;
}

#pragma mark - Heart Timer

- (void)onHeartTimer {
    
    [session stopRunning];
    [self.heartTimer invalidate];

    self.heartRate = (self.heartRate/2)*6;
    
    UIAlertView *heartAlertView = [[UIAlertView alloc]initWithTitle:@"Beats" message:[NSString stringWithFormat:@"%i",self.heartRate] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [heartAlertView show];
    self.heartRate = 0;
    
}

- (void)measureHeartRate {
    
    session = [AVCaptureSession new];
    
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([camera isTorchModeSupported:AVCaptureTorchModeOn]) {
        [camera lockForConfiguration:nil];
        [camera setActiveVideoMinFrameDuration:CMTimeMake(1, 10)];
        camera.torchMode = AVCaptureTorchModeOn;
        [camera unlockForConfiguration];
    }
    
    NSError *error = nil;
    AVCaptureInput *cameraInput = [[AVCaptureDeviceInput alloc]initWithDevice:camera error:&error];
    
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    dispatch_queue_t captureQueue=dispatch_queue_create("captureQueue", DISPATCH_QUEUE_SERIAL);
    
    [videoOutput setSampleBufferDelegate:self queue:captureQueue];
    videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],(id)kCVPixelBufferPixelFormatTypeKey, nil];
    
    [session setSessionPreset:AVCaptureSessionPresetLow];
    
    if ([session canAddInput:cameraInput]) {
        [session addInput:cameraInput];
    }
    
    if ([session canAddOutput:videoOutput]) {
        [session addOutput:videoOutput];
    }
    
    [session startRunning];
    
}

#pragma mark - Core Data stack

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

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
    
    [fetchRequest setFetchBatchSize:1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    abort();
	}

    return _fetchedResultsController;
}

@end
