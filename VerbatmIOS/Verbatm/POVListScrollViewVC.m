////
////  POVListScrollViewVC.m
////  Verbatm
////
////  Created by Iain Usiri on 2/3/16.
////  Copyright © 2016 Verbatm. All rights reserved.
////
//
//#import "Channel_BackendObject.h"
//#import "FeedQueryManager.h"
//#import "SizesAndPositions.h"
//#import "Styles.h"
//#import "POVListScrollViewVC.h"
//#import "PostHolderCollecitonRV.h"
//#import "Post_BackendObject.h"
//#import "Page_BackendObject.h"
//#import "ParseBackendKeys.h"
//#import "POVView.h"
//
//@interface POVListScrollViewVC ()<UIScrollViewDelegate,POVViewDelegate>
//
//@property (nonatomic) NSMutableArray * postList;
//@property (nonatomic) UIScrollView * mainScrollView;//shows all the povs
//@property (strong, nonatomic) NSMutableDictionary * povsPresented;
//@property (strong, nonatomic) FeedQueryManager * feedQueryManager;
//@property (nonatomic, strong) UILabel * noContentLabel;
//@property (strong, nonatomic) UIActivityIndicatorView * activityIndicator;
//@property (nonatomic) BOOL justLoaded;//records if this is the firs time the view is loaded
//
//@end
//
//@implementation POVListScrollViewVC
//
//
//-(void)viewDidLoad{
//    [self.activityIndicator startAnimating];
//    [self getPosts];
//    self.justLoaded = YES;
//}
//
//-(void)viewWillAppear:(BOOL)animated {
//    if(self.justLoaded){
//        self.justLoaded = NO;
//    } else {
//        [self.activityIndicator startAnimating];
//        [self getPosts];
//    }
//}
//
//-(void)reloadCurrentChannel{
//    self.postList = nil;
//    [self getPosts];
//}
//
//-(void)changeCurrentChannelTo:(Channel *) channel{
//    if(![self.channelForList.name isEqualToString:channel.name]){
//        self.channelForList = channel;
//        [self clearMainScrollView];
//        self.postList = nil;
//        
//        [self getPosts];
//    }
//}
//
//-(void)nothingToPresentHere {
//    [self.activityIndicator stopAnimating];
//    if(self.noContentLabel){
//        return;//no need to make another one
//    }
//    
//    self.noContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.f - NO_POVS_LABEL_WIDTH/2.f, 0.f,
//                                                                     NO_POVS_LABEL_WIDTH, self.view.frame.size.height)];
//    self.noContentLabel.text = @"There are no posts to present :(";
//    self.noContentLabel.font = [UIFont fontWithName:DEFAULT_FONT size:20.f];
//    self.noContentLabel.textColor = [UIColor whiteColor];
//    self.noContentLabel.textAlignment = NSTextAlignmentCenter;
//    self.noContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    self.noContentLabel.numberOfLines = 3;
//    self.view.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:self.noContentLabel];
//}
//
//-(void)removePresentLabel{
//    if(self.noContentLabel){
//        [self.noContentLabel removeFromSuperview];
//        self.noContentLabel = nil;
//    }
//}
//
//-(void) getPosts {
//    if(self.listType == listFeed) {
//        if(!self.feedQueryManager)self.feedQueryManager = [[FeedQueryManager alloc] init];
//        //to figure out
//        [self.feedQueryManager getMoreFeedPostsWithCompletionHandler:^(NSArray * posts) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(posts.count){
//                    [self.activityIndicator stopAnimating];
//                    [self.postList addObjectsFromArray:posts];
//                    [self startLoadingPoVs];
//                    [self removePresentLabel];
//                } else {
//                    [self nothingToPresentHere];
//                }
//            });
//        }];
//    }else if (self.listType == listChannel) {
//        [Post_BackendObject getPostsInChannel:self.channelForList withCompletionBlock:^(NSArray * posts) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(posts.count){
//                    [self.postList addObjectsFromArray:posts];
//                    [self startLoadingPoVs];
//                    [self removePresentLabel];
//                }else{
//                    [self nothingToPresentHere];
//                }
//            });
//
//        }];
//    }
//}
//
//-(void)startLoadingPoVs{
//    for(int i = 0; i< self.postList.count; i++){
//        PFObject * post = self.postList[i];
//        [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
//            POVView * pov = [[POVView alloc] initWithFrame:self.view.bounds andPovParseObject:post];
//            pov.delegate = self;
//            NSNumber * numberOfPostLikes = [post valueForKey:POST_LIKES_NUM_KEY];
//            NSNumber * numberOfPostShares = [post valueForKey:POST_NUM_SHARES_KEY];
//            NSNumber * numberOfPostPages =[NSNumber numberWithInteger:pages.count];
//            [pov createLikeAndShareBarWithNumberOfLikes:numberOfPostLikes numberOfShares:numberOfPostShares numberOfPages:numberOfPostPages andStartingPageNumber:@(1) startUp:self.isHomeProfileOrFeed];
//            [pov renderPOVFromPages:pages];
//            [pov povOffScreen];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self addPovToMainView:pov withIndex:i];
//            });
//            
//        }];
//        [self adjustScrollViewContentSize];
//    }
//    [self continueVideoContent];
//}
//
//-(void)clearMainScrollView{
//    for (NSString * key in self.povsPresented){
//        POVView * povInView = (POVView *) [self.povsPresented valueForKey:
//                                               key];
//        [povInView povOffScreen];
//        [povInView removeFromSuperview];
//    }
//    
//    [self.mainScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    
//    [self.povsPresented removeAllObjects];
//    self.mainScrollView.contentOffset = CGPointMake(0, 0);
//    [self.activityIndicator startAnimating];
//}
//
//-(void) addPovToMainView:(POVView *) pov withIndex:(CGFloat) index{
//    CGRect frame = CGRectMake(pov.frame.size.width * index,
//                              0, pov.frame.size.width, pov.frame.size.height);
//    pov.frame = frame;
//    
//    [self.povsPresented setObject:pov forKey:[NSNumber numberWithFloat:index].stringValue];
//    [self.mainScrollView addSubview:pov];
//    [pov povOffScreen];
//    
//    if(index == [self getVisibileCellIndex]){
//        [pov povOnScreen];
//    }
//}
//
//
//-(CGFloat) getVisibileCellIndex{
//    return self.mainScrollView.contentOffset.x / self.view.frame.size.width;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
//    
//    NSInteger visibleCellIndex = [self getVisibileCellIndex];
//    if(visibleCellIndex < self.mainScrollView.subviews.count){
//        POVView * povInView = (POVView *) [self.povsPresented valueForKey:
//                                           [NSNumber numberWithInteger:visibleCellIndex].stringValue];
//        if(povInView)[povInView povOnScreen];
//        [self stopPovsExceptAtIndex:visibleCellIndex];
//    }
//    
//}
//
//-(void)adjustScrollViewContentSize{
//    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.postList.count, 0);
//}
//
//-(void)stopPovsExceptAtIndex:(NSInteger) index{
//    
//    for (NSString * key in self.povsPresented){
//        if(![key isEqualToString:[NSNumber numberWithInteger:index].stringValue]){
//            POVView * povInView = (POVView *) [self.povsPresented valueForKey:
//                                               key];
//            [povInView povOffScreen];
//            
//        }
//    }
//}
//
//-(void) stopAllVideoContent{
//    NSInteger visibleCellIndex = [self getVisibileCellIndex];
//    if(visibleCellIndex < self.mainScrollView.subviews.count){
//        POVView * povInView = (POVView *) [self.povsPresented valueForKey:
//                                           [NSNumber numberWithInteger:visibleCellIndex].stringValue];
//        if(povInView)[povInView povOffScreen];
//        [self stopPovsExceptAtIndex:visibleCellIndex];
//    }
//}
//
//-(void) continueVideoContent{
//    NSInteger visibleCellIndex = [self getVisibileCellIndex];
//    if(visibleCellIndex < self.mainScrollView.subviews.count){
//        POVView * povInView = (POVView *) [self.povsPresented valueForKey:
//                                           [NSNumber numberWithInteger:visibleCellIndex].stringValue];
//        if(povInView)[povInView povOnScreen];
//    }
//}
//
//-(void) footerShowing: (BOOL) showing {
//    if(self.isHomeProfileOrFeed){
//        for(POVView * subView in self.mainScrollView.subviews){
//            if([subView isKindOfClass:[POVView class]]){
//                if (showing) {
//                    [(POVView *)subView shiftLikeShareBarDown:NO];
//                } else {
//                    [(POVView *)subView shiftLikeShareBarDown:YES];
//                }
//            }
//        }
//    }
//}
//
//#pragma mark -POV Delegate Protocol-
//-(void) likeButtonLiked: (BOOL)liked onPOV: (PovInfo*) povInfo{
//    
//}
//
//-(void) shareOptionSelectedForParsePostObject: (PFObject* ) post{
//    [self.delegate shareOptionSelectedForParsePostObject:post];
//}
//
//
//#pragma mark -Lazy instantiation-
//
//-(NSMutableArray *) postList{
//    if(!_postList)_postList = [[NSMutableArray alloc] init];
//    return _postList;
//}
//
//-(UIScrollView *) mainScrollView{
//    if(!_mainScrollView){
//        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//        [self.view addSubview:_mainScrollView];
//        _mainScrollView.showsHorizontalScrollIndicator = NO;
//        _mainScrollView.showsVerticalScrollIndicator = NO;
//        _mainScrollView.backgroundColor = [UIColor blackColor];
//        _mainScrollView.bounces = NO;
//        _mainScrollView.pagingEnabled = YES;
//        _mainScrollView.delegate = self;
//    }
//    return _mainScrollView;
//}
//
//-(NSMutableDictionary*) povsPresented{
//    if(!_povsPresented) {
//        _povsPresented = [[NSMutableDictionary alloc] init];
//    }
//    return _povsPresented;
//}
//
//-(UIActivityIndicatorView*) activityIndicator {
//    if (!_activityIndicator) {
//        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
//        _activityIndicator.color = [UIColor grayColor];
//        _activityIndicator.hidesWhenStopped = YES;
//        _activityIndicator.center = self.view.center;
//        [self.view addSubview:_activityIndicator];
//        [self.view bringSubviewToFront:_activityIndicator];
//    }
//    return _activityIndicator;
//}
//
//@end
