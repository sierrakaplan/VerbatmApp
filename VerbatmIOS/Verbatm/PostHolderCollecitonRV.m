//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <Parse/PFObject.h>
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PostHolderCollecitonRV.h"

@interface PostHolderCollecitonRV ()
    @property (nonatomic, readwrite) POVView * ourCurrentPOV;
    @property (nonatomic) PFObject * postBeingPresented;
    @property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

@end

@implementation PostHolderCollecitonRV



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self.activityIndicator startAnimating];
    return self;
}


-(void)presentPOV:(POVView *)pov{
    if(pov != self.ourCurrentPOV){
        [self.ourCurrentPOV povOffScreen];
        [self.ourCurrentPOV removeFromSuperview];
        self.ourCurrentPOV = pov;
        [self addSubview:self.ourCurrentPOV];
    }
}

-(void)presentPost:(PFObject *) postObject{
    if(postObject != self.postBeingPresented){
        self.postBeingPresented = postObject;
        [Page_BackendObject getPagesFromPost:postObject andCompletionBlock:^(NSArray * pages) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });
            [self.ourCurrentPOV clearArticle];//make sure there is no other stuff
            [self.ourCurrentPOV renderPOVFromPages:pages];
            [self.ourCurrentPOV scrollToPageAtIndex:0];//this prepares the
            
            NSNumber * numberOfPostLikes = [postObject valueForKey:POST_LIKES_NUM_KEY];
            NSNumber * numberOfPostShares = [postObject valueForKey:POST_NUM_SHARES_KEY];
            NSNumber * numberOfPostPages =[NSNumber numberWithInteger:pages.count];
            [self.ourCurrentPOV createLikeAndShareBarWithNumberOfLikes:numberOfPostLikes numberOfShares:numberOfPostShares numberOfPages:numberOfPostPages andStartingPageNumber:@(1) startUp:self.isHomeProfileOrFeed];
        }];
    }
}
-(void)onScreen{
    if(self.ourCurrentPOV){
        [self.ourCurrentPOV povOnScreen];
    }
}

-(void)offScreen{
    if(self.ourCurrentPOV){
        [self.ourCurrentPOV povOffScreen];
    }
}


#pragma mark -lazy instantiation-
-(POVView *) ourCurrentPOV{
    if(!_ourCurrentPOV){
        _ourCurrentPOV = [[POVView alloc] initWithFrame:self.bounds andPovParseObject:nil];
        [self addSubview:_ourCurrentPOV];
    }
    return _ourCurrentPOV;
}

-(UIActivityIndicatorView*) activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicator.color = [UIColor grayColor];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = CGPointMake(self.center.x, self.frame.size.height * 1.f/3.f);
        [self.contentView addSubview:_activityIndicator];
        [self.contentView bringSubviewToFront:_activityIndicator];
    }
    return _activityIndicator;
}
@end
