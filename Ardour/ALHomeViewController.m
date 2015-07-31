//
//  ALHomeViewController.m
//  Ardour
//
//  Created by Andy Lee on 8/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALHomeViewController.h"
#import <Parse/Parse.h>
#import "ALConstants.h"
#import "ALTestUser.h"
#import "ALProfileViewController.h"
#import "ALMatchViewController.h"
#import "ALTransitionAnimator.h"
#import <Mixpanel.h>

@interface ALHomeViewController () <ALMatchViewControllerDelegate, ALProfileViewControllerDelegate, UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

@property (strong, nonatomic) NSArray *photos;  //We save all the photos in Parse into this array, except currentUser.
@property (strong, nonatomic) PFObject *photo;  //The current photo we are viewing on home view.
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedbyCurrentUser;

@end

@implementation ALHomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [ALTestUser saveTestUserToParse];
    [self setUpViews];
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;  //We're indexing into the first photo of the current user's 'photos' array.
    
    PFQuery *query = [PFQuery queryWithClassName:kALPhotoClassKey];
    [query whereKey:kALPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kALPhotoUserKey];  //By using includeKey:@"user" we are telling the query to not only bring back the class 'Photo' in Parse, but also the related 'user' information for that Photo so we can access the user information.
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;  //This saves the current user's photos to 'self.photos' array to access in other methods.
            if ([self allowPhoto] == NO) {
                [self setupNextPhoto];
            }
            else {
                [self queryForCurrentPhotoIndex];
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

- (void)setUpViews {
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
    self.photoImageView.layer.masksToBounds = YES;
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

- (void)addShadowForView:(UIView *)view {
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"homeToProfileSegue"]) {
        ALProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
        
        profileVC.delegate = self;  // Lecture 367
    }
//    else if ([segue.identifier isEqualToString:@"homeToMatchSegue"]) {
//        ALMatchViewController *matchVC = segue.destinationViewController;
//        matchVC.matchedUserImage = self.photoImageView.image;
//        matchVC.delegate = self;  // Lecture 341
//    }
}


#pragma mark - IBActions

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)likeButtonPressed:(UIButton *)sender {
    
//    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [mixpanel track:@"Like"];
//    [mixpanel flush];
    
    [self checkLike];
    [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    
//    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [mixpanel track:@"DRislike"];
//    [mixpanel flush];
    
    [self checkDislike];
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}


#pragma mark - Helper Methods

- (void)queryForCurrentPhotoIndex {
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];  // Created a property 'photo' to store other user's first photo.
        PFFile *file = self.photo[kALPhotoPictureKey];  //We are downloading the above stated image from Parse, under 'image'.
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];  //Converts the NSData to UIImage format.
                self.photoImageView.image = image;  //Sets the photoImageView to the photo we just downloaded.
                [self updateView];
            }
            else {
                NSLog(@"%@", error);
            }
        }];
        
        PFQuery *queryForLikes = [PFQuery queryWithClassName:kALActivityClassKey];
        [queryForLikes whereKey:kALActivityTypeKey equalTo:kALActivityTypeLikeKey];
        [queryForLikes whereKey:kALActivityPhotoKey equalTo:self.photo];
        [queryForLikes whereKey:kALActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislikes = [PFQuery queryWithClassName:kALActivityClassKey];
        [queryForDislikes whereKey:kALActivityTypeKey equalTo:kALActivityTypeDislikeKey];
        [queryForDislikes whereKey:kALActivityPhotoKey equalTo:self.photo];
        [queryForDislikes whereKey:kALActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likesAndDislikesQuery = [PFQuery orQueryWithSubqueries:@[queryForLikes, queryForDislikes]];
        [likesAndDislikesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedbyCurrentUser = NO;
                }
                else {
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[kALActivityTypeKey] isEqualToString:kALActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedbyCurrentUser = NO;
                    }
                    else if ([activity[kALActivityTypeKey] isEqualToString:kALActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedbyCurrentUser = YES;
                    }
                    else {
                        // Some other types of activity.
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

- (void)updateView {
    self.firstNameLabel.text = self.photo[kALPhotoUserKey][kALUserProfileKey][kALUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kALPhotoUserKey][kALUserProfileKey][kALUserProfileAgeKey]];
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < self.photos.count) {
        self.currentPhotoIndex ++;
        if ([self allowPhoto] == NO) {
            [self setupNextPhoto];
        }
        else {
            [self queryForCurrentPhotoIndex];
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No more matches" message:@"Please come back later for new matches!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}

// Lecture 358
- (BOOL)allowPhoto {
    int maxAge = [[NSUserDefaults standardUserDefaults] integerForKey:kALAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults] boolForKey:kALMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults] boolForKey:kALWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults] boolForKey:kALSingleEnableKey];
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kALPhotoUserKey];
    
    int userAge = [user[kALUserProfileKey][kALUserProfileAgeKey] intValue];
    NSString *gender = user[kALUserProfileKey][kALUserProfileGenderKey];
    NSString *relationshipStatus = user[kALUserProfileKey][kALUserProfileRelationshipStatusKey];
    
    if (userAge > maxAge) {
        return NO;
    }
    else if (men == NO && [gender isEqualToString:@"male"]) {
        return NO;
    }
    else if (women == NO && [gender isEqualToString:@"female"]) {
        return NO;
    }
    else if (single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil)) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:kALActivityClassKey];
    [likeActivity setObject:kALActivityTypeLikeKey forKey:kALActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kALActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kALPhotoUserKey] forKey:kALActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kALActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedbyCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

- (void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:kALActivityClassKey];
    [dislikeActivity setObject:kALActivityTypeDislikeKey forKey:kALActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kALActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kALPhotoUserKey] forKey:kALActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kALActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedbyCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

- (void)checkLike {
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isDislikedbyCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    }
    else {
        [self saveLike];
    }
}

- (void)checkDislike {
    if (self.isDislikedbyCurrentUser) {
        [self setupNextPhoto];
        return;
    }
    else if (self.isLikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else {
        [self saveDislike];
    }
}

// Lecture 337
- (void)checkForPhotoUserLikes {
    PFQuery *query = [PFQuery queryWithClassName:kALActivityClassKey];
    [query whereKey:kALActivityFromUserKey equalTo:self.photo[kALPhotoUserKey]];
    [query whereKey:kALActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kALActivityTypeKey equalTo:kALActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            [self createChatRoom];
        }
    }];
}

- (void)createChatRoom {
    
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kALChatRoomClassKey];
    [queryForChatRoom whereKey:kALChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kALChatRoomUser2Key equalTo:self.photo[kALPhotoUserKey]];
    
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kALChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kALChatRoomUser1Key equalTo:self.photo[kALPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kALChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0) {
            PFObject *chatRoom = [PFObject objectWithClassName:kALChatRoomClassKey];
            [chatRoom setObject:[PFUser currentUser] forKey:kALChatRoomUser1Key];
            [chatRoom setObject:self.photo[kALPhotoUserKey] forKey:kALChatRoomUser2Key];
            [chatRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                UIStoryboard *myStoryboard = self.storyboard;  // Lecture 374
                
                ALMatchViewController *matchedViewContoller = [myStoryboard instantiateViewControllerWithIdentifier:@"matchVC"];
                matchedViewContoller.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.75];
                matchedViewContoller.transitioningDelegate = self;
                matchedViewContoller.matchedUserImage = self.photoImageView.image;
                
                matchedViewContoller.delegate = self;
                
                matchedViewContoller.modalPresentationStyle = UIModalPresentationCustom;
                [self presentViewController:matchedViewContoller animated:YES completion:nil];
            }];
        }
    }];
}


#pragma mark - ALMatchViewController Delegate

// Lecture 341
- (void)presentMatchesViewController {
    [self dismissViewControllerAnimated:NO completion:^ {
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}


#pragma mark - ALProfileViewController Delegate

// Lecture 367
- (void)didPressLike {
    [self.navigationController popViewControllerAnimated:NO];
    [self checkLike];
}


- (void)didPressDislike {
    [self.navigationController popViewControllerAnimated:NO];
    [self checkDislike];
}


#pragma mark - UIViewControllerTransitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    ALTransitionAnimator *animator = [[ALTransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ALTransitionAnimator *animator = [[ALTransitionAnimator alloc] init];
    return animator;
}


@end
