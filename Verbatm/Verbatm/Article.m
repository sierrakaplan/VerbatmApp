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
@property (strong,readwrite,nonatomic) NSString* title;
@property(strong,readwrite, nonatomic) NSString* content;
@property(strong, readwrite,nonatomic) NSString* sandwich;
@property(strong,readwrite, nonatomic) NSString* whatSandwich;
@property(strong,readwrite, nonatomic) NSString* whereSandwich;
@property(readwrite, nonatomic) BOOL isTestingArticle;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) PFRelation * articleVideosRelation;
@property (strong, nonatomic) PFRelation * articlePhotosRelation;
@property (strong, nonatomic) PFRelation* article_pageRelationship;
@property (strong, nonatomic ) PFFile* pinchObjectFile;

#define ARTICLE_PAGE_RELATIONSHIP @"articlePageRelation"
#define ARTICLE_VIDEO_RELATIONSHIP @"articleVideoRelation"
#define ARTICLE_PHOTO_RELATIONSHIP @"articlePhotoRelation"
#define ARTICLE_AUTHOR_RELATIONSHIP @"articleAuthorRelation"
#define ARTICLES @"articles"
#define ARTICLE_COLUMN @"Article"
#define LIKE @"likes"
#define VERBATM_USER_CLASSNAME @"VerbatmUser"
@end

@implementation Article
@dynamic sandwich;
@dynamic whatSandwich;
@dynamic whereSandwich;
@dynamic title;
@dynamic content;
@dynamic isTestingArticle;

@synthesize articleVideosRelation= _articleVideosRelation;
@synthesize articlePhotosRelation = _articlePhotosRelation;
@synthesize pinchObjectFile = _pinchObjectFile;
@synthesize article_pageRelationship = _article_pageRelationship;

#pragma mark - initialising an article
/*by Lucio Dery */
//This creates an article object with a title and subtitle, and pages as well as saves the article.
//relations can only be created between saved objects thus the need to save the article and pages before creating the article-page relations.
-(instancetype)initAndSaveWithTitle:(NSString *)title  andSandWichWhat:(NSString *)what  Where:(NSString *)where  andPinchObjects:(NSArray*)pages andIsTesting:(BOOL)isTesting
{
    if((self = [super init])) {
		self.isTestingArticle = isTesting;
        if(title) {
            self.title = title;
        }
        if (what && where) {
            [self setSandwich:what at:where];
        }
        PFUser * currentUser = [PFUser currentUser];
        self.username = currentUser.username;
        [self setObject:[PFUser currentUser]forKey: ARTICLE_AUTHOR_RELATIONSHIP];
        [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                [self processAndSavePages:pages];
                NSLog(@"Saved Article Successfully");
            }
        }];
    }
    return self;
}

/*returns the user that created the article*/
-(NSString *)getAuthorUsername{
    NSString * userName = self.username;
    return @"user name";
}

/*This function takes an array of pinch objects as the only parameter.
 Each pinch object is converted into a page which is then saved to parse*/
-(void)processAndSavePages:(NSArray*)pages {
    for(int i=0; i< pages.count; i++) {
        Page* this_page = [[Page alloc]initWithPinchObject:pages[i] Article:self andPageNumber:i];
            [this_page saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded) {
                NSLog(@"Saved Page Successfully");
            }else {
                NSLog(@"Could not save page: %@", [error localizedDescription]);
            }
        }];
    }
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
-(void)setSandwich:(NSString *)what at:(NSString *)where
{
    //need some security code to protect from any code injection.
    if(what && where) {
		self.sandwich = [NSString stringWithFormat:@"%@ @ %@", what, where];
		self.whatSandwich = what;
		self.whereSandwich = where;
	}
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


#pragma mark - Methods required for subclassing PFObject.

+(NSString *)parseClassName{
    return @"Article";
}

+(void)load{
    [self registerSubclass];
}

#pragma mark - getting the pages -

-(NSArray*)getAllPages {
    PFQuery* pageQuery = [PFQuery queryWithClassName:@"Page"];
    [pageQuery whereKey:ARTICLE_COLUMN equalTo:self];
    return [pageQuery findObjects];
}
@end

