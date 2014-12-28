//
//  Article.m
//  VerbatmProject
//
//  Created by DERY MWINMAARONG LUCIO on 8/19/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmUser.h"
#import "Article.h"
#import "Photo.h"
#import "Video.h"
#import "Page.h"
#import <Parse/PFRelation.h>
#import <Parse/PFObject+Subclass.h>

/*
 Created by: Lucio Dery
 Reviewed by: Iain Usiri
 */
@interface Article() <PFSubclassing>

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* subtitle;
@property(strong, nonatomic) NSString* content;
@property(strong, nonatomic) NSString* sandwich;
@property (strong, nonatomic) PFRelation * articleVideosRelation;
@property (strong, nonatomic) PFRelation * articlePhotosRelation;
@property (strong, nonatomic ) PFFile* pinchObjectFile;
@property (strong, nonatomic) NSArray* pages;

#define ARTICLE_PHOTO_RELATIONSHIP @"articlePhotoRelation"
#define ARTICLE_VIDEO_RELATIONSHIP @"articleVideoRelation"
#define ARTICLES @"articles"
#define LIKE @"likes"
#define VERBATM_USER_CLASSNAME @"VerbatmUser"
@end

@implementation Article
@dynamic sandwich;
@dynamic title;
@dynamic subtitle;
@dynamic content;

@synthesize articleVideosRelation= _articleVideosRelation;
@synthesize articlePhotosRelation = _articlePhotosRelation;
@synthesize pinchObjectFile = _pinchObjectFile;
@synthesize pages = _pages;

#pragma mark - initialising an article
/*by Lucio Dery */
//This creates an article object with a title and subtitle
-(instancetype)initWithTitle:(NSString *)title andSubtitle:(NSString*)subtitle andPages:(NSArray*)pages
{
    if((self = [super init]))
    {
        if(title || subtitle)
        {
            self.title = title;
            self.subtitle = subtitle;
        }
        _pages = pages;
    }
    return self;
}

#pragma mark - lazy instantiate the relationships

-(PFRelation *) articlePhotos
{
    if(!_articlePhotosRelation) _articlePhotosRelation = [self relationForKey:ARTICLE_PHOTO_RELATIONSHIP];
    return _articlePhotosRelation;
}

-(PFRelation *) articleVideos
{
    if(!_articleVideosRelation) _articleVideosRelation = [self relationForKey:ARTICLE_VIDEO_RELATIONSHIP];
    return _articleVideosRelation;
}

#pragma mark - adding content to the article

/*by Lucio Dery */
//adds a photo to the list of photos
-(void)addPhoto:(Photo*)photo
{
   if(photo) [self.articlePhotosRelation addObject:photo];
}

/*by Lucio Dery */
//This method adds a video to the article.
-(void)addVideo:(Video*)video
{
    if(video)[self.articleVideosRelation addObject:video];
}

/*by Lucio Dery */
//creates an s@ndwich given the two component strings in the right order
-(void)setSandwich:(NSString *)firstPart at:(NSString *)secondPart
{
    //need some security code to protect from any code injection.
    if(firstPart && secondPart) self.sandwich = [NSString stringWithFormat:@"%@ @ %@", firstPart, secondPart];
}

/*by Lucio Dery */
//sets the content of the Article. The content must correspond to the right format
-(void) setArticleContent:(NSString *)content
{
    content = [self formatContent:content];
    if(content)self.content = content;
}


#pragma mark - content retreival and querrying


/*by Lucio Dery */
/*Edited by Iain*/
//this method gets the all the photo objects associated with an article
-(PFQuery *)getPhotos
{
    PFRelation* photoArticleRelation = [self relationForKey:ARTICLE_PHOTO_RELATIONSHIP];
    PFQuery* photosQuery = [photoArticleRelation query];
    return photosQuery;
}

/*by Lucio Dery */
/*Edited by Iain*/
//This method gets all the video objects associated with an article
-(PFQuery*)getVideos
{
    PFRelation* videoArticleRelation = [self relationForKey: ARTICLE_VIDEO_RELATIONSHIP];
    PFQuery* videosQuery = [videoArticleRelation query];
    return videosQuery;
}

/*by Lucio Dery */
/*Edited by Iain*/
//gets the author of the article.
-(PFQuery *)author
{
    PFQuery* queryAuthor = [PFQuery queryWithClassName:VERBATM_USER_CLASSNAME];
    [queryAuthor whereKey:ARTICLES equalTo:self];
    return queryAuthor;
}

/*by Lucio Dery*/
/*Edited by Iain*/
//returns the number of likes that an article has
-(PFQuery*)numberOfLikes
{
    PFQuery* queryLikes = [PFQuery queryWithClassName:VERBATM_USER_CLASSNAME];
    [queryLikes whereKey:LIKE equalTo:self];
    return queryLikes;
}


#pragma mark - helper methods

/*Author: Lucio*/
-(NSString *)formatContent: (NSString*)contentString
{
    //to be implemented when the format for the content is decided
    //return nil if something goes wrong
    return contentString;
}

-(bool)isRightUrlFormat:(NSURL*)URL
{
    //put in check for any url formats that may be acceptable.
    return YES;
}


#pragma mark - Methods required for subclassing PFObject.

+(NSString *)parseClassName
{
    return @"Article";
}

+(void)load{
    [self registerSubclass];
}

#pragma mark - adding Pinch Objects -

-(void)setPinchObjects:(NSMutableArray *)p_objs
{
    NSData* pObj_Data = [NSKeyedArchiver archivedDataWithRootObject:p_objs];
    _pinchObjectFile = [PFFile fileWithData:pObj_Data];
}

-(NSArray*)getPinchObjects
{
    NSData* data = [_pinchObjectFile getData];
    NSArray* to_return = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return to_return;
}
@end

