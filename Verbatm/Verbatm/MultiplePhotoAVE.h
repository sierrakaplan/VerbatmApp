//
//  v_multiplePhoto.h
//  Verbatm
//
//  Created by Iain Usiri on 3/24/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiplePhotoAVE : UIView
//when there is no text
-(instancetype) initWithFrame:(CGRect)frame andPhotoArray: (NSMutableArray *) photos;
//we use this initializer when there is text to be added
-(id)initWithFrame:(CGRect)frame andAssets:(NSMutableArray *)photoList andText:(NSString*)textUsed;
-(void)addSwipeGesture;
@end
