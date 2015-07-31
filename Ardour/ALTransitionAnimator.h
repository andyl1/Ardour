//
//  ALTransitionAnimator.h
//  Ardour
//
//  Created by Andy Lee on 13/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ALTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
