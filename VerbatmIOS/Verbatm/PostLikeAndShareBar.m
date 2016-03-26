//
//  PostLikeAndShareBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//


#import "Icons.h"
#import "PostLikeAndShareBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"
#import "Like_BackendManager.h"

@interface PostLikeAndShareBar ()

@property (nonatomic,strong) UIButton * likeButton;
@property (nonatomic,strong) UIButton * numLikesButton;
@property (nonatomic, strong) UIButton * shareButon;
@property (nonatomic,strong) UIButton * numSharesButton;
@property (nonatomic, strong) UILabel * pageNumberLabel;

@property (nonatomic, strong) UIButton * muteButton;
@property (nonatomic) BOOL isMuted;

@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) NSNumber * totalNumberOfPages;

@property (nonatomic) NSNumber * totalNumberOfLikes;//number of likes on our related AVE

@property (nonatomic) NSDictionary * followNumberTextAttributes;

#define BUTTON_WALLOFFSET 10.f
#define NUMBER_FONT_SIZE 10.f
#define ICON_SPACING_GAP 20.f
#define NUMBER_TEXT_FONT CHANNEL_TAB_BAR_FOLLOWERS_FONT
#define NUMBER_TEXT_FONT_SIZE 25.f

#define OF_TEXT_FONT CHANNEL_TAB_BAR_FOLLOWERS_FONT
#define OF_TEXT_FONT_SIZE 18.f

@end

@implementation PostLikeAndShareBar

-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage {
    
    self = [super initWithFrame:frame];
    if(self){
        
        [self creatButtonsWithNumLike:numLikes andNumShare:numShares];
        self.totalNumberOfPages = numPages;
        self.totalNumberOfLikes = numLikes;
        [self formatView];
        self.isMuted = NO;
    }
    return self;
}

-(void)formatView{
    self.backgroundColor = LIKE_SHARE_BAR_BACKGROUND_COLOR;
}

-(void) createCounterLabelStartingAtPage:(NSNumber *) startPage outOf:(NSNumber *) totalPages{
    NSAttributedString * pageCounterText = [self createCounterStringStartingAtPage:startPage outOf:totalPages];
    CGRect labelFrame = CGRectMake(self.frame.size.width - BUTTON_WALLOFFSET - pageCounterText.size.width, BUTTON_WALLOFFSET, pageCounterText.size.width, self.frame.size.height - (BUTTON_WALLOFFSET*2));
    
    self.pageNumberLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [self.pageNumberLabel setAttributedText:pageCounterText];
    [self addSubview:self.pageNumberLabel];
}

//creates the text for the numbers at the bottom right that show what page you're on and how
//many there are left
-(NSAttributedString *) createCounterStringStartingAtPage:(NSNumber *) startPage outOf:(NSNumber *) totalPages{
    //create attributed string of number of pages
    NSDictionary * numberTextAttributes =@{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName: [UIFont fontWithName:NUMBER_TEXT_FONT size:NUMBER_TEXT_FONT_SIZE]};
    
    
    NSMutableAttributedString * pageWeAreOn = [[NSMutableAttributedString alloc] initWithString:startPage.stringValue attributes:numberTextAttributes];
    
    NSAttributedString * totalNumberOfPages = [[NSMutableAttributedString alloc] initWithString:totalPages.stringValue attributes:numberTextAttributes];
    
    //the small "of" word between numbers. eg 1of5
    NSDictionary * ofTextAttributes =@{
                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                           NSFontAttributeName: [UIFont fontWithName:OF_TEXT_FONT size:OF_TEXT_FONT_SIZE]};
    
    NSMutableAttributedString * ofText = [[NSMutableAttributedString alloc] initWithString:@"of" attributes:ofTextAttributes];
    
    [pageWeAreOn appendAttributedString:ofText];
    [pageWeAreOn appendAttributedString:totalNumberOfPages];
    return pageWeAreOn;
}

-(void) creatButtonsWithNumLike:(NSNumber *) numLikes andNumShare:(NSNumber *) numShares {
    [self createShareButton];
    [self createLikeButton];
    [self createLikeButtonNumbers:numLikes];
}

-(void)createShareButton {
    //create share button
    CGRect shareButtonFrame = CGRectMake(BUTTON_WALLOFFSET, BUTTON_WALLOFFSET,
                                         LIKE_SHARE_BAR_BUTTON_SIZE, LIKE_SHARE_BAR_BUTTON_SIZE);
    
    self.shareButon = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButon setFrame:shareButtonFrame];
    [self.shareButon setImage:[UIImage imageNamed:SHARE_ICON] forState:UIControlStateNormal];
    [self.shareButon addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.shareButon];
}

-(void)createLikeButton {
    //create like button
    CGRect likeButtonFrame =  CGRectMake(self.shareButon.frame.origin.x + self.shareButon.frame.size.width +
                                         ICON_SPACING_GAP,
                                         BUTTON_WALLOFFSET,
                                         LIKE_SHARE_BAR_BUTTON_SIZE, LIKE_SHARE_BAR_BUTTON_SIZE);
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setFrame:likeButtonFrame];
    self.likeButtonLikedImage = [UIImage imageNamed:LIKE_ICON_PRESSED];
    self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_ICON_UNPRESSED];
    [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.likeButton];
}

-(void)createLikeButtonNumbers:(NSNumber *) numLikes {
    if(self.numLikesButton){
        [self.numLikesButton removeFromSuperview];
        self.numLikesButton = nil;
    }
    self.numLikesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:numLikes.stringValue attributes:self.followNumberTextAttributes];
    [self.numLikesButton setAttributedTitle:followersText forState:UIControlStateNormal];
    CGSize textSize = [numLikes.stringValue sizeWithAttributes:self.followNumberTextAttributes];
    
    CGFloat numberHeight = self.frame.size.height - (BUTTON_WALLOFFSET*2);
    
    CGRect likeNumberButtonFrame = CGRectMake(self.likeButton.frame.origin.x + LIKE_SHARE_BAR_BUTTON_SIZE/2.f,
											  self.likeButton.center.y - (numberHeight/2.f),
                                              textSize.width, numberHeight);
    [self.numLikesButton setFrame:likeNumberButtonFrame];
    
    [self.numLikesButton addTarget:self action:@selector(numLikesButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.numLikesButton];
}

-(void)shouldStartPostAsLiked:(BOOL) postLiked{
    if(postLiked){
        [self.likeButton setImage:self.likeButtonLikedImage  forState:UIControlStateNormal];
        self.isLiked = YES;
        
    }else{
        [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
        self.isLiked = NO;
    }
}

//the icon is selected
-(void)shareButtonPressed{
    [self.delegate userAction:Share isPositive:YES];
}

//the icon is selected
-(void) likeButtonSelected {
    if(self.isLiked){
        [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
        self.isLiked = NO;
    }else{
        [self.likeButton setImage: self.likeButtonLikedImage forState:UIControlStateNormal];
        self.isLiked = YES;
    }
    
    [self changeLikeCount:self.isLiked];
    
    [self.delegate userAction:Like isPositive:self.isLiked];
}

//allows us to change our page number to the next number
-(void)setPageNumber:(NSNumber *) pageNumber{
	//todo: remove page number code?
//    if(pageNumber.integerValue < self.totalNumberOfPages.integerValue ||
//       pageNumber.integerValue >= 1){
//        if(self.pageNumberLabel)[self.pageNumberLabel removeFromSuperview];
//        [self createCounterLabelStartingAtPage:pageNumber outOf:self.totalNumberOfPages];
//    }
}

-(void)changeLikeCount:(BOOL)up{
    NSInteger currentLikes = self.totalNumberOfLikes.integerValue;
    if(up){
        currentLikes= 1+currentLikes;
    }else{
        currentLikes = currentLikes -1;
        if(currentLikes < 0) currentLikes = 0;
    }
    self.totalNumberOfLikes = [NSNumber numberWithInteger:currentLikes];
    [self createLikeButtonNumbers: self.totalNumberOfLikes];
}

-(void)presentMuteButton:(BOOL) shouldPresent{
    if(shouldPresent){
        [self addSubview:self.muteButton];
    }else{
        [self.muteButton removeFromSuperview];
        self.muteButton = nil;
    }
}

//the actual number view is selected
-(void) numLikesButtonSelected {
    
}

//the actual number view is selected
-(void) numSharesButtonSelected {
    
}

-(void)muteButtonTouched:(id)sender{
    if(self.isMuted){
        self.isMuted = false;
        [self.muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
    }else{
        self.isMuted = true;
        [self.muteButton  setImage:[UIImage imageNamed:MUTED_ICON] forState:UIControlStateNormal];
    }
    
    [self.delegate muteButtonSelected:self.isMuted];
}

#pragma mark - Lazy instantiation -

-(NSDictionary *)followNumberTextAttributes{
    if(!_followNumberTextAttributes){
        _followNumberTextAttributes =@{
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           NSFontAttributeName: [UIFont fontWithName:CHANNEL_TAB_BAR_FOLLOWERS_FONT size:NUMBER_FONT_SIZE]};
    }
    
    return _followNumberTextAttributes;
}

-(UIButton *)muteButton{
    if(!_muteButton){
        _muteButton = [[UIButton alloc] init];
        
        CGRect buttonFrame = CGRectMake(self.likeButton.frame.origin.x + self.likeButton.frame.size.width + ICON_SPACING_GAP,
										BUTTON_WALLOFFSET, LIKE_SHARE_BAR_BUTTON_SIZE, LIKE_SHARE_BAR_BUTTON_SIZE);
        _muteButton.frame = buttonFrame;
        
        [_muteButton setImage:[UIImage imageNamed:UNMUTED_ICON] forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(muteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteButton;
}

@end
