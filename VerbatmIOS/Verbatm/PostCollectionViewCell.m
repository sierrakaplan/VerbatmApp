//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Like_BackendManager.h"
#import <Parse/PFObject.h>
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "PostCollectionViewCell.h"
#import "Share_BackendManager.h"

@interface PostCollectionViewCell ()

@property (nonatomic, readwrite) PostView *ourCurrentPost;
@property (nonatomic) PFObject *postBeingPresented;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation PostCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}

-(void) prepareForReuse {
}

-(void) presentPostView:(PostView *)postView{
    if(postView != self.ourCurrentPost){
        [self.ourCurrentPost postOffScreen];
        [self.ourCurrentPost removeFromSuperview];
        self.ourCurrentPost = postView;
        [self addSubview:self.ourCurrentPost];
    }
}

-(void)onScreen{
    if(self.ourCurrentPost){
        [self.ourCurrentPost postOnScreen];
    }
}

-(void)offScreen{
    if(self.ourCurrentPost){
        [self.ourCurrentPost postOffScreen];
    }
}

#pragma mark - Lazy Instantiation -

-(PostView *) ourCurrentPost{
    if(!_ourCurrentPost){
        _ourCurrentPost = [[PostView alloc] initWithFrame:self.bounds andPostChannelActivityObject:nil small:NO];
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
