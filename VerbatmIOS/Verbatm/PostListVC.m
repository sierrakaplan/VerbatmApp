//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "Channel_BackendObject.h"

#import "Durations.h"

#import "FeedQueryManager.h"

#import "LoadingIndicator.h"

#import "Notifications.h"

#import "Page_BackendObject.h"
#import "PostListVC.h"
#import "PostHolderCollecitonRV.h"
#import "Post_BackendObject.h"
#import "Post_Channel_RelationshipManger.h"
#import "ParseBackendKeys.h"
#import "POVView.h"
#import <PromiseKit/PromiseKit.h>

#import "SizesAndPositions.h"
#import "Styles.h"
#import "SharePOVView.h"


@interface PostListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,
                        UIScrollViewDelegate,POVViewDelegate>

@property (nonatomic) NSMutableArray * presentedPostList;
@property (strong, nonatomic) FeedQueryManager * feedQueryManager;
@property (nonatomic, strong) UILabel * noContentLabel;
@property (nonatomic) PostHolderCollecitonRV * lastVisibleCell;
@property (nonatomic) LoadingIndicator * customActivityIndicator;
@property (nonatomic) SharePOVView * sharePOVView;
@property (nonatomic) BOOL shouldPlayVideos;
@property (nonatomic) BOOL isReloading;
@property (nonatomic) PFObject * povToShare;

@property (nonatomic) UIImageView * reblogSucessful;
@property (nonatomic) UIImageView * following;
@property (nonatomic) UIImageView * publishSuccessful;
@property (nonatomic) UIImageView * publishFailed;

#define LOAD_MORE_POSTS_COUNT 3 //number of posts left to see before we start loading more content
#define POV_CELL_ID @"povCellId"
#define NUM_POVS_TO_PREPARE_EARLY 2 //we prepare this number of POVVs after the current one for viewing

#define REBLOG_IMAGE_SIZE 150.f //when we put size it means both width and height
#define REPOST_ANIMATION_DURATION 2.f
@end

@implementation PostListVC

-(void)viewDidLoad {
    [self setDateSourceAndDelegate];
    [self registerClassForCustomCells];
    [self getPosts];
    self.shouldPlayVideos = YES;
    [self registerForNotifications];
}


-(void)registerForNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(publishingFailedNotification:)
                                                 name:NOTIFICATION_MEDIA_SAVING_FAILED
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successfullyPublishedNotification:)
                                                 name:NOTIFICATION_POV_PUBLISHED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(followingSuccesufulNotification:)
                                                 name:NOTIFICATION_NOW_FOLLOWING_USER
                                               object:nil];
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
    self.collectionView.bounces = YES;
}

-(void)nothingToPresentHere {
    if(self.noContentLabel || self.presentedPostList.count > 0){
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
    [self stopAllVideoContent];
    [self.presentedPostList removeAllObjects];
    [self.customActivityIndicator startCustomActivityIndicator];
    [self getPosts];
}

-(void)changeCurrentChannelTo:(Channel *) channel{
    if(![self.channelForList.name isEqualToString:channel.name]){
        self.collectionView.contentOffset = CGPointMake(0, 0);
        self.channelForList = channel;
        [self clearOldPosts];
        [self removePresentLabel];
        [self.customActivityIndicator startCustomActivityIndicator];
        [self getPosts];
    }
}

-(void) getPosts {
    if(self.listType == listFeed) {
        if(!self.feedQueryManager)self.feedQueryManager = [[FeedQueryManager alloc] init];
        [self.feedQueryManager getMoreFeedPostsWithCompletionHandler:^(NSArray * posts) {
            
               [self.customActivityIndicator stopCustomActivityIndicator];
                if(posts.count){
                    [self loadNewBackendPosts:posts];
                    [self removePresentLabel];
                } else {
                    [self nothingToPresentHere];
                }
            
        }];
        
    }else if (self.listType == listChannel) {
        [Post_BackendObject getPostsInChannel:self.channelForList withCompletionBlock:^(NSArray * posts) {
            [self.customActivityIndicator stopCustomActivityIndicator];
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
    
    for(PFObject * pc_activity in backendPostObjects) {
        AnyPromise * promise = [AnyPromise promiseWithResolverBlock:^(PMKResolver  _Nonnull resolve) {
                                        PFObject * post = [pc_activity objectForKey:POST_CHANNEL_ACTIVITY_POST];
                                        [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
                                            POVView * pov = [[POVView alloc] initWithFrame:self.view.bounds];
                                            pov.parsePostChannelActivityObject = pc_activity;
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
                                            pov.delegate = self;
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
            if(self.shouldPlayVideos && !self.isReloading)[(POVView *)self.presentedPostList.firstObject povOnScreen];
            [self.collectionView reloadData];
            self.isReloading = NO;
        });
    });
}


-(void)sortOurPostList{
    [self.presentedPostList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        POVView * view1 = obj1;
        POVView * view2 = obj2;
    
        PFObject * pc_activityA = view1.parsePostChannelActivityObject;
        PFObject * pc_activityB = view2.parsePostChannelActivityObject;
        
        NSTimeInterval distanceBetweenDates = [[pc_activityA createdAt] timeIntervalSinceDate:[pc_activityB createdAt]];
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
    
        if(indexPath.row == [self getVisibileCellIndex]) {
            if(self.shouldPlayVideos)[nextCellToBePresented onScreen];
            //for the first cell prepare the next cell so there
            //is a smooth transition
            if(indexPath.row == 0)[self prepareNextViewAfterVisibleIndex:indexPath.row];
        }
    }
    //we only load more media if we're in the feed and if there are "Load_more.."
    //cells left until the end
    if(indexPath.row == (self.presentedPostList.count - LOAD_MORE_POSTS_COUNT) &&
       (self.listType == listFeed) && !self.isReloading){
        self.isReloading = YES;
        [self getPosts];
    }
    
    return nextCellToBePresented;
}


-(CGFloat) getVisibileCellIndex{
    return self.collectionView.contentOffset.x / self.view.frame.size.width;
}


//marks all POVs as off screen
-(void) stopAllVideoContent{
    self.shouldPlayVideos = NO;
    for(POVView * pov in self.presentedPostList){
        [pov povOffScreen];
    }
}

//continues POV that's on screen
-(void) continueVideoContent{
    self.shouldPlayVideos = YES;
    if(self.presentedPostList.count > 0){
        if([self getVisibileCellIndex] < self.presentedPostList.count){
            POVView * pov = [self.presentedPostList objectAtIndex:[self getVisibileCellIndex]];
            [pov povOnScreen];
        }
    }else{
        [self getPosts];
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


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSInteger currentPOVIndex = [self getVisibileCellIndex];
//    //somehow turn other cells off
//    [self.presentedPostList[currentPOVIndex] povOnScreen];
//    [self prepareNextViewAfterVisibleIndex:currentPOVIndex];
}

-(void)prepareNextViewAfterVisibleIndex:(NSInteger) visibleIndex{
    for(NSInteger i = 0; i < self.presentedPostList.count; i++){
         POVView * view = self.presentedPostList[i];
        if((i > visibleIndex) && (i < (visibleIndex + NUM_POVS_TO_PREPARE_EARLY))){
            [view presentMediaContent];
        }else if(i != visibleIndex){
            [view povOffScreen];
        }
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
        if(self.shouldPlayVideos)[visibleCell onScreen];
    }
    
}


-(void) shareOptionSelectedForParsePostObject: (PFObject* ) pov{
   [self.delegate hideNavBarIfPresent];
    self.povToShare = pov;
    [self presentShareSelectionViewStartOnChannels:YES];
}


-(void)presentShareSelectionViewStartOnChannels:(BOOL) startOnChannels{
    if(self.sharePOVView){
        [self.sharePOVView removeFromSuperview];
        self.sharePOVView = nil;
    }
    
    CGRect onScreenFrame = CGRectMake(0.f, self.view.frame.size.height/2.f, self.view.frame.size.width, self.view.frame.size.height/2.f);
    CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
    self.sharePOVView = [[SharePOVView alloc] initWithFrame:offScreenFrame shouldStartOnChannels:startOnChannels];
    self.sharePOVView.delegate = self;
    [self.view addSubview:self.sharePOVView];
    [self.view bringSubviewToFront:self.sharePOVView];
    [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
        self.sharePOVView.frame = onScreenFrame;
    }];
}

-(void)removeSharePOVView{
    if(self.sharePOVView){
        CGRect offScreenFrame = CGRectMake(0.f, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height/2.f);
        [UIView animateWithDuration:TAB_BAR_TRANSITION_TIME animations:^{
            self.sharePOVView.frame = offScreenFrame;
        }completion:^(BOOL finished) {
            if(finished){
                [self.sharePOVView removeFromSuperview];
                self.sharePOVView = nil;
            }
        }];
    }
}

#pragma mark -Share Seletion View Protocol -
-(void)cancelButtonSelected{
    [self removeSharePOVView];
}

-(void)postPOVToChannels:(NSMutableArray *) channels{
    if(channels.count){
        [Post_Channel_RelationshipManger savePost:self.povToShare toChannels:channels withCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self successfullyReblogged];
            });
        }];
    }
    [self removeSharePOVView];
}


-(void)successfullyReblogged{
    [self.view addSubview:self.reblogSucessful];
    [self.view bringSubviewToFront:self.reblogSucessful];
    [UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
        self.reblogSucessful.alpha = 0.f;
    }completion:^(BOOL finished) {
        [self.reblogSucessful removeFromSuperview];
        self.reblogSucessful = nil;
    }];
}

-(void)successfullyPublishedNotification:(NSNotification *) notification{
    [self.view addSubview:self.publishSuccessful];
    [self.view bringSubviewToFront:self.publishSuccessful];
    [UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
        self.publishSuccessful.alpha = 0.f;
    }completion:^(BOOL finished) {
        [self.publishSuccessful removeFromSuperview];
        self.publishSuccessful = nil;
    }];
}

-(void)publishingFailedNotification:(NSNotification *) notification{
    [self.view addSubview:self.publishFailed];
    [self.view bringSubviewToFront:self.publishFailed];
    [UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
        self.publishFailed.alpha = 0.f;
    }completion:^(BOOL finished) {
        [self.publishFailed removeFromSuperview];
        self.publishFailed = nil;
    }];
}

-(void)followingSuccesufulNotification:(NSNotification *) notification{
    [self.view addSubview:self.following];
    [self.view bringSubviewToFront:self.following];
    [UIView animateWithDuration:REPOST_ANIMATION_DURATION animations:^{
        self.following.alpha = 0.f;
    }completion:^(BOOL finished) {
        [self.following removeFromSuperview];
        self.following = nil;
    }];
}

-(void)sharePostWithComment:(NSString *) comment{
    //todo--sierra
    //code to share post to facebook etc
    [self removeSharePOVView];
    
}

#pragma mark -POV delegate-
-(void)channelSelected:(Channel *) channel withOwner:(PFUser *) owner{
    [self.delegate channelSelected:channel withOwner:owner];
}

#pragma mark -Lazy instantiation-

-(UIImageView *)reblogSucessful{
    if(!_reblogSucessful){
        _reblogSucessful = [[UIImageView alloc] init];
        [_reblogSucessful setImage:[UIImage imageNamed:REBLOG_IMAGE]];
        [_reblogSucessful setFrame:CGRectMake((self.view.frame.size.width/2.f)-REBLOG_IMAGE_SIZE/2.f, (self.view.frame.size.height/2.f) -REBLOG_IMAGE_SIZE/2.f, REBLOG_IMAGE_SIZE, REBLOG_IMAGE_SIZE)];
    }
    return _reblogSucessful;
}


-(UIImageView *)publishSuccessful{
    if(!_publishSuccessful){
        _publishSuccessful = [[UIImageView alloc] init];
        [_publishSuccessful setImage:[UIImage imageNamed:SUCCESS_PUBLISHING_IMAGE]];
        [_publishSuccessful setFrame:self.reblogSucessful.frame];
        self.reblogSucessful = nil;
    }
    return _publishSuccessful;
}

-(UIImageView *)publishFailed{
    if(!_publishFailed){
        _publishFailed = [[UIImageView alloc] init];
        [_publishFailed setImage:[UIImage imageNamed:FAILED_PUBLISHING_IMAGE]];
        [_publishFailed setFrame:self.reblogSucessful.frame];
        self.reblogSucessful = nil;
    }
    return _publishFailed;
}

-(UIImageView *)following{
    if(!_following){
        _following = [[UIImageView alloc] init];
        [_following setImage:[UIImage imageNamed:FOLLOWING_SUCCESS_IMAGE]];
        [_following setFrame:self.reblogSucessful.frame];
        self.reblogSucessful = nil;
    }
    return _following;
}

-(LoadingIndicator *)customActivityIndicator{
    if(!_customActivityIndicator){
        CGPoint center = CGPointMake(self.view.frame.size.width/2., self.view.frame.size.height/2.f);
        _customActivityIndicator = [[LoadingIndicator alloc] initWithCenter:center];
        [self.view addSubview:_customActivityIndicator];
        [self.view bringSubviewToFront:_customActivityIndicator];
    }
    return _customActivityIndicator;
}

-(NSMutableArray *)presentedPostList{
    if(!_presentedPostList)_presentedPostList = [[NSMutableArray alloc] init];
    return _presentedPostList;
}

@end
