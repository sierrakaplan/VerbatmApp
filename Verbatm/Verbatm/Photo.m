//
//  Photo.m
//  Verbatm
//
//  Created by Iain Usiri on 8/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

/*Class implemented by Lucio Dery*/
#import "Photo.h"
#import "Article.h"
#import "VerbatmUser.h"

@interface Photo() <PFSubclassing>

@property(strong, nonatomic, readwrite)PFFile* photoDataFile;
@property(strong, nonatomic, readwrite)NSString* caption;
@property(strong, nonatomic, readwrite)NSString* title;
@property(strong, nonatomic, readwrite)CLLocation* location;
@property (strong, nonatomic, readwrite)NSString * name;

#define ARTICLE_PHOTO_RELATIONSHIP @"ArticlePhotoRelation"
@end

@implementation Photo
@dynamic photoDataFile;
@dynamic location;
@dynamic title;
@dynamic caption;
@dynamic name;

#pragma  mark - initializer

/*By Lucio Dery*/
//Returns an instance of the article class. Initialized with data, a title and a caption.
-(instancetype)initWithData:(NSData*)data
                withCaption:(NSString*)caption
                    andName:(NSString*)name
                 atLocation:(CLLocation*)location
{
    if((self = [super init])){
        self.photoDataFile = [PFFile fileWithData:data];
        self.caption = caption;
        self.title = name;
        self.location = location;
    }
    return self;
}

#pragma mark - Retrieval



/*By Lucio Dery*/
/*edited by Iain Usiri*/
// This method returns the query for the information required
-(PFQuery *)parentArticle
{
    PFQuery* queryArticle = [PFQuery queryWithClassName:@"Article"];
    [queryArticle whereKey:ARTICLE_PHOTO_RELATIONSHIP equalTo: self];
    return queryArticle;
    
}

#pragma mark - getting photo back -
-(UIImage*)getPhoto
{
    UIImage* image = [UIImage imageWithData: [self.photoDataFile getData]];
    return image;
}

#pragma mark - Required Subclassing methods

+(void)load
{
    [self registerSubclass];
}

+(NSString*)parseClassName
{
    return @"Photo";
}

@end
