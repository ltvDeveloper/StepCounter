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
- (IBAction)onSettingsButton:(id)sender;
- (IBAction)onOKButton:(id)sender;
- (IBAction)onGenderControl:(id)sender;
- (IBAction)onMetabolismButton:(id)sender;



@property (strong, nonatomic) IBOutlet UILabel *consumptionWaterLabel;
@property (strong, nonatomic) IBOutlet UILabel *accCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lapLabel;
@property (strong, nonatomic) IBOutlet UILabel *burnedCaloriesLabel;
@property (strong, nonatomic) IBOutlet UILabel *fatLabel;
@property (strong, nonatomic) IBOutlet UILabel *agingFactorLabel;
@property (strong, nonatomic) IBOutlet UILabel *biologicalAgeLabel;

@property (strong, nonatomic) IBOutlet UIView *settingsView;
@property (strong, nonatomic) IBOutlet UIView *metabolismView;

@property (strong, nonatomic) IBOutlet UITextField *weightTextField;
@property (strong, nonatomic) IBOutlet UITextField *ageTextField;
@property (strong, nonatomic) IBOutlet UITextField *growthTextField;
@property (strong, nonatomic) IBOutlet UITextField *waistlineTextField;
@property (strong, nonatomic) IBOutlet UITextField *hipsTextField;

@property (strong, nonatomic) IBOutlet UISegmentedControl *genderControl;

@end
