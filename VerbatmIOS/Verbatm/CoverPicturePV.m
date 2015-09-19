//
//  CoverPicturePV.m
//  Verbatm
//
//  Created by Iain Usiri on 9/15/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "CoverPicturePV.h"
#import "Styles.h"

@interface CoverPicturePV ()
    @property (strong, nonatomic) UILabel* addCoverPicLabel;
    //we are redeclaring this property fromt the super class so that we can acceess it. It's
    //not duplicated in memory.
    @property (strong, nonatomic) UIImageView *imageView;
@end


@implementation CoverPicturePV
@dynamic imageView;

-(instancetype)initWithRadius:(float)radius  withCenter:(CGPoint)center andImage:(UIImage*)image {
    
    self = [super initWithRadius:radius withCenter:center andImage:image];
    if(self){
        [self formatSelf];
    }
    return self;
}

-(void) formatSelf {
    [self setBackgroundColor: [UIColor clearColor]];
    [self formatAddCoverPicLabel];
    self.layer.borderColor = [UIColor COVER_PIC_CIRCLE_COLORE].CGColor;
}

-(void) formatAddCoverPicLabel {
    self.addCoverPicLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.addCoverPicLabel.textAlignment = NSTextAlignmentCenter;
    self.addCoverPicLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addCoverPicLabel.numberOfLines = 3;
    self.addCoverPicLabel.text = @"Cover Picture";
    [self.addCoverPicLabel setTextColor:[UIColor TELL_YOUR_STORY_COLOR]];
    self.addCoverPicLabel.font = [UIFont fontWithName:ADD_COVER_PIC_FONT size: ADD_COVER_PIC_TEXT_SIZE];
    [self.background addSubview: self.addCoverPicLabel];
}

-(void) setNewImageWith: (UIImage*) image {
    [super putNewImage:image];
    if(self.addCoverPicLabel)[self.addCoverPicLabel removeFromSuperview];
    self.containsImage = YES;
}

-(UIImage*) getImage {
    return [super getImage];
}

-(void) removeImage {
    [self.imageView setImage:nil];
    
    [self.background addSubview: self.addCoverPicLabel];
}


@end
