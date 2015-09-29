//
//  verbatmArticle_TableViewCell.h
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "GTLDateTime.h"
#import <UIKit/UIKit.h>

@class FeedTableViewCell;

@protocol FeedTableViewCellDelegate <NSObject>

// Lets table view know the two half circles have been pinched
// so that it can select the row (passes self back so it knows what cell)
-(void) successfullyPinchedTogetherCell: (FeedTableViewCell*) cell;

@end

@interface FeedTableViewCell : UITableViewCell

// The cell's row index (needs to pass this to its delegate when it is pinched)
@property (nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) id<FeedTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSString* title;

//Loads a normal looking story cell
-(void) setContentWithUsername:(NSString *) username andTitle: (NSString *) title
				 andCoverImage: (UIImage*) coverImage andDateCreated: (GTLDateTime*) dateCreated
				   andNumLikes: (NSNumber*) numLikes;

//Loads a publishing story cell
-(void) setLoadingContentWithUsername:(NSString *) username andTitle: (NSString *) title
						andCoverImage: (UIImage*) coverImage;

-(void)stopActivityIndicator;

// If it was selected (by a tap for example)
// Then animate the circles together before calling delegate method
// Telling that it was pinched together
-(void) wasSelected;

// After being selected needs to reset where semi circles are
// And do other formatting to be back to normal state
-(void) deSelect;

@end

