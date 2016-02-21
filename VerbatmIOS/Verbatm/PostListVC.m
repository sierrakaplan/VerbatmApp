//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"

#import "FeedQueryManager.h"

#import "Page_BackendObject.h"
#import "PostListVC.h"
#import "PostHolderCollecitonRV.h"
#import "Post_BackendObject.h"
#import "ParseBackendKeys.h"
#import "POVView.h"
#import <PromiseKit/PromiseKit.h>

#import "SizesAndPositions.h"
#import "Styles.h"



@interface PostListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,
                        UIScrollViewDelegate>

@property (nonatomic) NSMutableArray * presentedPostList;
@property (strong, nonatomic) FeedQueryManager * feedQueryManager;
@property (nonatomic, strong) UILabel * noContentLabel;
@property (nonatomic) PostHolderCollecitonRV * lastVisibleCell;

#define POV_CELL_ID @"povCellId"

@end

@implementation PostListVC

-(void)viewDidLoad {
    [self setDateSourceAndDelegate];
    [self registerClassForCustomCells];
    [self getPosts];
}

//register our custom cell class
-(void)registerClassForCustomCells{
     [self.collectionView registerClass:[PostHolderCollecitonRV class] forCellWithReuseIdentifier:POV_CELL_ID];
}

//set the data source and delegate of the collection view
-(void)setDateSourceAndDelegate{
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
}

-(void)reloadCurrentChannel{
    [self.presentedPostList removeAllObjects];
    [self getPosts];
}

-(void)changeCurrentChannelTo:(Channel *) channel{
    if(![self.channelForList.name isEqualToString:channel.name]){
        self.channelForList = channel;
        [self.presentedPostList removeAllObjects];
        [self getPosts];
    }
}

-(void) getPosts {
    if(self.listType == listFeed) {
        if(!self.feedQueryManager)self.feedQueryManager = [[FeedQueryManager alloc] init];
        [self.feedQueryManager getMoreFeedPostsWithCompletionHandler:^(NSArray * posts) {
                if(posts.count){
                    [self loadNewBackendPosts:posts];
                    //[self removePresentLabel];
                } else {
                    //[self nothingToPresentHere];
                }
        }];
        
    }else if (self.listType == listChannel) {
        [Post_BackendObject getPostsInChannel:self.channelForList withCompletionBlock:^(NSArray * posts) {
            
            [self loadNewBackendPosts:posts];
        }];
    }
}



-(void)loadNewBackendPosts:(NSArray *) backendPostObjects{
    self.presentedPostList = [[NSMutableArray alloc] init];
    
    NSMutableArray * pageLoadPromises = [[NSMutableArray alloc] init];
    
    for(PFObject * post in backendPostObjects){
        
        AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
                                        [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
                                            POVView * pov = [[POVView alloc] initWithFrame:self.view.bounds];
                                            NSNumber * numberOfPostLikes =
                                            [post valueForKey:POST_LIKES_NUM_KEY];
                                            NSNumber * numberOfPostShares =
                                            [post valueForKey:POST_NUM_SHARES_KEY];
                                            
                                            NSNumber * numberOfPostPages =
                                            [NSNumber numberWithInteger:pages.count];
                                            
                                            [pov createLikeAndShareBarWithNumberOfLikes:numberOfPostLikes numberOfShares:numberOfPostShares
                                                numberOfPages:numberOfPostPages
                                                andStartingPageNumber:@(1)
                                                startUp:self.isHomeProfileOrFeed];
                                            [pov renderPOVFromPages:pages];
                                            [pov povOffScreen];
                                            [self.presentedPostList addObject:pov];
                                            resolve(nil);
                                        }];
                            }];
        
        [pageLoadPromises addObject:promise];
        
    }
    
    //when all pages are loaded then we reload our list
    PMKWhen(pageLoadPromises).then(^(id data){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

#pragma mark -DataSource-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;//we only have one section
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    //have some array that contains
   return self.presentedPostList.count;
}

#pragma mark -ViewDelegate-
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//POVVs are not selectable
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    PostHolderCollecitonRV * nextCellToBePresented = (PostHolderCollecitonRV *) [collectionView dequeueReusableCellWithReuseIdentifier:POV_CELL_ID forIndexPath:indexPath];
    
        POVView * povToPresent = self.presentedPostList[indexPath.row];
        [nextCellToBePresented presentPOV:povToPresent];
    
        if(indexPath.row == [self getVisibileCellIndex]){
            [nextCellToBePresented onScreen];
        }
    
    return nextCellToBePresented;
}


-(CGFloat) getVisibileCellIndex{
    return self.collectionView.contentOffset.x / self.view.frame.size.width;
}


//marks all POVs as off screen
-(void) stopAllVideoContent{
    for(POVView * pov in self.presentedPostList){
        [pov povOffScreen];
    }
}

//continues POV that's on screen
-(void) continueVideoContent{
    if([self getVisibileCellIndex] < self.presentedPostList.count){
        POVView * pov = [self.presentedPostList objectAtIndex:[self getVisibileCellIndex]];
        [pov povOnScreen];
    }
}

-(void) footerShowing: (BOOL) showing{
    
}


#pragma mark -Scrollview delegate-
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
   NSArray * cellsVisible = [self.collectionView visibleCells];
   PostHolderCollecitonRV * visibleCell = [cellsVisible firstObject];
    //somehow turn other cells off
    [self turnOffCellsOffScreenWithVisibleCell:visibleCell];
}

-(void)turnOffCellsOffScreenWithVisibleCell:(PostHolderCollecitonRV *)visibleCell{
    if(visibleCell && (self.lastVisibleCell !=visibleCell)){
        if(self.lastVisibleCell){
            [self.lastVisibleCell offScreen];
            self.lastVisibleCell = visibleCell;
        }else{
            self.lastVisibleCell = visibleCell;
        }
        [visibleCell onScreen];
    }
    
}




#pragma mark -Lazy instantiation-

-(NSMutableArray *)presentedPostList{
    if(!_presentedPostList)_presentedPostList = [[NSMutableArray alloc] init];
    return _presentedPostList;
}






@end
