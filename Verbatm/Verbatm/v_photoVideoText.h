//
//  v_photoVideoText.h
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "v_textPhoto.h"

@interface v_photoVideoText : UIView
-(id)initWithFrame:(CGRect)frame forImage:(UIImage *)image andText:(NSString *)text andVideo:(NSArray*)assetList;
-(void)offScreen;
-(void)onScreen;
-(void)addSwipeGesture;
-(void)mutePlayer;
-(void)enableSound;
@end
