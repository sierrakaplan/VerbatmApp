////
////  PostListVC.m
////  Verbatm
////
////  Created by Iain Usiri on 1/18/16.
////  Copyright © 2016 Verbatm. All rights reserved.
////
//
//#import "Channel_BackendObject.h"
//#import "PostListVC.h"
//#import "PostHolderCollecitonRV.h"
//#import "Post_BackendObject.h"
//#import "Page_BackendObject.h"
//#import "ParseBackendKeys.h"
//#import "POVView.h"
//
//@interface PostListVC ()<UICollectionViewDelegate,UICollectionViewDataSource,
//                        UIScrollViewDelegate>
//
//@property (nonatomic) NSMutableArray * postList;
//@property (nonatomic) NSMutableArray * postPOVList;
//
//#define POV_CELL_ID @"povCellId"
//
//@end
//
//@implementation PostListVC
//
//-(void)viewDidLoad {
//    //set the data source and delegate of the collection view
//    self.collectionView.dataSource = self;
//    self.collectionView.delegate = self;
//    self.collectionView.pagingEnabled = YES;
//    self.collectionView.scrollEnabled = YES;
//    self.collectionView.showsHorizontalScrollIndicator = NO;
//    self.collectionView.bounces = NO;
//    //register our custom cell class
//    [self.collectionView registerClass:[PostHolderCollecitonRV class] forCellWithReuseIdentifier:POV_CELL_ID];
//    [self getPosts];
//}
//
//-(void)reloadCurrentChannel{
//    self.postList = nil;
//    [self getPosts];
//}
//
//-(void)changeCurrentChannelTo:(Channel *) channel{
//    self.channelForList = channel;
//    self.postList = nil;
//    [self getPosts];
//}
//
//-(void) getPosts {
//    if(self.listType == listFeed) {
//        
//        //to figure out
//        
//    }else if (self.listType == listChannel) {
//        
//        [Post_BackendObject getPostsInChannel:self.channelForList withCompletionBlock:^(NSArray * posts) {
//            [self.postList addObjectsFromArray:posts];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.collectionView reloadData];
//                    [self startLoadingPoVs];
//            });
//        }];
//    }
//}
//
//
//
//-(void)startLoadingPoVs{
//    self.postPOVList = [[NSMutableArray alloc] init];
//    for(PFObject * post in self.postList){
//        [Page_BackendObject getPagesFromPost:post andCompletionBlock:^(NSArray * pages) {
//            POVView * pov = [[POVView alloc] initWithFrame:self.view.bounds];
//            NSNumber * numberOfPostLikes = [post valueForKey:POST_LIKES_NUM_KEY];
//            NSNumber * numberOfPostShares = [post valueForKey:POST_NUM_SHARES_KEY];
//            NSNumber * numberOfPostPages =[NSNumber numberWithInteger:pages.count];
//            [pov createLikeAndShareBarWithNumberOfLikes:numberOfPostLikes numberOfShares:numberOfPostShares numberOfPages:numberOfPostPages andStartingPageNumber:@(1)];
//            [self.postPOVList addObject:pov];
//            [pov povOffScreen];
//        }];
//    }
//}
//
//#pragma mark -DataSource-
//
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;//we only have one section
//}
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView
//     numberOfItemsInSection:(NSInteger)section {
//    //have some array that contains
//    if(self.postList)return self.postList.count;
//    else return 0;
//}
//
//#pragma mark -ViewDelegate-
//- (BOOL)collectionView:(UICollectionView *)collectionView
//shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    return NO;//POVVs are not selectable
//}
//
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
//                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    PostHolderCollecitonRV * nextCellToBePresented = (PostHolderCollecitonRV *) [collectionView dequeueReusableCellWithReuseIdentifier:POV_CELL_ID forIndexPath:indexPath];
//    
//    if(self.postList.count && (indexPath.row < self.postList.count)){
//        
//        
//        if(self.postPOVList.count != 20 &&
//           self.postPOVList.count != self.postList.count){
//            PFObject * postObjectToPresent = self.postList[indexPath.row];
//            [nextCellToBePresented presentPost:postObjectToPresent];
////        }else{
////            POVView * povToPresent = self.postPOVList[indexPath.row];
////            [nextCellToBePresented presentPOV:povToPresent];
////            [nextCellToBePresented onScreen];
//            
//        }
//        if(indexPath.row == [self getVisibileCellIndex]){
//            [nextCellToBePresented onScreen];
//        }
//    }
//    
//    return nextCellToBePresented;
//}
//
//
//-(CGFloat) getVisibileCellIndex{
//    
//    return self.collectionView.contentOffset.x / self.view.frame.size.width;
//}
//
//#pragma mark -Scrollview delegate-
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
//    
//   NSArray * cellsVisible = [self.collectionView visibleCells];
//   PostHolderCollecitonRV * visibleCell = [cellsVisible firstObject];
//   [visibleCell onScreen];
//    //somehow turn other cells off
//    
//}
//
//
//#pragma mark -Lazy instantiation-
//
//-(NSMutableArray *)postList{
//    if(!_postList)_postList = [[NSMutableArray alloc] init];
//    return _postList;
//}
//
//
//
//
//
//
//@end
