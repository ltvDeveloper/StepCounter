//
//  Session.h
//  LocationManager
//
//  Created by Developer on 7/15/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LogPoint;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * kilometers;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSData * path;
@property (nonatomic, retain) NSSet *logPoint;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)addLogPointObject:(LogPoint *)value;
- (void)removeLogPointObject:(LogPoint *)value;
- (void)addLogPoint:(NSSet *)values;
- (void)removeLogPoint:(NSSet *)values;

@end
