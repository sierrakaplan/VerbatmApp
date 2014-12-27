//
//  v_photoVideoText.h
//  tester
//
//  Created by Iain Usiri on 12/20/14.
//  Copyright (c) 2014 IainAndLucio. All rights reserved.
//

#import "v_textPhoto.h"

@interface v_photoVideoText : v_textPhoto
-(id)initWithFrame:(CGRect)frame forImage:(UIImage *)image andText:(NSString *)text andAssets:(NSArray*)assetList;
-(void)createGestures;
@end
