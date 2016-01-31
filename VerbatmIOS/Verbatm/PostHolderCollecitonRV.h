//
//  postHolderCollecitonRV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>

@interface PostHolderCollecitonRV : UICollectionViewCell
-(void)presentPost:(PFObject *) postObject;
-(void)onScreen;
-(void)offScreen;
@end
