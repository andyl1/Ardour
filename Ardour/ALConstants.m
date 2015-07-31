//
//  ALConstants.m
//  Ardour
//
//  Created by Andy Lee on 7/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import "ALConstants.h"

@implementation ALConstants


#pragma mark - User Class

NSString *const kALUserTagLineKey                       = @"tagLine";

NSString *const kALUserProfileKey                       = @"profile";
NSString *const kALUserProfileNameKey                   = @"name";
NSString *const kALUserProfileFirstNameKey              = @"firstName";
NSString *const kALUserProfileLocationKey               = @"location";
NSString *const kALUserProfileGenderKey                 = @"gender";
NSString *const kALUserProfileBirthdayKey               = @"birthday";
NSString *const kALUserProfileInterestedInKey           = @"interestedIn";
NSString *const kALUserProfilePictureURL                = @"pictureURL";
NSString *const kALUserProfileRelationshipStatusKey     = @"relationshipStatus";
NSString *const kALUserProfileAgeKey                    = @"age";


#pragma mark - Photo Class

NSString *const kALPhotoClassKey                        = @"Photo";
NSString *const kALPhotoUserKey                         = @"user";
NSString *const kALPhotoPictureKey                      = @"image";


#pragma mark - Activity Class

NSString *const kALActivityClassKey                     = @"Activity";
NSString *const kALActivityTypeKey                      = @"type";
NSString *const kALActivityFromUserKey                  = @"fromUser";
NSString *const kALActivityToUserKey                    = @"toUser";
NSString *const kALActivityPhotoKey                     = @"photo";
NSString *const kALActivityTypeLikeKey                  = @"like";
NSString *const kALActivityTypeDislikeKey               = @"dislike";


#pragma mark - Settings Class

NSString *const kALMenEnabledKey                        = @"men";
NSString *const kALWomenEnabledKey                      = @"women";
NSString *const kALSingleEnableKey                      = @"single";
NSString *const kALAgeMaxKey                            = @"ageMax";


#pragma mark - ChatRoom Class

NSString *const kALChatRoomClassKey                     = @"ChatRoom";
NSString *const kALChatRoomUser1Key                     = @"user1";
NSString *const kALChatRoomUser2Key                     = @"user2";


#pragma mark - Chat Class

NSString *const kALChatClassKey                         = @"Chat";
NSString *const kALChatChatRoomKey                      = @"chatRoom";
NSString *const kALChatFromUserKey                      = @"fromUser";
NSString *const kALChatToUserKey                        = @"toUser";
NSString *const kALChatTextKey                          = @"text";


@end
