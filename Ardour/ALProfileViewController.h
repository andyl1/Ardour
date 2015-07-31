//
//  ALProfileViewController.h
//  Ardour
//
//  Created by Andy Lee on 8/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ALProfileViewControllerDelegate <NSObject>

- (void)didPressLike;
- (void)didPressDislike;

@end

@interface ALProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;
@property (weak, nonatomic) id <ALProfileViewControllerDelegate> delegate;

@end
