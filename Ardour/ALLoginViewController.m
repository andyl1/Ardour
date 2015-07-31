//
//  ALLoginViewController.m
//  Ardour
//
//  Created by Andy Lee on 6/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALLoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "ALConstants.h"

@interface ALLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation ALLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.activityIndicator.hidden = YES;
}


//This stops the user from having to press the 'Login With Facebook' button.
- (void)viewDidAppear:(BOOL)animated {
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {  //This checks if current user ID is the same in both Parse and in Facebook linked user.
        [self updateUserInformation];  //If yes, refresh user information by updating, incase user data has changed in FB.
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];  //If yes, perform segue to Home, without having to press the 'Login With Facebook' button.
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if (!user) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Your Facebook login was cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
            }
        }
        else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
    }];
}


#pragma mark - Helper Methods

- (void)updateUserInformation {
    
    // Create a FB user request to access user information.
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            
            // Create a 'userDictionary' dictionary of all the data we have been granted access to.
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            // Create pictureURL string, containing user's facebookID, is uploaded to Parse in userProfile dictionary below.
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            // Create a 'userProfile' dictionary saving only the data we want from userDictionary to Parse.
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            
            if (userDictionary[@"name"]) {
                userProfile[kALUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kALUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kALUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kALUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kALUserProfileBirthdayKey] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];  //Comparing now to DOB to calculate user's age.
                int age = seconds / 31536000;  //Converts age to 'years'.
                userProfile[kALUserProfileAgeKey] = @(age);  //Saves 'age' to userProfile in Parse.
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kALUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            if (userDictionary[@"relationshipStatus"]) {
                userProfile[kALUserProfileRelationshipStatusKey] = userDictionary[@"relationshipStatus"];
            }
            // Converting the URL into a string format, then adding this string to our 'userProfile' to Parse.
            if ([pictureURL absoluteString]) {
                userProfile[kALUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            // Setting 'currentUser' as the 'userProfile' we just created.
            [[PFUser currentUser] setObject:userProfile forKey:kALUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
        }
        
        else {
            NSLog(@"Error in Facebook request %@", error);
        }
    }];
}

//This method uploads an image to Parse as an PFFile, but we still need to hit the URL for the photo elsewhere.
- (void)uploadPFFileToParse:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData) {
        NSLog(@"Image data was not found.");
        return;  //This stops the method from continuing if no image data is found.
    }
    
    //Converts the NSData imageData object to a PFFile to store in Parse.
    PFFile *photoFile = [PFFile fileWithData:imageData];
    //Whenever we create a PF object we need to save it...
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject *photo = [PFObject objectWithClassName:kALPhotoClassKey];  //This is the PFFile as Parse item on left menu.
            [photo setObject:[PFUser currentUser] forKey:kALPhotoUserKey];  //This is setting the object heading 'user' value.
            [photo setObject:photoFile forKey:kALPhotoPictureKey];  //This is setting the object heading 'image' value.
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved successfully");  //This is saving the photo object we just created for the PFFile.
            }];
        }
    }];
}

//This method hits the URL to download the user's photo, so we can upload it to Parse as an PFFile.
- (void)requestImage {
    PFQuery *query = [PFQuery queryWithClassName:kALPhotoClassKey];  //This gets all the photos back from Parse.
    [query whereKey:kALPhotoUserKey equalTo:[PFUser currentUser]];  //This constrains it to photos to currentUser only.
    
    //This further constrains the query to only getting the count of the photos for this currentUser, and saving it.
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0) {
            PFUser *user = [PFUser currentUser];  //If no photos, then create NSMutableData object for this currentUser.
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kALUserProfileKey][kALUserProfilePictureURL]];  //This is grabbing the URL we saved into the 'userProfile' dictionary earlier.
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];  //This is requesting the server for a response.
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];  //This is connecting to the remote server and downloading the photo, and allows for asynchronous downloading.
            if (!urlConnection) {
                NSLog(@"Failed to download picture");  //If no urlConnection.
            }
        }
    }];
}

//This method is available by conforming to the NSURLConnectionDataDelegate.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data];  //This appends the downloaded data to the receiver 'self.imageData', building the file as it is being downloaded.
}

//This method is available by conforming to the NSURLConnectionDataDelegate.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *profileImage = [UIImage imageWithData:self.imageData];  //This sets the 'profileImage' object when download is completed, because imageData is a NSMutableData type, not UIImage type.
    [self uploadPFFileToParse:profileImage];  //This then uploads the file to Parse by calling on the uploadPFFileToParse method.
}


@end
