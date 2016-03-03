//
//  photoVideoWrapperViewForText.h
//  Verbatm
//
//  Created by Iain Usiri on 10/7/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

//	TextOverMediaView takes care of displaying and editing text over an image or a video, within an AVE.

#import <UIKit/UIKit.h>
@interface TextOverMediaView : UIView

@property (nonatomic, strong) UIImageView* imageView;
//NOT IN USE @property (nonatomic, strong) UIImageView* blurPhotoView;
@property (nonatomic, strong) UITextView * textView;
@property (nonatomic, readonly) BOOL textShowing;

-(instancetype) initWithFrame:(CGRect)frame andImage: (UIImage*) image andText: (NSString*) text andTextYPosition: (CGFloat) textYPosition;

-(void) resizeTextView;

-(void) showText: (BOOL) show;

-(void)changeImageTo:(UIImage *) image;

-(void)setText:(NSString *) text;

@end
