//
//  ALConstants.h
//  Ardour
//
//  Created by Andy Lee on 7/06/2015.
//  Copyright (c) 2015 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALConstants : NSObject


#pragma mark - User Class

extern NSString *const kALUserTagLineKey;

extern NSString *const kALUserProfileKey;
extern NSString *const kALUserProfileNameKey;
extern NSString *const kALUserProfileFirstNameKey;
extern NSString *const kALUserProfileLocationKey;
extern NSString *const kALUserProfileGenderKey;
extern NSString *const kALUserProfileBirthdayKey;
extern NSString *const kALUserProfileInterestedInKey;
extern NSString *const kALUserProfilePictureURL;
extern NSString *const kALUserProfileRelationshipStatusKey;
extern NSString *const kALUserProfileAgeKey;


#pragma mark - Photo Class

extern NSString *const kALPhotoClassKey;
extern NSString *const kALPhotoUserKey;
extern NSString *const kALPhotoPictureKey;


#pragma mark - Activity Class

extern NSString *const kALActivityClassKey;
extern NSString *const kALActivityTypeKey;
extern NSString *const kALActivityFromUserKey;
extern NSString *const kALActivityToUserKey;
extern NSString *const kALActivityPhotoKey;
extern NSString *const kALActivityTypeLikeKey;
extern NSString *const kALActivityTypeDislikeKey;


#pragma mark - Settings Class

extern NSString *const kALMenEnabledKey;
extern NSString *const kALWomenEnabledKey;
extern NSString *const kALSingleEnableKey;
extern NSString *const kALAgeMaxKey;


#pragma mark - ChatRoom Class

extern NSString *const kALChatRoomClassKey;
extern NSString *const kALChatRoomUser1Key;
extern NSString *const kALChatRoomUser2Key;


#pragma mark - Chat Class

extern NSString *const kALChatClassKey;
extern NSString *const kALChatChatRoomKey;
extern NSString *const kALChatFromUserKey;
extern NSString *const kALChatToUserKey;
extern NSString *const kALChatTextKey;










@end
