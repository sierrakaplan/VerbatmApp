//
//  PhotoAVE.h
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 7/23/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoAVEDelegate <NSObject>

// Lets super class (with scroll view) know if the circle is currently dragging
-(void) startedDraggingAroundCircle;
-(void) stoppedDraggingAroundCircle;

@end

@interface PhotoAVE : UIView

@property (strong, nonatomic) id<PhotoAVEDelegate> delegate;

//photos are UIImage*
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSArray *) photos;

-(void) showAndRemoveCircle;

@end
