//
//  PhotoAVE.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAVE : UIView

//photos are NSData*
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSMutableArray *) photos;

@end
