//
//  v_textVideo.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/18/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VideoAVE.h"

@interface TextVideoAVE : VideoAVE
-(id)initWithFrame:(CGRect)frame andAssets:(NSArray *)videoDataList andText:(NSString*)text;
-(void)addSwipeGesture;
@end
