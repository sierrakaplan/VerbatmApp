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
@interface NotificationPostPreview () <CustomNavigationBarDelegate>
@property (nonatomic, readwrite) PFObject *currentPostActivityObject;
@property (nonatomic, readwrite) PostView *currentPostView;

@property (nonatomic) PFObject *postBeingPresented;

@property (nonatomic) UIView * customNavBar;
#define NAV_BAR_HEIGHT 40.f
@end


@implementation NotificationPostPreview


-(void)createNavBar{
    CGRect customBarFrame = CGRectMake(0.f, 0.f, self.frame.size.width, NAV_BAR_HEIGHT +STATUS_BAR_HEIGHT);
    CGRect navFrame = CGRectMake(0.f, STATUS_BAR_HEIGHT, self.frame.size.width, NAV_BAR_HEIGHT);
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
-(void)leftButtonPressed{
    [self.delegate exitPreview];
}


-(void)presentPost:(PFObject *) pfActivityObj andChannel:(Channel *) channel{
    self.postBeingPresented = pfActivityObj;
    NSLog([pfActivityObj parseClassName]);
    
    PFObject * post = [pfActivityObj objectForKey:POST_CHANNEL_ACTIVITY_POST];
    
    [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
        self.currentPostView = [[PostView alloc] initWithFrame:self.bounds
                                  andPostChannelActivityObject:pfActivityObj small:NO andPageObjects:pages];
        
      //  NSNumber * numberOfPages = [NSNumber numberWithInteger:pages.count];
        self.currentPostView.listChannel = channel;
        [self addSubview: self.currentPostView];
        self.currentPostView.inSmallMode = NO;
        
//        AnyPromise *likesPromise = [Like_BackendManager numberOfLikesForPost:post];
//        AnyPromise *sharesPromise = [Share_BackendManager numberOfSharesForPost:post];
//        PMKWhen(@[likesPromise, sharesPromise]).then(^(NSArray *likesAndShares) {
//            NSNumber *numLikes = likesAndShares[0];
//            NSNumber *numShares = likesAndShares[1];
//            [self.currentPostView createLikeAndShareBarWithNumberOfLikes:numLikes numberOfShares:numShares
//                                                           numberOfPages:numberOfPages
//                                                   andStartingPageNumber:@(1)
//                                                                 startUp:NO
//                                                        withDeleteButton:NO];
//            [self.currentPostView addCreatorInfo];
//        });
        [self.currentPostView postOnScreen];
        [self createNavBar];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
