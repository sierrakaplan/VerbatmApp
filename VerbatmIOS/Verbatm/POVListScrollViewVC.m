//
//  POVListScrollViewVC.m
//  Verbatm
//
//  Created by Iain Usiri on 2/3/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "POVListScrollViewVC.h"
#import "Channel_BackendObject.h"
#import "PostListVC.h"
#import "PostHolderCollecitonRV.h"
#import "Post_BackendObject.h"
#import "Page_BackendObject.h"
#import "ParseBackendKeys.h"
#import "POVView.h"

@interface POVListScrollViewVC ()<UIScrollViewDelegate>

@property (nonatomic) NSMutableArray * postList;
@property (nonatomic) UIScrollView * mainScrollView;//shows all the povs
@property (strong, nonatomic) NSMutableDictionary * povsPresented;

@end

@implementation POVListScrollViewVC


-(void)viewDidLoad{
    [self getPosts];
}


-(void)reloadCurrentChannel{
    self.postList = nil;
    [self getPosts];
}

-(void)changeCurrentChannelTo:(Channel *) channel{
    if(![self.channelForList.name isEqualToString:channel.name]){
        self.channelForList = channel;
        [self clearMainScrollView];
        self.postList = nil;
        
        [self getPosts];
    }
}

-(void) getPosts {
    if(self.listType == listFeed) {
        
        //to figure out
        
    }else if (self.listType == listChannel) {
        
        [Post_BackendObject getPostsInChannel:self.channelForList withCompletionBlock:^(NSArray * posts) {
            [self.postList addObjectsFromArray:posts];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startLoadingPoVs];
            });
        }];
    }
}



-(void)startLoadingPoVs{
    for(int i =0; i< self.postList.count; i++){
        PFObject * post = self.postList[i];
        [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
            POVView * pov = [[POVView alloc] initWithFrame:self.view.bounds];
            NSNumber * numberOfPostLikes = [post valueForKey:POST_LIKES_NUM_KEY];
            NSNumber * numberOfPostShares = [post valueForKey:POST_NUM_SHARES_KEY];
            NSNumber * numberOfPostPages =[NSNumber numberWithInteger:pages.count];
            [pov createLikeAndShareBarWithNumberOfLikes:numberOfPostLikes numberOfShares:numberOfPostShares numberOfPages:numberOfPostPages andStartingPageNumber:@(1)];
            [pov renderPOVFromPages:pages];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addPovToMainView:pov withIndex:i];
            });
            [pov povOffScreen];
        }];
        [self adjustScrollViewContentSize];
    }
}

-(void)clearMainScrollView{
    for (NSString * key in self.povsPresented){
            POVView * povInView = (POVView *) [self.povsPresented valueForKey:
                                               key];
        [povInView povOffScreen];
            [povInView removeFromSuperview];
    }
    [self.povsPresented removeAllObjects];
    self.mainScrollView.contentOffset = CGPointMake(0, 0);
}

-(void) addPovToMainView:(POVView *) pov withIndex:(CGFloat) index{
    CGRect frame = CGRectMake(pov.frame.size.width * index,
                              0, pov.frame.size.width, pov.frame.size.height);
    pov.frame = frame;
    
    [self.povsPresented setObject:pov forKey:[NSNumber numberWithFloat:index].stringValue];
    [self.mainScrollView addSubview:pov];
    [pov povOffScreen];
    
    if(index == [self getVisibileCellIndex]){
        [pov povOnScreen];
    }
}


-(CGFloat) getVisibileCellIndex{
    return self.mainScrollView.contentOffset.x / self.view.frame.size.width;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    
    NSInteger visibleCellIndex = [self getVisibileCellIndex];
    if(visibleCellIndex < self.mainScrollView.subviews.count){
        POVView * povInView = (POVView *) [self.povsPresented valueForKey:
                                           [NSNumber numberWithInteger:visibleCellIndex].stringValue];
        if(povInView)[povInView povOnScreen];
        [self stopPovsExceptAtIndex:visibleCellIndex];
    }
    
}

-(void)adjustScrollViewContentSize{
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.postList.count, 0);
}

-(void)stopPovsExceptAtIndex:(NSInteger) index{
    
    for (NSString * key in self.povsPresented){
        if(![key isEqualToString:[NSNumber numberWithInteger:index].stringValue]){
            POVView * povInView = (POVView *) [self.povsPresented valueForKey:
                                               key];
            [povInView povOffScreen];
            
        }
    }
}

-(void) headerShowing: (BOOL) showing {
    for(POVView * subView in self.mainScrollView.subviews){
        if([subView isKindOfClass:[POVView class]]){
            if (showing) {
                [(POVView *)subView shiftLikeShareBarDown:NO];
            } else {
                [(POVView *)subView shiftLikeShareBarDown:YES];
            }
        }
    }
}


#pragma mark -Lazy instantiation-

-(NSMutableArray *) postList{
    if(!_postList)_postList = [[NSMutableArray alloc] init];
    return _postList;
}

-(UIScrollView *) mainScrollView{
    if(!_mainScrollView){
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_mainScrollView];
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.backgroundColor = [UIColor blackColor];
        _mainScrollView.bounces = NO;
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.delegate = self;
    }
    return _mainScrollView;
}

-(NSMutableDictionary*) povsPresented{
    if(!_povsPresented) {
        _povsPresented = [[NSMutableDictionary alloc] init];
    }
    return _povsPresented;
}

@end
