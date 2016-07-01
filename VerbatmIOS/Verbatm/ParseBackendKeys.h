//
//  ParseBackendKeys.h
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#ifndef ParseBackendKeys_h
#define ParseBackendKeys_h

#define USER_KEY @"User"

#define RELATIONSHIP_OWNER @"RelationshipOwner"

#define VERBATM_USER_NAME_KEY @"VerbatmName" //different from the username which is used by fb on parse
#define USER_FTUE @"UserFtue"
#define USER_MIGRATED_ONE_CHANNEL @"UserMigratedOneChannel"
#define USER_RELATION_CHANNELS_FOLLOWING @"ChannelsFollowing"

#define FOLLOW_PFCLASS_KEY @"FollowClass"//we maintain all the follow relationships in their own table
#define FOLLOW_USER_KEY @"UserFollowing"//the user doing the following
#define FOLLOW_CHANNEL_FOLLOWED_KEY @"ChannelFollowed"//channel being followed by above user
#define FOLLOW_LATEST_POST_SEEN @"LatestPostSeen"

#define LIKE_PFCLASS_KEY @"LikeClass"//we maintain all the like relationships in their own table
#define LIKE_USER_KEY @"UserLiking"//the user doing the liking
#define LIKE_POST_LIKED_KEY @"PostLiked"//post being liked by above user

#define SHARE_PFCLASS_KEY @"ShareClass"
#define SHARE_USER_KEY @"UserSharing"
#define SHARE_POST_SHARED_KEY @"PostShared"
#define SHARE_TYPE @"ShareType"
#define SHARE_TYPE_REBLOG @"ShareTypeReblog"
#define SHARE_REBLOG_CHANNEL @"ChannelRebloggedTo"

#define PHOTO_PFCLASS_KEY @"PhotoClass"
#define PHOTO_TEXT_KEY @"PhotoText"
#define PHOTO_TEXT_YOFFSET_KEY @"TextYOffset"
#define PHOTO_TEXT_COLOR_KEY @"TextColor"
#define PHOTO_TEXT_SIZE_KEY @"TextSize"
#define PHOTO_TEXT_ALIGNMENT_KEY @"TextAlignment"
#define PHOTO_IMAGEURL_KEY @"BlobStoreUrl"
#define PHOTO_PAGE_OBJECT_KEY @"PageObject"
#define PHOTO_INDEX_KEY @"PhotoIndex"
#define PHOTO_USER_KEY @"UsersPhoto"


#define VIDEO_INDEX_KEY @"VideoIndex" //if we have multiple videos how they are organized
#define VIDEO_PFCLASS_KEY @"VideoClass"
#define BLOB_STORE_URL @"BlobStoreUrl"
#define VIDEO_PAGE_OBJECT_KEY @"Page"
#define VIDEO_THUMBNAIL_KEY @"Thumbnail"


#define PAGE_PFCLASS_KEY @"PageClass"
#define PAGE_INDEX_KEY @"PageIndex"
#define PAGE_POST_KEY @"PostForPage" // the post this page belongs to
#define PAGE_VIEW_TYPE @"AveType"
#define PAGE_PHOTOS_PFRELATION @"PhotoObjectsInPageRelation"


#define POST_PFCLASS_KEY @"PostClass"
#define POST_CHANNEL_KEY @"ChannelForPost" //the channel the post lives in
#define POST_SIZE_KEY @"PostSize" //number of pages on this post
#define POST_ORIGINAL_CREATOR_KEY @"OriginalCreator" //Original creator or post
#define POST_NUM_LIKES @"PostNumLikes"
#define POST_NUM_REBLOGS @"PostNumReblogs"
#define POST_SHARE_LINK @"PostSocialShareLink" //string url to share to social media
#define POST_PAGES_PFRELATION @"PagesInPost"

#define POST_COMPLETED_SAVING @"PostDoneSaving"//we store

#define POST_CHANNEL_ACTIVITY_CLASS  @"PostChannelActivityClass"
#define POST_CHANNEL_ACTIVITY_CHANNEL_POSTED_TO @"PostChannelActivityChannelPosted"//channel that post is posted in 
#define POST_CHANNEL_ACTIVITY_POST @"PostChannelActivityPost"

#define POST_FLAGGED_KEY  @"Post_Is_Flagged"
#define FLAG_PFCLASS_KEY @"FlagClass"
#define FLAG_USER_KEY @"FlagUser"
#define FLAG_POST_FLAGGED_KEY @"FlagPost"

#define BLOCK_PFCLASS_KEY @"BlockClass"
#define BLOCK_USER_BLOCKED_KEY @"BlockUserBlocked" //User who has been blocked
#define BLOCK_USER_BLOCKING_KEY @"BlockUserBlocking" //User who blocked another user

#define CHANNEL_PFCLASS_KEY @"ChannelClass"
#define CHANNEL_NAME_KEY @"ChannelName"
#define CHANNEL_DESCRIPTION_KEY @"ChannelDescription"
#define CHANNEL_CREATOR_KEY @"ChannelCreator" //the user that has created this channel
#define CHANNEL_NUM_FOLLOWS @"ChannelNumFollows"
#define CHANNEL_FEATURED_BOOL @"Featured"
#define CHANNEL_COVER_PHOTO_URL @"CoverPhotoURL"

#endif /* ParseBackendKeys_h */
