//
//  Video.m
//  Verbatm
//
//  Created by Iain Usiri on 8/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "Video.h"
#import "Article.h"
#import "VerbatmUser.h"

@interface Video() <PFSubclassing>
@property(strong, nonatomic, readwrite)NSString* caption;
@property(strong, nonatomic, readwrite)NSString* name;
@property(strong, nonatomic, readwrite)NSURL* url;
@property(strong, nonatomic, readwrite)CLLocation* location;
@property (strong, nonatomic ) PFFile* videoDataFile;

#define ARTICLE_VIDEO_RELATIONSHIP @"ArticleVideoRelation"
@end

@implementation Video
@dynamic videoDataFile;
@dynamic location;
@dynamic url;
@dynamic caption;
@dynamic name;

#pragma  mark - initializers

/*by Lucio Dery*/
//initialises a Video object using data , a caption and a name.
-(instancetype)initWithData:(NSData*)data
                withCaption:(NSString*)caption
                    andName:(NSString*)name
                 atLocation:(CLLocation*)location
{
    if((self = [super init])){
        self.videoDataFile = [PFFile fileWithData:data];
        self.caption = caption;
        self.name = name;
        self.location = location;
    }
    return self;
}

/*by Lucio Dery*/
//Initialises the Video object using a url name and caption
-(instancetype)initWithURL:(NSURL*)url
               withCaption:(NSString*)caption
                   andName:(NSString*)name
                atLocation:(CLLocation*)location
{
    if((self = [super init])){
        self.url = url;
        self.caption = caption;
        self.name = name;
    }
    return self;
}


#pragma mark - Retrieval

/*By Lucio Dery*/
//Returns the video's location
-(CLLocation*)getLocation
{
    return self.location;
}

/*by Lucio Dery*/
//gets the article of which the video is part

-(PFQuery *)parentArticle
{
    PFQuery* queryArticle = [PFQuery queryWithClassName:@"Article"];
    [queryArticle whereKey:ARTICLE_VIDEO_RELATIONSHIP equalTo: self];
    return queryArticle;
}


#pragma mark - getting data back - 

-(NSData*) getVideoData {
	if (self.videoDataFile) {
		return [self.videoDataFile getData];
	}
	return nil;
}

-(NSURL*)getVideoUrl
{
	if (self.videoDataFile) {
		return [[NSURL alloc] initWithString:self.videoDataFile.url];
	}
    return self.url;
}

#pragma mark - Required Subclassing methods

/*by Lucio Dery*/
+(void)load
{
    [self registerSubclass];
}

/*by Lucio Dery*/
+(NSString*)parseClassName
{
    return @"Video";
}

@end
