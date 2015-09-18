//
//  verbatmArticle_TableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedTableViewCellDelegate <NSObject>

// Lets table view know the two half circles have been pinched
// so that it can select the row
-(void) successfullyPinchedTogetherAtIndexPath: (NSIndexPath*) indexPath;

@end

@interface FeedTableViewCell : UITableViewCell

// The cell's row index (needs to pass this to its delegate when it is pinched)
@property (nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) id<FeedTableViewCellDelegate> delegate;

//Loads a normal looking story cell
-(void)setContentWithUsername:(NSString *) username andTitle: (NSString *) title andCoverImage: (UIImage*) coverImage;

//Loads a publishing story cell
-(void)setLoadingContentWithUsername:(NSString *) username andTitle: (NSString *) title andCoverImage: (UIImage*) coverImage;

-(void)stopActivityIndicator;

@end
