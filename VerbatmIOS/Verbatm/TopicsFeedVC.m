//
//  topicsViewVC.m
//  Verbatm
//
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "TopicsFeedVC.h"
#import "TopicsTableView.h"
#import "TopicsTableViewCell.h"
#import "SizesAndPositions.h"


@interface TopicsFeedVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TopicsTableView *topicsListView;

#define TOPIC_CELL_ID @"topicCellID"

@end

@implementation TopicsFeedVC


-(void) viewDidLoad {
	[super viewDidLoad];
	[self initTopicsListView];
}

-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

}

-(void) initTopicsListView {
	self.topicsListView = [[TopicsTableView alloc] initWithFrame:self.view.bounds style: UITableViewStylePlain];
	self.topicsListView.dataSource = self;
	self.topicsListView.delegate = self;
	[self.view addSubview: self.topicsListView];
}


#pragma mark - Table View Delegate methods (view customization) -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return TOPIC_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self viewTopicAtIndex: indexPath.row];
}

//one of the topics in the list has been clicked
-(void) viewTopicAtIndex: (NSInteger) index {
	// TODO: enter specific topic at that index (create Article List VC)
}

#pragma mark - Table View Data Source methods (model) -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	//    NSUInteger count = self.articleLoadManger.articleList.count;
	//    count += (self.pullDownInProgress) ? 1 : 0;
	//    return count;
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	TopicsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: TOPIC_CELL_ID];
	if (cell == nil) {
		cell = [[TopicsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: TOPIC_CELL_ID];
	}
	//    NSInteger index = indexPath.row;
	//    if(!self.pullDownInProgress){
	//        //configure cell
	//        Article * article = self.articleLoadManger.articleList[index];
	//        [cell setContentWithUsername:[article getAuthorUsername] andTitle:article.title];
	//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//    }else if(self.refreshInProgress && index ==0){
	//this means that the cell is an animation place-holder
	[cell setContentWithTitle: [NSString stringWithFormat:@"Topic %ld", (long)indexPath.row]];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	//}
	return cell;
}

@end
