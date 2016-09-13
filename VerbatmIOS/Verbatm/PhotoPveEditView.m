//
//  PhotoPveEditView.m
//  Verbatm
//
//  Created by Iain Usiri on 9/12/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "CollectionPinchView.h"
#import "ImagePinchView.h"
#import "EditMediaContentView.h"

#import "SizesAndPositions.h"
#import "PostInProgress.h"
#import "PhotoPveEditView.h"

@interface PhotoPveEditView () <OpenCollectionViewDelegate, EditContentViewDelegate>

@end

@implementation PhotoPveEditView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype) initWithFrame:(CGRect)frame andPinchView:(PinchView *)pinchView
                inPreviewMode: (BOOL) inPreviewMode isPhotoVideoSubview:(BOOL)halfScreen {
    self = [super initWithFrame:frame];
    if (self) {
        self.hasLoadedMedia = YES;
        self.small = NO;
        self.photoVideoSubview = halfScreen;
        self.pinchView = pinchView;
        if([self.pinchView isKindOfClass:[CollectionPinchView class]]){
            [self addContentFromImagePinchViews:((CollectionPinchView *)self.pinchView).imagePinchViews];
        }else{
            [self addContentFromImagePinchViews:[NSMutableArray arrayWithObject:pinchView]];
        }
        [super initialFormatting];
    }
    return self;
}

#pragma mark - EditContentViewDelegate methods -

-(void) textIsEditing {
    
    if (self.imageContainerViews.count > 1) {
        // Pause slideshow
        if(!self.rearrangeView) {
            [self pauseToRearrangeButtonPressed];
        }
        [self.rearrangeView setHidden:YES];
        [self.pauseToRearrangeButton setHidden:YES];
    }
    
    if([self.textEntryDelegate respondsToSelector:@selector(editContentViewTextIsEditing)])[self.textEntryDelegate editContentViewTextIsEditing];
}

-(void) textDoneEditing {
    [self.pauseToRearrangeButton setHidden:NO];
    [self.rearrangeView setHidden:NO];
    if([self.textEntryDelegate respondsToSelector:@selector(editContentViewTextDoneEditing)])[self.textEntryDelegate editContentViewTextDoneEditing];
}

-(void) addContentFromImagePinchViews:(NSMutableArray *)pinchViewArray{
    for (ImagePinchView *imagePinchView in pinchViewArray) {
            EditMediaContentView *editMediaContentView = [self getEditContentViewFromPinchView:imagePinchView];
            [self.imageContainerViews addObject:editMediaContentView];
        
    }
    
    [self layoutContainerViews];
    if(pinchViewArray.count > 1) {
        [self createRearrangeButton];
    }
}



-(EditMediaContentView *) getEditContentViewFromPinchView: (ImagePinchView *)pinchView {
    EditMediaContentView * editMediaContentView = [[EditMediaContentView alloc] initWithFrame:self.bounds];
    //this has to be set before we set the text view information
    editMediaContentView.pinchView = pinchView;
    editMediaContentView.povViewMasterScrollView = self.postScrollView;
    editMediaContentView.delegate = self;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    __weak PhotoPVE * weakSelf = self;
    [pinchView getLargerImageWithHalfSize:weakSelf.photoVideoSubview].then(^(UIImage *image) {
        [editMediaContentView displayImage:image isHalfScreen:self.photoVideoSubview
                         withContentOffset:pinchView.imageContentOffset];
        
        BOOL textColorBlack = [pinchView.textColor isEqual:[UIColor blackColor]];
        [editMediaContentView setText:pinchView.text
                     andTextYPosition:[pinchView.textYPosition floatValue]
                    andTextColorBlack:textColorBlack
                     andTextAlignment:[pinchView.textAlignment integerValue]
                          andTextSize:[pinchView.textSize floatValue] andFontName:pinchView.fontName];
        if (self.imageContainerViews.count < 2) {
            [editMediaContentView showTextToolbar:YES];
        }
        if (self.currentlyOnScreen) {
            [editMediaContentView onScreen];
        }
    });
    return editMediaContentView;
}


-(void)createRearrangeButton {
    [self.pauseToRearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
    self.pauseToRearrangeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.pauseToRearrangeButton addTarget:self action:@selector(pauseToRearrangeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:self.pauseToRearrangeButton];
}

-(void) pauseToRearrangeButtonPressed {
    // Pausing slideshow
    if(![self.pinchView isKindOfClass:[CollectionPinchView class]])return;
    
    if(!self.rearrangeView) {
        for (UIView * view in self.imageContainerViews) {
            if([view isKindOfClass:[EditMediaContentView class]]){
                [((EditMediaContentView *)view) showTextToolbar:YES];
            }
        }
        
        [self offScreen];
        CGFloat y_pos = (self.photoVideoSubview) ? 0.f : CUSTOM_NAV_BAR_HEIGHT;
        CGRect frame = CGRectMake(0.f,y_pos, self.frame.size.width, OPEN_COLLECTION_FRAME_HEIGHT);
        OpenCollectionView *rearrangeView = [[OpenCollectionView alloc] initWithFrame:frame
                                                                    andPinchViewArray:((CollectionPinchView*)self.pinchView).imagePinchViews];
        [self insertSubview: rearrangeView belowSubview:self.pauseToRearrangeButton];
        self.rearrangeView = rearrangeView;
        self.rearrangeView.delegate = self;
        [self.pauseToRearrangeButton setImage:[UIImage imageNamed:PLAY_SLIDESHOW_ICON] forState:UIControlStateNormal];
    } else {
        for (UIView * view in self.imageContainerViews) {
            if([view isKindOfClass:[EditMediaContentView class]]){
                [((EditMediaContentView *)view) exiting];
                [((EditMediaContentView *)view) showTextToolbar: NO];
            }
        }
        [self.pauseToRearrangeButton setImage:[UIImage imageNamed:PAUSE_SLIDESHOW_ICON] forState:UIControlStateNormal];
        [self.rearrangeView exitView];
        [self playSlideshow];
    }
}

-(void)animateNextView{
    __weak PhotoPVE * weakSelf = self;
    NSInteger nextIndex = weakSelf.currentPhotoIndex + 1;
    if(weakSelf.slideShowPlaying && !weakSelf.animating){
        //todo: This is a hack. Find where animations get disabled
        if(![UIView areAnimationsEnabled]){
            //            NSLog(@"Animations are disabled.");
            [UIView setAnimationsEnabled:YES];
        }
        [UIView animateWithDuration:IMAGE_FADE_OUT_ANIMATION_DURATION animations:^{
            weakSelf.animating = YES;
            
            [weakSelf setImageViewsToLocation:nextIndex];
        } completion:^(BOOL finished) {
            weakSelf.animating = NO;
            [super startBaseSlideshowTimer];
        }];
        
    }
}


-(void)playSlideshow{
    if(!self.animating){
        CGRect  v_frame= CGRectMake(0.f, 0.f, self.frame.size.width, self.pauseToRearrangeButton.frame.origin.y);
         CGRect h_frame= CGRectMake(0.f, self.pauseToRearrangeButton.frame.origin.y,self.pauseToRearrangeButton.frame.origin.x - 10.f,
                                self.frame.size.height - self.pauseToRearrangeButton.frame.origin.y);
        
        //create view to sense swiping
        if(self.panGestureSensingViewHorizontal == nil){
            UIView *panViewVertical = [[UIView alloc] initWithFrame:v_frame];
            [self addSubview: panViewVertical];
            self.panGestureSensingViewVertical = panViewVertical;
            self.panGestureSensingViewVertical.backgroundColor = [UIColor clearColor];
            
            UIView *panViewHorizontal = [[UIView alloc] initWithFrame:h_frame];
            [self addSubview: panViewHorizontal];
            self.panGestureSensingViewHorizontal = panViewHorizontal;
            self.panGestureSensingViewHorizontal.backgroundColor = [UIColor clearColor];
            
            [self bringSubviewToFront:self.panGestureSensingViewVertical];
            [self bringSubviewToFront:self.panGestureSensingViewHorizontal];
            [self bringSubviewToFront: self.pauseToRearrangeButton];
        }
        
        [super startBaseSlideshowTimer];
    }
    self.slideShowPlaying = YES;
}


//new pinchview tapped in rearange view so we need to change what's presented
-(void)pinchViewSelected:(PinchView *) pv{
    NSInteger imageIndex = 0;
    for(NSInteger index = 0; index < self.imageContainerViews.count; index++){
        EditMediaContentView *eview = self.imageContainerViews[index];
        if(eview.pinchView == pv){
            imageIndex = index;
            break;
        }
    }
    [self setImageViewsToLocation:imageIndex];
}

#pragma mark OpenCollectionView delegate method

-(void) collectionClosedWithFinalArray:(NSMutableArray *) pinchViews {
    if(self.rearrangeView){
        [self.rearrangeView removeFromSuperview];
        self.rearrangeView = nil;
    }
    self.imageContainerViews = nil;
    ((CollectionPinchView*)self.pinchView).imagePinchViews = pinchViews;
    [[PostInProgress sharedInstance] removePinchViewAtIndex:self.indexInPost andReplaceWithPinchView:self.pinchView];
    [self.pinchView renderMedia];
    [self addContentFromImagePinchViews: pinchViews];
}


@end
