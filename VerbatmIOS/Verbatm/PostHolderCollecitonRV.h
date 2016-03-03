//
//  postHolderCollecitonRV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import "POVView.h"

@interface PostHolderCollecitonRV : UICollectionViewCell
-(void)presentPost:(PFObject *) postObject;
-(void)presentPOV:(POVView *)pov;
-(void)onScreen;
-(void)offScreen;

@property (nonatomic) BOOL isHomeProfileOrFeed;//profile of the current logged in user
@property (nonatomic, readonly) POVView * ourCurrentPOV;


@end
