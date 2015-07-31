//
//  ALProfileViewController.m
//  Ardour
//
//  Created by Andy Lee on 8/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALProfileViewController.h"
#import "ALConstants.h"
#import <Parse/Parse.h>

@interface ALProfileViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation ALProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFFile *pictureFile = self.photo[kALPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
    }];
    
    PFUser *user = self.photo[kALPhotoUserKey];
    self.locationLabel.text = user[kALUserProfileKey][kALUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kALUserProfileKey][kALUserProfileAgeKey]];
    
    if (user[kALUserProfileKey][kALUserProfileRelationshipStatusKey] == nil) {
        self.statusLabel.text = @"Single";
    }
    
    self.statusLabel.text = user[kALUserProfileKey][kALUserProfileRelationshipStatusKey];
    self.tagLineLabel.text = user[kALUserTagLineKey];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.title = user[kALUserProfileKey][kALUserProfileFirstNameKey];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - IBActions


- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self.delegate didPressLike];
}


- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self.delegate didPressDislike];
}


@end
