//
//  AdjustTextAVEBackgroundToolBar.m
//  Verbatm
//
//  Created by Iain Usiri on 7/26/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "AdjustTextAVEBackgroundToolBar.h"
#import "UtilityFunctions.h"
#import "Styles.h"
#import "Icons.h"
@interface AdjustTextAVEBackgroundToolBar()

@property (nonatomic) NSMutableArray * selectionOptions;
@property (nonatomic) NSArray * circleButtonBackgrounds;
@property (nonatomic) NSArray * fullScreenbackgrounds;

#define IMAGE_GAP 10.f
#define IMAGE_SIZE (self.frame.size.height - 5.f)
@end



@implementation AdjustTextAVEBackgroundToolBar



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundColor:TOP_TOOLBAR_BACKGROUND_COLOR];
        self.circleButtonBackgrounds = TEXTAVE_BACKGROUND_CIRCLE_VIEW_OPTIONS;
        self.fullScreenbackgrounds = TEXTAVE_BACKGROUND_FULLSCREEN_OPTIONS;
        [self createScrollingViews];
    }
    return self;
}

-(void)createScrollingViews{
    CGFloat xAdvanced = IMAGE_GAP;
    for(int i = 0; i < self.circleButtonBackgrounds.count; i++) {
        CGRect  buttomFrame = CGRectMake(xAdvanced, 2.f, IMAGE_SIZE, IMAGE_SIZE);
        UIButton * button = [UtilityFunctions getButtonWithFrame:buttomFrame andIcon:self.circleButtonBackgrounds[i] andSelector:@selector(buttonSelected:) andTarget:self];
        
        if(i == 1){
            // this is the black icon so lets give it a boarder
            //aish should really just give us an icon with a white boarder
            button.layer.cornerRadius = button.frame.size.width/2.f;
            button.layer.borderWidth = 2.f;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        
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


@end
