//
//  verbatmCustomMediaSelectTile.m
//  Verbatm
//
//  Created by Iain Usiri on 9/14/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "verbatmCustomMediaSelectTile.h"

@interface verbatmCustomMediaSelectTile ()
    @property(nonatomic ,strong) UIButton * selectMedia;
    @property (nonatomic ,strong) UIButton * selectText;

#define BUTTON_OFFSET 5
@end

@implementation verbatmCustomMediaSelectTile

#pragma mark - initialize view
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createFramesForButtonsWithFrame: frame];
        [self addButtonsAsSubviews];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.selectText setBackgroundColor:[UIColor greenColor]];
        [self.selectMedia setBackgroundColor:[UIColor yellowColor]];
        
    }
    return self;
}

//Iain
-(void) createFramesForButtonsWithFrame: (CGRect) frame
{
    self.selectText.frame = CGRectMake(BUTTON_OFFSET, BUTTON_OFFSET, frame.size.width/2, frame.size.height-BUTTON_OFFSET*2);
    self.selectMedia.frame = CGRectMake(frame.size.width/2, BUTTON_OFFSET, frame.size.width/2-BUTTON_OFFSET, frame.size.height-BUTTON_OFFSET*2);
}
//Iain
-(void)addButtonsAsSubviews
{
    [self addSubview:self.selectText];
    [self addSubview:self.selectMedia];
}


-(void) addText
{
    [self.customDelegate addTextViewButtonPressedAsBaseView:self.baseSelector];
}

-(void) addMedia
{
    [self.customDelegate addMultiMediaButtonPressedAsBaseView:self.baseSelector];
}
//Iain
//Set the background images for the button views
//To be implemented
-(void) addImagesToButtons
{
    //self.selectMedia.imageView.image = ;
    //self.selectText.imageView.image = ;
}

#pragma mark - *Lazy Instantiation
-(UIButton *) selectMedia
{
    if(!_selectMedia)
    {
        _selectMedia = [[UIButton alloc]init];
        [_selectMedia addTarget:self action:@selector(addMedia) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _selectMedia;
}

-(UIButton *) selectText
{
    if(!_selectText) _selectText = [[UIButton alloc]init];
    [_selectText addTarget:self action:@selector(addText) forControlEvents:UIControlEventTouchUpInside];

    return _selectText;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
