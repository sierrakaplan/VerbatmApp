//
//  Video.h
//  Verbatm
//
//  Created by Iain Usiri on 8/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//


#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
@class Article;
@class VerbatmUser;
@class Page;

@interface Video : PFObject
#pragma mark - Required Subclassing methods
+(NSString*)parseClassName;
+(void)load;
#pragma mark - create video object
//Creates an instance of the video class using video file data, article and caption.
//-(instancetype)initWithData:(NSData*)data withCaption:(NSString*)caption andName:(NSString*)name atLocation:(CLLocation*)location;

//Creates an instance of the video with a url, article and caption.
-(instancetype)initWithURL:(NSURL*)url withCaption:(NSString*)caption andName:(NSString*)name atLocation:(CLLocation*)location;

#pragma mark - fetch arguments from video object
-(NSURL*)getVideoUrl;
@property(strong, nonatomic, readonly)NSString* caption;
@property(strong, nonatomic, readonly)NSURL* url;//could be nil if it's a video file data
@property(strong, nonatomic, readonly)CLLocation* location;
@property(strong, nonatomic, readonly)NSString* name;

/*by Lucio Dery*/
//gets the article of which the video is part
/*
 e.g.
 [queryArticle findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if(!error){
        NSLog(@"Successfully retrieved %d scores.", objects.count);
        parentArticle = [objects firstObject];
    }else{
        NSLog(@"Error: %@ %@", error, [error userInfo]);   //Error handling may be done in a different way
    }
 }];*/
-(PFQuery *)parentArticle;
@end