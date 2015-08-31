//
//  Photo.h
//  Verbatm
//
//  Created by Iain Usiri on 8/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
@class VerbatmUser;
@class Article;
@class Page;


@interface Photo : PFObject 
/*removed the save call*/

#pragma mark - required subclassing methods
+(NSString*)parseClassName;
+(void)load;

#pragma mark - creating a photo object
//Creates an instance of the photo class using the data, article and caption.
-(instancetype)initWithData:(NSData*)data withCaption:(NSString*)caption andName:(NSString*)name atLocation:(CLLocation*)location;

#pragma mark - get values for photo
//These get the instance variables from a photo object.
-(UIImage*)getPhoto;
@property(strong, nonatomic, readonly)NSString* caption;
@property(strong, nonatomic, readonly)NSString* title;
@property(strong, nonatomic, readonly)CLLocation* location;
@property (strong, nonatomic, readonly)NSString * name;

// This method returns the query for the information required
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