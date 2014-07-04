//
//  LMSettingsViewController.m
//  LocationManager
//
//  Created by Developer on 7/1/14.
//  Copyright (c) 2014 developer. All rights reserved.
//

#import "LMSettingsViewController.h"
#import "LMViewController.h"

@interface LMSettingsViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation LMSettingsViewController

@synthesize activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
    self.weightTextField.delegate = self;
}


- (void)viewDidDisappear:(BOOL)animated {
    
    LMViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    viewController.activity = activity;
    viewController.weight = self.weightTextField.text;
    NSLog(@"%@",activity);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    return YES;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    
    switch (row) {
        case 0:
            title = @"Running";
            break;
        case 1:
            title = @"Walking";
            break;
    }
    
    return title;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 2;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (row) {
        case 0:
            activity = @"Running";
            break;
        case 1:
            activity = @"Walking";
            break;

    }
}



@end
