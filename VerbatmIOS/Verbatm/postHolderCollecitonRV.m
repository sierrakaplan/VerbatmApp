//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "POVView.h"
#import "postHolderCollecitonRV.h"

@interface postHolderCollecitonRV ()
    @property (nonatomic) POVView * ourCurrentPOV;
    @property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;

@end

@implementation postHolderCollecitonRV



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self.activityIndicator startAnimating];
    return self;
}

-(void)presentPages:(NSMutableArray *) aves startingAtIndex:(NSInteger) startIndex {
    if(aves){
        [self.ourCurrentPOV clearArticle];//make sure there is no other stuff
        [self.ourCurrentPOV renderAVES:aves];
        [self.ourCurrentPOV scrollToPageAtIndex:startIndex];
    }
}




#pragma mark -lazy instantiation-
-(POVView *) ourCurrentPOV{
    if(!_ourCurrentPOV) _ourCurrentPOV = [[POVView alloc] initWithFrame:self.bounds andPOVInfo:nil];
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
