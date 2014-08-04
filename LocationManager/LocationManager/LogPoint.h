//
//  LogPoint.h
//  LocationManager
//
//  Created by Developer on 7/14/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Session;

@interface LogPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) Session *session;

@end
