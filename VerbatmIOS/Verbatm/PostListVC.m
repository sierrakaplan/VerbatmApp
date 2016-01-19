//
//  PostListVC.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "PostListVC.h"

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
}

-(void)setAppropriateScrollDirection{
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}


#pragma mark -DataSource-

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 0;//we only have one section
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    //have some array that contains
    if(self.postList)return self.postList.count;
    else return 0;
}

#pragma mark -ViewDelegate-

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;//the cell should take up the whole screen
}


- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;//POVVs are not selectable
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionViewCell * nextCell = [collectionView dequeueReusableCellWithReuseIdentifier:POV_CELL_ID forIndexPath:indexPath];
    
    if(!nextCell){
        
    }
    
    
    return nextCell;
}













@end
