//
//  LMViewController.h
//  LocationManager
//
//  Created by Developer on 6/18/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LMViewController : UIViewController

- (IBAction)onResetButton:(id)sender;
- (IBAction)onStartButton:(id)sender;
- (IBAction)onStopButton:(id)sender;
- (IBAction)onMapButton:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *accCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end
