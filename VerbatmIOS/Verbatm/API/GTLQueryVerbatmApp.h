/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLQueryVerbatmApp.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLQueryVerbatmApp (24 custom class methods, 4 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLQuery.h"
#else
  #import "GTLQuery.h"
#endif

@class GTLVerbatmAppImage;
@class GTLVerbatmAppPage;
@class GTLVerbatmAppPageListWrapper;
@class GTLVerbatmAppPOV;
@class GTLVerbatmAppVerbatmUser;
@class GTLVerbatmAppVideo;

@interface GTLQueryVerbatmApp : GTLQuery

//
// Parameters valid on all methods.
//

// Selector specifying which fields to include in a partial response.
@property (nonatomic, copy) NSString *fields;

//
// Method-specific parameters; see the comments below for more information.
//
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, copy) NSString *cursorString;
// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (nonatomic, assign) long long identifier;

#pragma mark - "image" methods
// These create a GTLQueryVerbatmApp object.

// Method: verbatmApp.image.getImage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppImage.
+ (instancetype)queryForImageGetImageWithIdentifier:(long long)identifier;

// Method: verbatmApp.image.insertImage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppImage.
+ (instancetype)queryForImageInsertImageWithObject:(GTLVerbatmAppImage *)object;

// Method: verbatmApp.image.removeImage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
+ (instancetype)queryForImageRemoveImageWithIdentifier:(long long)identifier;

// Method: verbatmApp.image.updateImage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppImage.
+ (instancetype)queryForImageUpdateImageWithObject:(GTLVerbatmAppImage *)object;

#pragma mark - "page" methods
// These create a GTLQueryVerbatmApp object.

// Method: verbatmApp.page.getPage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPage.
+ (instancetype)queryForPageGetPageWithIdentifier:(long long)identifier;

// Method: verbatmApp.page.insertPage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPage.
+ (instancetype)queryForPageInsertPageWithObject:(GTLVerbatmAppPage *)object;

// Method: verbatmApp.page.insertPages
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPageListWrapper.
+ (instancetype)queryForPageInsertPagesWithObject:(GTLVerbatmAppPageListWrapper *)object;

// Method: verbatmApp.page.removePage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
+ (instancetype)queryForPageRemovePageWithIdentifier:(long long)identifier;

// Method: verbatmApp.page.updatePage
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPage.
+ (instancetype)queryForPageUpdatePageWithObject:(GTLVerbatmAppPage *)object;

#pragma mark - "pov" methods
// These create a GTLQueryVerbatmApp object.

// Method: verbatmApp.pov.getPagesFromPOV
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPageListWrapper.
+ (instancetype)queryForPovGetPagesFromPOVWithIdentifier:(long long)identifier;

// Method: verbatmApp.pov.getPOV
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPOV.
+ (instancetype)queryForPovGetPOVWithIdentifier:(long long)identifier;

// Method: verbatmApp.pov.getRecentPOVsInfo
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppResultsWithCursor.
+ (instancetype)queryForPovGetRecentPOVsInfoWithCount:(NSInteger)count
                                         cursorString:(NSString *)cursorString;

// Method: verbatmApp.pov.getTrendingPOVsInfo
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppResultsWithCursor.
+ (instancetype)queryForPovGetTrendingPOVsInfoWithCount:(NSInteger)count
                                           cursorString:(NSString *)cursorString;

// Method: verbatmApp.pov.insertPOV
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPOV.
+ (instancetype)queryForPovInsertPOVWithObject:(GTLVerbatmAppPOV *)object;

// Method: verbatmApp.pov.removePOV
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
+ (instancetype)queryForPovRemovePOVWithIdentifier:(long long)identifier;

// Method: verbatmApp.pov.updatePOV
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppPOV.
+ (instancetype)queryForPovUpdatePOVWithObject:(GTLVerbatmAppPOV *)object;

#pragma mark - "verbatmuser" methods
// These create a GTLQueryVerbatmApp object.

// Method: verbatmApp.verbatmuser.getUser
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppVerbatmUser.
+ (instancetype)queryForVerbatmuserGetUserWithIdentifier:(long long)identifier;

// Method: verbatmApp.verbatmuser.insertUser
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppVerbatmUser.
+ (instancetype)queryForVerbatmuserInsertUserWithObject:(GTLVerbatmAppVerbatmUser *)object;

// Method: verbatmApp.verbatmuser.removeUser
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
+ (instancetype)queryForVerbatmuserRemoveUserWithIdentifier:(long long)identifier;

// Method: verbatmApp.verbatmuser.updateUser
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppVerbatmUser.
+ (instancetype)queryForVerbatmuserUpdateUserWithObject:(GTLVerbatmAppVerbatmUser *)object;

#pragma mark - "video" methods
// These create a GTLQueryVerbatmApp object.

// Method: verbatmApp.video.getVideo
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppVideo.
+ (instancetype)queryForVideoGetVideoWithIdentifier:(long long)identifier;

// Method: verbatmApp.video.insertVideo
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppVideo.
+ (instancetype)queryForVideoInsertVideoWithObject:(GTLVerbatmAppVideo *)object;

// Method: verbatmApp.video.removeVideo
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
+ (instancetype)queryForVideoRemoveVideoWithIdentifier:(long long)identifier;

// Method: verbatmApp.video.updateVideo
//  Authorization scope(s):
//   kGTLAuthScopeVerbatmAppUserinfoEmail
// Fetches a GTLVerbatmAppVideo.
+ (instancetype)queryForVideoUpdateVideoWithObject:(GTLVerbatmAppVideo *)object;

@end
