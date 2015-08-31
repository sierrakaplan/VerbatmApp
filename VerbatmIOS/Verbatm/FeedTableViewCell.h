//
//  verbatmArticle_TableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableViewCell : UITableViewCell
/*sets the text and username for the cell*/
-(void)setContentWithUsername:(NSString *) username andTitle: (NSString *) title;
@end