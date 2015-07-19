//
//  Article.h
//  Verbatm
//
//  Created by Iain Usiri on 8/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Foundation/Foundation.h>
@class Photo;
@class Video;
@class Page;
@class VerbatmUser;

/*Class implemented by Lucio Dery*/

@interface Article : PFObject

@property (strong,readonly, nonatomic) NSString* title;
//@property (strong,readonly, nonatomic) NSString* subtitle;
@property(strong, readonly,nonatomic) NSString* content;
@property(strong,readonly, nonatomic) NSString* sandwich;
@property(strong,readonly, nonatomic) NSString* whatSandwich;
@property(strong,readonly, nonatomic) NSString* whereSandwich;
@property(readonly, nonatomic) BOOL isTestingArticle;

#pragma mark - Required methods for subclassing PFObject:
+(NSString*)parseClassName;
+(void)load;

#pragma mark - article creation and edit


/*Get's all the pages from the Article*/
//this method blocks
-(NSArray*)getAllPages;

//get the author of an article
-(NSString *)getAuthor;

-(instancetype)initAndSaveWithTitle:(NSString *)title  andSandWichWhat:(NSString *)what  Where:(NSString *)where  andPinchObjects:(NSArray*)pages andIsTesting:(BOOL)isTesting;

//sets the content of the Article. The content must correspond to the right format
//-(void) setArticleContent:(NSString *)content;

//-(void)setArticleTitle:(NSString *)title;

//creates an s@ndwich given the two component strings in the right order
-(void)setSandwich:(NSString*)firstPart at: (NSString*)secondPart;

//adds a photo to the list of photos
-(void)addPhoto:(Photo*)photo;

//adds a video to the list of videos of the article.
-(void)addVideo:(Video*)video;

//-(void)setPinchObjects:(NSMutableArray*)p_objs;


#pragma mark - querry articles for information
//returns the querry to get the exact information you want. Call as is shown below:
/*
 e.g
 [[articleobject getPhotos] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if(!error){
        //do something
     }else{
        //do something
     }
 }];*/
-(PFQuery *)getPhotos;


//returns the querry to get the exact information you want. Call as is shown below:
/*
 e.g
 [videosQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if(!error)
     {
        //do something
     }else
     {
        //do something
     }
 }];*/

-(PFQuery*)getVideos;

//returns the query to get the exact information you want. Call as is shown below:
/*
e.g:
 [queryLikes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if(!error){
         NSLog(@"Successfully retrieved %d authors", objects.count);
         numLikes = [objects count];
     }else{
         NSLog(@"Error: %@ %@", error, [error userInfo]);   //Error handling may be done in a different way
     }
 }];*/

-(PFQuery*)numberOfLikes;


//returns the querry to get the exact information you want. Call as is shown below:
/*
 e.g.
 [queryAuthor findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if(!error){
        NSLog(@"Successfully retrieved %d authors", objects.count);
        author = [objects firstObject];
    }else{
        NSLog(@"Error: %@ %@", error, [error userInfo]);   //Error handling may be done in a different way
    }
 }];*/

-(PFQuery *)author;

@end
