//
//  v_multiVidTextPhoto.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/25/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "v_multiplePhotoVideo.h"

@interface v_multiVidTextPhoto : v_multiplePhotoVideo
-(id)initWithFrame:(CGRect)frame andMedia:(NSArray *)media andText:(NSString*)text;
-(void)addSwipeGesture;
-(void)addTapGesture;
@end
