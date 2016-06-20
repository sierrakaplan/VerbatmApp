//
//  LoadingIndicator.h
//  Verbatm
//
//  Created by Iain Usiri on 3/8/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingIndicator : UIImageView

-(instancetype)initWithCenter:(CGPoint ) center andImage: (UIImage *) loadImage;

-(void)startCustomActivityIndicator;

-(void)stopCustomActivityIndicator;

@end
