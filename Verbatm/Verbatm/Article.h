//
//  Article.h
//  Verbatm
//
//  Created by Iain Usiri on 8/20/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class Photo;
@class Video;
@class VerbatmUser;

/*Class implemented by Lucio Dery*/

@interface Article : PFObject

#pragma mark - Required methods for subclassing PFObject:
+(NSString*)parseClassName;
+(void)load;

#pragma mark - article creation and edit
/*Note that the save call was removed. Call it externally*/

//This creates an article object with a title and a subtitle.
-(instancetype)initWithTitle:(NSString *)title andSubtitle:(NSString*)subtitle;

//sets the content of the Article. The content must correspond to the right format
-(void) setArticleContent:(NSString *)content;

//creates an s@ndwich given the two component strings in the right order
-(void)setSandwich:(NSString*)firstPart at: (NSString*)secondPart;

//adds a photo to the list of photos
-(void)addPhoto:(Photo*)photo;

//adds a video to the list of videos of the article.
-(void)addVideo:(Video*)video;


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

//returns the querry to get the exact information you want. Call as is shown below:
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
