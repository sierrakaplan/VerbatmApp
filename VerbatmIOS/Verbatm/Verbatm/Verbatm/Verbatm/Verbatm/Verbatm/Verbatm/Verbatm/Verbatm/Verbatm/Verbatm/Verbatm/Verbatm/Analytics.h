//
//  Analytics.h
//  Verbatm
//
//  Created by Iain Usiri on 10/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

//before you call any function be sure to get the shared instance 
+ (id)getSharedInstance;


//called in a pair
//the titles are compared to make sure we're logging the right story
-(void) storyStartedViewing:(NSString *) articleTitle;
-(void) storyEndedViewing;

//called in a pair
//the titles and page indexes are compared to make sure we're logging the right story
//allows us to track how long the user spends on each page
-(void) pageStartedViewingWithIndex: (NSInteger) pageIndex;
-(void) pageEndedViewingWithIndex: (NSInteger) pageIndex aveType: (NSString *) aveType;

//called in pair
//we track how long the user spends on the app per session (a session is everytime the app is in the forground)
-(void) newUserSession;
-(void)endOfUserSession;

//called in a pair
//we track how long the user spends per creation session on the ADK
//for now this means from initial media caputre to final publish -- not that this must be in the same userSession
-(void)newADKSession;
-(void)endOfADKSession;

@end
