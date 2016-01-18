/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLQueryVerbatmApp.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryVerbatmApp (29 custom class methods, 10 custom properties)

#import "GTLQueryVerbatmApp.h"

#import "GTLVerbatmAppImage.h"
#import "GTLVerbatmAppImageCollection.h"
#import "GTLVerbatmAppPage.h"
#import "GTLVerbatmAppPageCollection.h"
#import "GTLVerbatmAppPostCollection.h"
#import "GTLVerbatmAppUploadURI.h"
#import "GTLVerbatmAppVerbatmUser.h"
#import "GTLVerbatmAppVerbatmUserCollection.h"
#import "GTLVerbatmAppVideo.h"
#import "GTLVerbatmAppVideoCollection.h"

@implementation GTLQueryVerbatmApp

@dynamic channelId, count, email, fields, identifier, liked, pageId, postId,
         shareType, userId;

+ (NSDictionary *)parameterNameMap {
  NSDictionary *map = @{
    @"channelId" : @"channel_id",
    @"identifier" : @"id",
    @"pageId" : @"page_id",
    @"postId" : @"post_id",
    @"shareType" : @"share_type",
    @"userId" : @"user_id"
  };
  return map;
}

#pragma mark - "image" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForImageGetImageWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.image.getImage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  query.expectedObjectClass = [GTLVerbatmAppImage class];
  return query;
}

+ (instancetype)queryForImageGetUploadURI {
  NSString *methodName = @"verbatmApp.image.getUploadURI";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [GTLVerbatmAppUploadURI class];
  return query;
}

+ (instancetype)queryForImageInsertImageWithObject:(GTLVerbatmAppImage *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.image.insertImage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppImage class];
  return query;
}

+ (instancetype)queryForImageRemoveImageWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.image.removeImage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  return query;
}

+ (instancetype)queryForImageUpdateImageWithObject:(GTLVerbatmAppImage *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.image.updateImage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppImage class];
  return query;
}

#pragma mark - "page" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForPageGetPageWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.page.getPage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  query.expectedObjectClass = [GTLVerbatmAppPage class];
  return query;
}

+ (instancetype)queryForPageInsertPageWithObject:(GTLVerbatmAppPage *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.page.insertPage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppPage class];
  return query;
}

+ (instancetype)queryForPageRemovePageWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.page.removePage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  return query;
}

+ (instancetype)queryForPageUpdatePageWithObject:(GTLVerbatmAppPage *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.page.updatePage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppPage class];
  return query;
}

#pragma mark - "post" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForPostGetImagesInPageWithPageId:(long long)pageId {
  NSString *methodName = @"verbatmApp.post.getImagesInPage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.pageId = pageId;
  query.expectedObjectClass = [GTLVerbatmAppImageCollection class];
  return query;
}

+ (instancetype)queryForPostGetPagesInPostWithPostId:(long long)postId {
  NSString *methodName = @"verbatmApp.post.getPagesInPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.expectedObjectClass = [GTLVerbatmAppPageCollection class];
  return query;
}

+ (instancetype)queryForPostGetPostsInChannelWithChannelId:(NSInteger)channelId {
  NSString *methodName = @"verbatmApp.post.getPostsInChannel";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.channelId = channelId;
  query.expectedObjectClass = [GTLVerbatmAppPostCollection class];
  return query;
}

+ (instancetype)queryForPostGetRecentPostsWithCount:(NSInteger)count {
  NSString *methodName = @"verbatmApp.post.getRecentPosts";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.count = count;
  query.expectedObjectClass = [GTLVerbatmAppPostCollection class];
  return query;
}

+ (instancetype)queryForPostGetUsersWhoLikePostWithPostId:(long long)postId {
  NSString *methodName = @"verbatmApp.post.getUsersWhoLikePost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUserCollection class];
  return query;
}

+ (instancetype)queryForPostGetUsersWhoSharedPostWithPostId:(long long)postId {
  NSString *methodName = @"verbatmApp.post.getUsersWhoSharedPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUserCollection class];
  return query;
}

+ (instancetype)queryForPostGetVideosInPageWithPageId:(long long)pageId {
  NSString *methodName = @"verbatmApp.post.getVideosInPage";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.pageId = pageId;
  query.expectedObjectClass = [GTLVerbatmAppVideoCollection class];
  return query;
}

+ (instancetype)queryForPostInsertPost {
  NSString *methodName = @"verbatmApp.post.insertPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  return query;
}

+ (instancetype)queryForPostUserLikedPostWithLiked:(BOOL)liked
                                            postId:(long long)postId
                                            userId:(long long)userId {
  NSString *methodName = @"verbatmApp.post.userLikedPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.liked = liked;
  query.postId = postId;
  query.userId = userId;
  return query;
}

+ (instancetype)queryForPostUserSharedPostWithPostId:(long long)postId
                                           shareType:(NSString *)shareType
                                              userId:(long long)userId {
  NSString *methodName = @"verbatmApp.post.userSharedPost";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.postId = postId;
  query.shareType = shareType;
  query.userId = userId;
  return query;
}

#pragma mark - "verbatmuser" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForVerbatmuserGetUserWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.verbatmuser.getUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

+ (instancetype)queryForVerbatmuserGetUserFromEmailWithEmail:(NSString *)email {
  NSString *methodName = @"verbatmApp.verbatmuser.getUserFromEmail";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.email = email;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

+ (instancetype)queryForVerbatmuserInsertUserWithObject:(GTLVerbatmAppVerbatmUser *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.verbatmuser.insertUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

+ (instancetype)queryForVerbatmuserRemoveUserWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.verbatmuser.removeUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  return query;
}

+ (instancetype)queryForVerbatmuserUpdateUserWithObject:(GTLVerbatmAppVerbatmUser *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.verbatmuser.updateUser";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppVerbatmUser class];
  return query;
}

#pragma mark - "video" methods
// These create a GTLQueryVerbatmApp object.

+ (instancetype)queryForVideoGetUploadURI {
  NSString *methodName = @"verbatmApp.video.getUploadURI";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [GTLVerbatmAppUploadURI class];
  return query;
}

+ (instancetype)queryForVideoGetVideoWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.video.getVideo";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  query.expectedObjectClass = [GTLVerbatmAppVideo class];
  return query;
}

+ (instancetype)queryForVideoInsertVideoWithObject:(GTLVerbatmAppVideo *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.video.insertVideo";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppVideo class];
  return query;
}

+ (instancetype)queryForVideoRemoveVideoWithIdentifier:(long long)identifier {
  NSString *methodName = @"verbatmApp.video.removeVideo";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.identifier = identifier;
  return query;
}

+ (instancetype)queryForVideoUpdateVideoWithObject:(GTLVerbatmAppVideo *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"verbatmApp.video.updateVideo";
  GTLQueryVerbatmApp *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLVerbatmAppVideo class];
  return query;
}

@end
