//
//  ALChatViewController.m
//  Ardour
//
//  Created by Andy Lee on 10/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALChatViewController.h"
#import "ALConstants.h"

@interface ALChatViewController ()

@property (strong, nonatomic) PFUser *withUser;  // Lecture 346
@property (strong, nonatomic) PFUser *currentUser;  // Lecture 346

@property (strong, nonatomic) NSTimer *chatsTimer;  // Lecture 346
@property (nonatomic) BOOL initialLoadComplete;  // Lecture 346

@property (strong, nonatomic) NSMutableArray *chats;  // Lecture 346

@end

@implementation ALChatViewController


#pragma mark - Lazy Instantiation

// Lecture 346
- (NSMutableArray *)chats {
    if (!_chats) {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}


- (void)viewDidLoad {
    
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kALChatRoomUser1Key];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]) {
        self.withUser = self.chatRoom[kALChatRoomUser2Key];
    }
    else {
        self.withUser = self.chatRoom[kALChatRoomUser1Key];
    }
    
    self.title = self.withUser[kALUserProfileKey][kALUserProfileFirstNameKey];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidDisappear:(BOOL)animated {
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chats count];
}


#pragma mark - TableView Delegate (REQUIRED)

-(void)didSendText:(NSString *)text {
    if (text.length != 0) {
        PFObject *chat = [PFObject objectWithClassName:kALChatClassKey];
        [chat setObject:self.chatRoom forKey:kALChatChatRoomKey];
        [chat setObject:self.currentUser forKey:kALChatFromUserKey];
        [chat setObject:self.withUser forKey:kALChatToUserKey];
        [chat setObject:text forKey:kALChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
    }
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kALChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return JSBubbleMessageTypeOutgoing;
    }
    else {
        return JSBubbleMessageTypeIncoming;
    }
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kALChatFromUserKey];
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    }
    else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

-(JSMessagesViewTimestampPolicy)timestampPolicy {
    return JSMessagesViewTimestampPolicyAll;
}

-(JSMessagesViewAvatarPolicy)avatarPolicy{
    return JSMessagesViewAvatarPolicyNone;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy {
    return JSMessagesViewSubtitlePolicyNone;
}

-(JSMessageInputViewStyle)inputViewStyle {
    return JSMessageInputViewStyleFlat;
}


#pragma mark - TableView Delegate (OPTIONAL)

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}


#pragma mark - MessagesView DataSource (REQUIRED)

-(NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[kALChatTextKey];
    return message;
}

-(NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


#pragma mark - Helper Methods


- (void)checkForNewChats {
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:kALChatClassKey];
    [queryForChats whereKey:kALChatChatRoomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]) {
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                
                if (self.initialLoadComplete == YES) {
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
}


@end
