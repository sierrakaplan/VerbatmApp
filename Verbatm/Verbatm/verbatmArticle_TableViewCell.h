//
//  verbatmArticle_TableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface verbatmArticle_TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UILabel *sandwich;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightSandwich;
@property (weak, nonatomic) IBOutlet UILabel *rightAuthor;
@end
