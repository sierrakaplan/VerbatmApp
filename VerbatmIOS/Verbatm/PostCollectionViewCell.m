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
#import "PostCollectionViewCell.h"

@interface PostCollectionViewCell ()

@property (nonatomic, readwrite) PostView *ourCurrentPost;
@property (nonatomic) PFObject *postBeingPresented;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    //[self.activityIndicator startAnimating];
    return self;
}

-(void)presentPOV:(PostView *)pov{
    if(pov != self.ourCurrentPost){
        [self.ourCurrentPost postOffScreen];
        [self.ourCurrentPost removeFromSuperview];
        self.ourCurrentPost = pov;
        [self addSubview:self.ourCurrentPost];
    }
}

-(void)presentPost:(PFObject *) postObject{
    if(postObject != self.postBeingPresented){
        self.postBeingPresented = postObject;
        [Page_BackendObject getPagesFromPost:postObject andCompletionBlock:^(NSArray * pages) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });
            [self.ourCurrentPost clearArticle];//make sure there is no other stuff
            [self.ourCurrentPost renderPostFromPages:pages];
            [self.ourCurrentPost scrollToPageAtIndex:0];//this prepares the
            
            NSNumber * numberOfPostLikes = [postObject valueForKey:POST_LIKES_NUM_KEY];
            NSNumber * numberOfPostShares = [postObject valueForKey:POST_NUM_SHARES_KEY];
            NSNumber * numberOfPostPages =[NSNumber numberWithInteger:pages.count];
            [self.ourCurrentPost createLikeAndShareBarWithNumberOfLikes:numberOfPostLikes numberOfShares:numberOfPostShares numberOfPages:numberOfPostPages andStartingPageNumber:@(1) startUp:self.isHomeProfileOrFeed];
        }];
    }
}
-(void)onScreen{
    if(self.ourCurrentPost){
        [self.ourCurrentPost postOnScreen];
    }
}

-(void)offScreen{
    if(self.ourCurrentPost){
        [self.ourCurrentPost postOnScreen];
    }
}

#pragma mark - Lazy Instantiation -

-(PostView *) ourCurrentPost{
    if(!_ourCurrentPost){
        _ourCurrentPost = [[PostView alloc] initWithFrame:self.bounds andPostParseObject:nil];
        [self addSubview:_ourCurrentPost];
    }
    return _ourCurrentPost;
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
