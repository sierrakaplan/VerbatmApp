//
//  imageFiltered.m
//  Verbatm
//
//  Created by Iain Usiri on 11/14/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "imageFiltered.h"

@interface imageFiltered ()
#pragma mark FilteredPhotos
@property (nonatomic, weak) NSArray * filteredImages;
@property (nonatomic) NSInteger imageIndex;

@end


@implementation imageFiltered


-(instancetype) initWithFrame:(CGRect)frame andImage:(UIImage *) image{
    self = [super initWithFrame:frame];
    if(self){
        
    }
    
    return self;
}








/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
