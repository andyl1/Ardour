//
//  ALMatchViewController.h
//  Ardour
//
//  Created by Andy Lee on 10/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

// Lecture 341
@protocol ALMatchViewControllerDelegate <NSObject>

- (void)presentMatchesViewController;

@end

@interface ALMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <ALMatchViewControllerDelegate> delegate;

@end
