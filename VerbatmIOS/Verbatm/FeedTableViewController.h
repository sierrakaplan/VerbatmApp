//
//  FeedTableViewController.h
//  Verbatm
//
//  Created by Iain Usiri on 6/27/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FeedTableViewDelegate <NSObject>

-(void) showTabBar: (BOOL) show;

-(void)goToDiscover;
-(void) refreshListOfContent;
-(void)exitProfileList;
@end

@interface FeedTableViewController : UITableViewController

@property (nonatomic, weak) id<FeedTableViewDelegate> delegate;

-(void)setAndRefreshWithList:(NSMutableArray *) channelList withStartIndex:(NSInteger) startIndex;
@end
