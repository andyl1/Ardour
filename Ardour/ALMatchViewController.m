//
//  ALMatchViewController.m
//  Ardour
//
//  Created by Andy Lee on 10/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALMatchViewController.h"
#import <Parse/Parse.h>
#import "ALConstants.h"

@interface ALMatchViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *matchedUserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *currentUserImageView;
@property (strong, nonatomic) IBOutlet UIButton *startChatButton;
@property (strong, nonatomic) IBOutlet UIButton *keepSearchingButton;


@end

@implementation ALMatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Lecture 340
    PFQuery *query = [PFQuery queryWithClassName:kALPhotoClassKey];
    [query whereKey:kALPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kALPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.currentUserImageView.image = [UIImage imageWithData:data];
                self.matchedUserImageView.image = self.matchedUserImage;
            }];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

// Lecture 341
- (IBAction)startChatButtonPressed:(UIButton *)sender {
    [self.delegate presentMatchesViewController];
}

// Lecture 340
- (IBAction)keepSearchingButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
