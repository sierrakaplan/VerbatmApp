//
//  v_MultiplePhotoText.h
//  Verbatm
//
//  Created by Iain Usiri on 4/4/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "v_multiplePhoto.h"

@interface v_MultiplePhotoText : v_multiplePhoto
-(id)initWithFrame:(CGRect)frame andAssets:(NSMutableArray *)photoList andText:(NSString*)text;
-(void)addSwipeGesture;
@end
