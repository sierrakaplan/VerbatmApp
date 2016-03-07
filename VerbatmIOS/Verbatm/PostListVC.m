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
#define NUM_POVS_TO_PREPARE_EARLY 1 //we prepare this number of POVVs after the current one for viewing
@end

@implementation PostListVC

-(void)viewDidLoad {
    [self setDateSourceAndDelegate];
    [self registerClassForCustomCells];
    [self getPosts];
}

-(void)viewDidAppear:(BOOL)animated{
    
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

-(void)nothingToPresentHere {
    if(self.noContentLabel){
        return;//no need to make another one
    }
    
    self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.f - NO_POVS_LABEL_WIDTH/2.f, 0.f,
                                                                    NO_POVS_LABEL_WIDTH, self.view.frame.size.height)];
    self.noContentLabel.text = @"There are no posts to present :(";
    self.noContentLabel.font = [UIFont fontWithName:DEFAULT_FONT size:20.f];
    self.noContentLabel.textColor = [UIColor whiteColor];
    self.noContentLabel.textAlignment = NSTextAlignmentCenter;
    self.noContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.noContentLabel.numberOfLines = 3;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.noContentLabel];
}

-(void)removePresentLabel{
    if(self.noContentLabel){
        [self.noContentLabel removeFromSuperview];
        self.noContentLabel = nil;
    }
}


-(void)reloadCurrentChannel{
    [self.presentedPostList removeAllObjects];
    [self getPosts];
}

-(void)changeCurrentChannelTo:(Channel *) channel{
    if(![self.channelForList.name isEqualToString:channel.name]){
        self.collectionView.contentOffset = CGPointMake(0, 0);
        self.channelForList = channel;
        [self clearOldPosts];
        [self removePresentLabel];
        [self getPosts];
    }
}

-(void) getPosts {
    if(self.listType == listFeed) {
        if(!self.feedQueryManager)self.feedQueryManager = [[FeedQueryManager alloc] init];
        [self.feedQueryManager getMoreFeedPostsWithCompletionHandler:^(NSArray * posts) {
                if(posts.count){
                    [self loadNewBackendPosts:posts];
                    [self removePresentLabel];
                } else {
                    [self nothingToPresentHere];
                }
        }];
        
    }else if (self.listType == listChannel) {
        [Post_BackendObject getPostsInChannel:self.channelForList withCompletionBlock:^(NSArray * posts) {
            
            if(posts.count){
                [self loadNewBackendPosts:posts];
                [self removePresentLabel];
            } else {
                [self nothingToPresentHere];
            }
        }];
    }
}

-(void)clearOldPosts{
    for(POVView * view in self.presentedPostList){
        [view removeFromSuperview];
        [view clearArticle];
    }
    [self.presentedPostList removeAllObjects];
}

-(void)loadNewBackendPosts:(NSArray *) backendPostObjects{
    
    NSMutableArray * pageLoadPromises = [[NSMutableArray alloc] init];
    
    for(PFObject * post in backendPostObjects) {
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
                                            pov.parsePostObject = post;
                                            [self.presentedPostList addObject:pov];
                                            resolve(nil);
                                        }];
                            }];
        
        [pageLoadPromises addObject:promise];
        
    }
    
    //when all pages are loaded then we reload our list
    PMKWhen(pageLoadPromises).then(^(id data){
        [self sortOurPostList];
        dispatch_async(dispatch_get_main_queue(), ^{
            //prepare the first POV object
            [(POVView *)self.presentedPostList.firstObject povOnScreen];
            [self.collectionView reloadData];
        });
    });
}


-(void)sortOurPostList{
    [self.presentedPostList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        POVView * view1 = obj1;
        POVView * view2 = obj2;
    
        PFObject * postA = view1.parsePostObject;
        PFObject * postB = view2.parsePostObject;
        
        NSTimeInterval distanceBetweenDates = [[postA createdAt] timeIntervalSinceDate:[postB createdAt]];
        double secondsInMinute = 60;
        NSInteger secondsBetweenDates = distanceBetweenDates / secondsInMinute;
        
        if (secondsBetweenDates == 0)
             return NSOrderedSame;
        
        else if (secondsBetweenDates < 0)
            return NSOrderedDescending;
        else
            return NSOrderedAscending;

    }];
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
    
    if(indexPath.row < self.presentedPostList.count){
    
        POVView * povToPresent = self.presentedPostList[indexPath.row];
        [nextCellToBePresented presentPOV:povToPresent];
    
        if(indexPath.row == [self getVisibileCellIndex]){
            [nextCellToBePresented onScreen];
            //for the first cell prepare the next cell so there
            //is a smooth transition
            if(indexPath.row == 0)[self prepareNextViewAfterVisibleIndex:indexPath.row];
        }
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
    for(POVView * pov in self.presentedPostList){
        [pov shiftLikeShareBarDown:!showing];
    }
}


#pragma mark -Scrollview delegate-
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
   NSArray * cellsVisible = [self.collectionView visibleCells];
   PostHolderCollecitonRV * visibleCell = [cellsVisible firstObject];
    //somehow turn other cells off
    [self turnOffCellsOffScreenWithVisibleCell:visibleCell];
    [self prepareNextViewAfterVisibleIndex:[self.presentedPostList indexOfObject:visibleCell.ourCurrentPOV]];
}


-(void)prepareNextViewAfterVisibleIndex:(NSInteger) visibleIndex{
    
    NSInteger startIndex = visibleIndex -1;
    if(startIndex < 0) startIndex = 1;
    
    for(NSInteger i = startIndex; (i < self.presentedPostList.count  && 1 < visibleIndex + (NUM_POVS_TO_PREPARE_EARLY +1)); i++){
        POVView * view = self.presentedPostList[i];
        [view presentMediaContent];
    }
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
