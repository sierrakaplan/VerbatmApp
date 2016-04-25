//
//  postHolderCollecitonRV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import "PostView.h"

@interface PostCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly) PostView *currentPostView;

-(void) presentPostFromPCActivityObj: (PFObject *) pfActivityObj andChannel:(Channel*) channelForList
					withDeleteButton: (BOOL) withDelete;

-(void) shiftLikeShareBarDown:(BOOL) down;

-(void) almostOnScreen;
-(void) onScreen;
-(void) offScreen;


@end
