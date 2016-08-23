//
//  NotificationPostPreview.m
//  Verbatm
//
//  Created by Iain Usiri on 7/6/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "NotificationPostPreview.h"
#import "Page_BackendObject.h"
#import "Icons.h"
#import "Like_BackendManager.h"
#import "Share_BackendManager.h"
#import "CustomNavigationBar.h"
#import "Styles.h"
#import "SizesAndPositions.h"
#import "ParseBackendKeys.h"
#import <Parse/PFQuery.h>
#import "LoadingIndicator.h"

@interface NotificationPostPreview () <CustomNavigationBarDelegate, PostViewDelegate>
@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;

@property (nonatomic) UIView * customNavBar;
@property (nonatomic) UIActivityIndicatorView *loadingIndicator;

#define HEADER_HEIGHT 40.f
@property (nonatomic) UIButton * tempCancelButton;
@end


@implementation NotificationPostPreview
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if(self){
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)createNavBar{
	CGRect customBarFrame = CGRectMake(0.f, 0.f, self.frame.size.width, HEADER_HEIGHT);
	self.customNavBar = [[UIView alloc] initWithFrame:customBarFrame];
	[self.customNavBar setBackgroundColor:PROFILE_INFO_BAR_BACKGROUND_COLRO];

	CustomNavigationBar * navBar = [[CustomNavigationBar alloc] initWithFrame:customBarFrame andBackgroundColor:[UIColor clearColor]];
	[navBar createLeftButtonWithTitle:nil orImage:[UIImage imageNamed:PROFILE_BACK_BUTTON_ICON]];
	navBar.delegate = self;

	[self.customNavBar addSubview:navBar];
	[self addSubview:self.customNavBar];
}

-(void)clearViews{
	[self.currentPostView clearPost];
	[self.currentPostView removeFromSuperview];
	self.currentPostView = nil;
	[self.customNavBar removeFromSuperview];
	self.customNavBar = nil;
}

-(void)getAndPresentPost:(PFObject *) pfActivityObj andChannel:(Channel *) channel{
    self.postBeingPresented = pfActivityObj;
    PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
    [post fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if(object){
            [Page_BackendObject getPagesFromPost:object andCompletionBlock:^(NSArray * pages) {
                self.currentPostView = [[PostView alloc] initWithFrame:self.bounds
                                          andPostChannelActivityObject:pfActivityObj small:NO andPageObjects:pages];
                self.currentPostView.delegate = self;
                
                NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
                self.currentPostView.listChannel = channel;
                [self addSubview: self.currentPostView];
                self.currentPostView.inSmallMode = NO;
                NSNumber *numLikes = object[POST_NUM_LIKES];
                NSNumber *numShares = object[POST_NUM_REBLOGS];
                NSNumber *numComments = object[POST_NUM_COMMENTS];
                [self.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares numberOfComments:numComments numberOfPages:numberOfPages andStartingPageNumber:@(1) startUp:NO withDeleteButton:NO];
                [self.currentPostView addCreatorInfo];
                
                [self.currentPostView postOnScreen];
                [self bringSubviewToFront:self.customNavBar];
                [self.loadingIndicator stopAnimating];
            }];
        }
    }];
}

-(void)presentPost:(PFObject *) postObject andChannel:(Channel *) channel{
    PFQuery * query = [PFQuery queryWithClassName:POST_CHANNEL_ACTIVITY_CLASS];
    [query whereKey:POST_CHANNEL_ACTIVITY_POST equalTo:postObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self getAndPresentPost:[objects firstObject] andChannel:channel];
    }];
    [self.loadingIndicator startAnimating];
}

#pragma mark -POVDelegate-


-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post{
    
}
-(void) channelSelected:(Channel *) channel{
    
}
-(void) deleteButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post reblogged: (BOOL)reblogged{
    
}

-(void) flagButtonSelectedOnPostView:(PostView *) postView withPostObject:(PFObject*)post{
    
}
-(void) showWhoLikesThePost:(PFObject *) post{
    [self.delegate showWhoLikesThePostFromNotifications:post];
}

-(void)removePostViewSelected{
    [self.delegate exitPreview];
}

-(void)presentSmallLikeButton{
    
}


-(void)updateSmallLikeButton:(BOOL)isLiked{
    
}
-(void)startLikeButtonAsLiked:(BOOL)isLiked{
    
}
-(void)showWhoCommentedOnPost:(PFObject *) post{
    [self.delegate presentCommentListForPost:post];
}



-(UIActivityIndicatorView *) loadingIndicator {
    if(!_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        _loadingIndicator.center = self.center;
        _loadingIndicator.hidesWhenStopped = YES;
        [self addSubview:_loadingIndicator];
    }
    [self bringSubviewToFront:_loadingIndicator];
    return _loadingIndicator;
}



@end
