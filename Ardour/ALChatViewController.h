//
//  ALChatViewController.h
//  Ardour
//
//  Created by Andy Lee on 10/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <Parse/Parse.h>

@interface ALChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>  // Lecture 346

@property (strong, nonatomic) PFObject *chatRoom;  // Lecture 345

@end
