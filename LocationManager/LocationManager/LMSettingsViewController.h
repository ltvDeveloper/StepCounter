//
//  LMSettingsViewController.h
//  LocationManager
//
//  Created by Developer on 7/1/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMSettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *weightTextField;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, readonly) NSString *activity;
@end
