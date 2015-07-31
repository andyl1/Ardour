//
//  ALMatchesViewController.m
//  Ardour
//
//  Created by Andy Lee on 10/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALMatchesViewController.h"
#import <Parse/Parse.h>
#import "ALConstants.h"
#import "ALChatViewController.h"  // Lecture 345

@interface ALMatchesViewController () <UITableViewDelegate, UITableViewDataSource>  // Lecture 343

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableChatRooms;  // Lecture 342

@end

@implementation ALMatchesViewController


#pragma mark - Lazy Instantiation


// Lecture 343
- (NSMutableArray *)availableChatRooms {
    if (!_availableChatRooms) {
        _availableChatRooms = [[NSMutableArray alloc] init];
    }
    return _availableChatRooms;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Lecture 343
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateAvailableChatRooms];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation


// Lecture 345
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     ALChatViewController *chatVC = segue.destinationViewController;
     NSIndexPath *indexPath = sender;
     chatVC.chatRoom = [self.availableChatRooms objectAtIndex:indexPath.row];
 }


#pragma mark - Helper Methods


//Lecture 342
-(void)updateAvailableChatRooms {
    
    PFQuery *query = [PFQuery queryWithClassName:kALChatRoomClassKey];
    [query whereKey:kALChatRoomUser1Key equalTo:[PFUser currentUser]];
    
    PFQuery *queryInverse = [PFQuery queryWithClassName:kALChatRoomClassKey];
    [query whereKey:kALChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    
    [queryCombined includeKey:kALChatClassKey];
    [queryCombined includeKey:kALChatRoomUser1Key];
    [queryCombined includeKey:kALChatRoomUser2Key];
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatRooms removeAllObjects];
            self.availableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}


#pragma mark - UITableView DataSource


// Lecture 343
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableChatRooms count];
    
}


// Lecture 343
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = [self.availableChatRooms objectAtIndex:indexPath.row];
    
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[kALChatRoomUser1Key];
    if ([testUser1.objectId isEqual:currentUser.objectId]) {
        likedUser = [chatRoom objectForKey:kALChatRoomUser2Key];
    }
    else {
        likedUser = [chatRoom objectForKey:kALChatRoomUser1Key];
    }
    
    cell.textLabel.text = likedUser[kALUserProfileKey][kALUserProfileFirstNameKey];
    cell.detailTextLabel.text = likedUser[kALUserProfileKey][kALUserProfileRelationshipStatusKey];
    
    // Lecture 344  
    // cell.imageView.image = "placeholder image"
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [[PFQuery alloc] initWithClassName:kALPhotoClassKey];
    [queryForPhoto whereKey:kALPhotoUserKey equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kALPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    
    return cell;
}


#pragma mark - UITableView Delegate


// Lecture 345
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"matchesToChatSegue" sender:indexPath];
}


@end
