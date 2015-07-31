//
//  ALSettingsViewController.m
//  Ardour
//
//  Created by Andy Lee on 8/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALSettingsViewController.h"
#import "ALConstants.h"
#import <Parse/Parse.h>

@interface ALSettingsViewController ()

@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UISwitch *mensSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *womensSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *singlesSwitch;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;

@end

@implementation ALSettingsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kALAgeMaxKey];
    self.mensSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kALMenEnabledKey];
    self.womensSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kALWomenEnabledKey];
    self.singlesSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kALSingleEnableKey];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mensSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.womensSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singlesSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBActions


- (IBAction)logoutButtonPressed:(UIButton *)sender {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)editProfileButtonPressed:(UIButton *)sender {
    
}


#pragma mark - Helper Methods


- (void)valueChanged:(id)sender {
    
    if (sender == self.ageSlider) {
        [[NSUserDefaults standardUserDefaults] setInteger:(int)self.ageSlider.value forKey:kALAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    }
    else if (sender == self.mensSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.mensSwitch.isOn forKey:kALMenEnabledKey];
    }
    else if (sender == self.womensSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.womensSwitch.isOn forKey:kALWomenEnabledKey];
    }
    else if (sender == self.singlesSwitch) {
        [[NSUserDefaults standardUserDefaults] setBool:self.singlesSwitch.isOn forKey:kALSingleEnableKey];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
