//
//  ParseBackendKeys.h
//  Verbatm
//
//  Created by Iain Usiri on 1/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#ifndef ParseBackendKeys_h
#define ParseBackendKeys_h

#define PHOTO_PFCLASS_KEY @"Photo Class"
#define PHOTO_TEXT_KEY @"Photo Text"
#define PHOTO_TEXT_YOFFSET_KEY @"Text Y Offset"
#define PHOTO_IMAGEURL_KEY @"Blob Store Url"
#define PHOTO_PAGE_OBJECT_KEY @"Page Object"
#define PHOTO_INDEX_KEY @"Photo Index"
#define PHOTO_USER_KEY @"Users Photo"



#define VIDEO_INDEX_KEY @"Video Index" //if we have multiple videos how they are organized
#define VIDEO_PFCLASS_KEY @"Video"
#define User_Key @"user"
#define BLOB_STORE_URL @"Blob Store Url"
#define VIDEO_PAGE_OBJECT_KEY @"Page"


#define PAGE_PFCLASS_KEY @"Page Class"
#define PAGE_INDEX_KEY @"Page Index"
#define PAGE_POST_KEY @"Post for Page" // the post this page belongs to


#define POST_PFCLASS_KEY @"Post Class"
#define POST_CHANNEL_KEY @"Channel for post" //the channel the post lives in
#define POST_SIZE_KEY @"Post Size" //number of pages on this post
#define POST_LIKES_NUM_KEY @"Number of Likes"
#define POST_NUM_SHARES_KEY @"Number of Shares" //number of times this post has been shared
#define POST_ORIGINAL_CREATOR_KEY @"Original Creator" //Original creator or post

#define CHANNEL_PFCLASS_KEY @"Channel Class"
#define CHANNEL_NAME_KEY @"Chanel Name"
#define CHANNEL_NUM_POSTS_KEY @"Number of Posts"
#define CHANNEL_NUM_FOLLOWERS_KEY @"Number of Followers"
#endif /* ParseBackendKeys_h */
