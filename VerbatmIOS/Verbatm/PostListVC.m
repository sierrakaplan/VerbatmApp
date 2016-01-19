//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PostListVC.h"
#import "PostHolderCollecitonRV.h"

@interface PostListVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic) NSMutableArray * postList;

#define POV_CELL_ID @"povCellId"

@end

@implementation PostListVC

-(void)viewDidLoad {
    //set the data source and delegate of the collection view
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    //register our custom cell class
    [self.collectionView registerClass:[PostHolderCollecitonRV class] forCellWithReuseIdentifier:POV_CELL_ID];
}


#pragma mark -DataSource-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;//we only have one section
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    //have some array that contains
    if(self.postList)return self.postList.count;
    else return 10;
}

#pragma mark -ViewDelegate-
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//POVVs are not selectable
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostHolderCollecitonRV * nextCellToBePresented = (PostHolderCollecitonRV *) [collectionView dequeueReusableCellWithReuseIdentifier:POV_CELL_ID forIndexPath:indexPath];
    //TODO --sierra
    //get the AVEs for this specific post and send them to be presented
    //[nextCellToBePresented presentPages:<#(NSMutableArray *)#> startingAtIndex:0];
    
    //temp to test paging -- remove
    if(indexPath.row%2)nextCellToBePresented.backgroundColor = [UIColor redColor];//temp
    else nextCellToBePresented.backgroundColor = [UIColor blueColor];//temp

    return nextCellToBePresented;
}













@end
