//
//  verbatmArticle_TableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableViewCell : UITableViewCell

//Loads a normal looking story cell
-(void)setContentWithUsername:(NSString *) username andTitle: (NSString *) title andCoverImage: (UIImage*) coverImage;

//Loads a publishing story cell
-(void)setLoadingContentWithUsername:(NSString *) username andTitle: (NSString *) title andCoverImage: (UIImage*) coverImage;

-(void)startActivityIndicatrForPlaceholder;

@end
