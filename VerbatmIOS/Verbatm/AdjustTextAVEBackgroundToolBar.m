//
//  AdjustTextAVEBackgroundToolBar.m
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "AdjustTextAVEBackgroundToolBar.h"
#import "UtilityFunctions.h"

@interface AdjustTextAVEBackgroundToolBar()

@property (nonatomic) NSMutableArray * selectionOptions;
@property (nonatomic) NSArray * smallBackgrounds;
@property (nonatomic) NSArray * fullScreenbackgrounds;

#define IMAGE_GAP 10.f
#define IMAGE_SIZE (self.frame.size.height - 5.f)
@end



@implementation AdjustTextAVEBackgroundToolBar



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.smallBackgrounds = @[@"circle background 3",@"circle background 4",@"circle background 5",@"circle background 6"];
        self.fullScreenbackgrounds = @[@"Text AVE background 3",@"Text AVE background 4",@"Text AVE background 5",@"Text AVE background 6"];
        [self createScrollingViews];
    }
    return self;
}

-(void)createScrollingViews{
    
    
    
    
    CGFloat xAdvanced = IMAGE_GAP;
    for(int i = 0; i < 4; i++) {
        CGRect  buttomFrame = CGRectMake(xAdvanced, 2.f, IMAGE_SIZE, IMAGE_SIZE);
        UIButton * button = [UtilityFunctions getButtonWithFrame:buttomFrame andIcon:self.smallBackgrounds[i] andSelector:@selector(buttonSelected:) andTarget:self];
        [self addSubview:button];
        [self.selectionOptions addObject:button];
        xAdvanced = xAdvanced + IMAGE_SIZE + IMAGE_GAP;
    }
    
    self.contentSize = CGSizeMake(xAdvanced + IMAGE_GAP, 0.f);
    [self setScrollEnabled:YES];
}


-(void)buttonSelected:(id)sender {
    NSInteger buttonIndex = [self.selectionOptions indexOfObject:sender];
    [self.toolBarDelegate changeImageToImage:self.fullScreenbackgrounds[buttonIndex]];
}

-(NSMutableArray *)selectionOptions{
    if(!_selectionOptions)_selectionOptions=[[NSMutableArray alloc] init];
    return _selectionOptions;
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
