//
//  ALTestUser.m
//  Ardour
//
//  Created by Andy Lee on 9/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALTestUser.h"
#import <Parse/Parse.h>
#import "ALConstants.h"

@implementation ALTestUser

+ (void)saveTestUserToParse {
    PFUser *newUser = [PFUser user];
    newUser.username = @"user1";
    newUser.password = @"password1";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSDictionary *profile = @{@"age" : @23, @"birthday" : @"10/06/1993", @"firstName" : @"Julie", @"gender" : @"female", @"location" : @"London, United Kingdom", @"name" : @"Julie McDonald", @"relationshipStatus" : @"Single"};
            [newUser setObject:profile forKey:@"profile"];
            [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                UIImage *profileImage = [UIImage imageNamed:@"astronaut.jpg"];
                NSData *imageData = UIImageJPEGRepresentation(profileImage, 1.0);
                PFFile *photoFile = [PFFile fileWithData:imageData];
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFObject *photo = [PFObject objectWithClassName:kALPhotoClassKey];
                        [photo setObject:newUser forKey:kALPhotoUserKey];
                        [photo setObject:photoFile forKey:kALPhotoPictureKey];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Test user photo saved successfully");
                        }];
                    }
                }];
            }];
        }
    }];
}


@end
