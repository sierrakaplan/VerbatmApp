//
//  Analytics.m
//  Verbatm
//
//  Created by Iain Usiri on 10/20/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "Analytics.h"
#import <Parse/PFAnalytics.h>
#import <Parse/PFUser.h>

@interface Analytics ()

//title of the article that is currently being viewed
//if an article is not open then this is nil
@property (strong, nonatomic) NSString * currentArticleTitle;
//index of current page being viewed
@property (nonatomic) NSInteger currentPageIndex;
/*Note that all time is in seconds. We divide by 60 before saving to get it all in minutes*/
@property (nonatomic) CGFloat userSessionStartTime;
@property (nonatomic) CGFloat pageViewStartTime;
@property (nonatomic) CGFloat adkSessionStartTime;
@property (nonatomic) CGFloat storyViewStartTime;
@property (nonatomic) NSInteger numberOfStoriesRead;//number of stories opened in one session
@end

@implementation Analytics


+ (id)getSharedInstance {
    static Analytics *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Analytics alloc] init];
        
    });
    return sharedInstance;
}


//called in a pair
//the titles are compared to make sure we're logging the right story
-(void) storyStartedViewing:(NSString *) articleTitle{
    self.storyViewStartTime = CACurrentMediaTime();
    self.currentArticleTitle = articleTitle;
    self.numberOfStoriesRead++;
}


-(void) storyEndedViewing{
     if(![PFUser currentUser] || !self.currentArticleTitle) return;
    
    CGFloat timeSpent_mins = (CACurrentMediaTime() - self.storyViewStartTime)/60;
    NSDictionary *dimensions = @{
                                 //article title
                                 @"articleTitle": self.currentArticleTitle,
                                 @"totalTimeSpent": [[NSNumber numberWithFloat:timeSpent_mins] stringValue],
                                 @"username" : [[PFUser currentUser] username]
                                 };
    // Send the dimensions to Parse for the 'POV' event
    [PFAnalytics trackEvent:@"POV" dimensions:dimensions];
}

//called in a pair
//the titles and page indexes are compared to make sure we're logging the right story
//allows us to track how long the user spends on each page
-(void) pageStartedViewingWithIndex: (NSInteger) pageIndex {
    self.pageViewStartTime = CACurrentMediaTime();
    self.currentPageIndex = pageIndex;

}
-(void) pageEndedViewingWithIndex: (NSInteger) pageIndex aveType: (NSString *) aveType{
    if(self.currentPageIndex != pageIndex) return;
    if(![PFUser currentUser] || !self.currentArticleTitle) return;
    CGFloat timeSpent_mins = (CACurrentMediaTime() - self.pageViewStartTime)/60;
    
    NSDictionary *dimensions = @{@"articleTitle": self.currentArticleTitle,
                                 @"totalTimeSpentOnPage": [[NSNumber numberWithFloat:timeSpent_mins] stringValue],
                                 @"username" : [[PFUser currentUser] username],
                                 @"pageIndex" : [[NSNumber numberWithInteger:pageIndex] stringValue],
                                 @"aveType": aveType
                                };
    [PFAnalytics trackEvent:@"POVPageViews" dimensions:dimensions];
}

//called in pair
//we track how long the user spends on the app per session (a session is everytime the app is in the forground)
-(void) newUserSession{
    self.userSessionStartTime = CACurrentMediaTime();
}
-(void)endOfUserSession{
    if(![PFUser currentUser])return;
    if(self.userSessionStartTime == 0) return;//prevents this method being called twice without newUserS being called 
    CGFloat timeSpent_mins = (CACurrentMediaTime() - self.userSessionStartTime)/60;
    NSDictionary *dimensions = @{@"username" : [[PFUser currentUser] username],
                                 @"totalTimeSpent" : [[NSNumber numberWithFloat:timeSpent_mins] stringValue],
                                 @"numerOfStoriesRead" : [[NSNumber numberWithInteger:self.numberOfStoriesRead] stringValue]
                                 };
    // Send the dimensions to Parse along with the 'search' event
    [PFAnalytics trackEvent:@"UserSession" dimensions:dimensions];
    self.userSessionStartTime = 0;
}

//called in a pair
//we track how long the user spends per creation session on the ADK
//for now this means from initial media caputre to final publish -- not that this must be in the same userSession
-(void)newADKSession{
    if(self.adkSessionStartTime != 0) return;
    self.adkSessionStartTime = CACurrentMediaTime();
}

-(void)endOfADKSession{
    if(self.adkSessionStartTime == 0) return;
    
    CGFloat timeSpent_mins = (CACurrentMediaTime() - self.userSessionStartTime)/60;
    NSDictionary *dimensions = @{
                                 @"totalTimeSpent":[[NSNumber numberWithFloat:timeSpent_mins] stringValue],
                                 @"username" : [[PFUser currentUser]username],
                                 };
    // Send the dimensions to Parse along with the 'search' event
    [PFAnalytics trackEvent:@"ADKSession" dimensions:dimensions];
    self.adkSessionStartTime = 0;
}





@end
