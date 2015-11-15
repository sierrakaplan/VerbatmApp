//
//  imageFiltered.h
//  Verbatm
//
//  Created by Iain Usiri on 11/14/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 This class has images and their filtered counterparts. It manages swiping and changing the filtered image
 */
@interface imageFiltered : UIImageView

-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage *) image;

@end
