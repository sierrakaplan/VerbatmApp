//
//  POVLikeAndShareBar.m
//  Verbatm
//
//  Created by Iain Usiri on 12/29/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//


#import "Icons.h"
#import "POVLikeAndShareBar.h"
#import "SizesAndPositions.h"
#import "Styles.h"


@interface POVLikeAndShareBar ()
@property (nonatomic,strong) UIButton * likeButton;
@property (nonatomic,strong) UIButton * numLikesButton;
@property (nonatomic, strong) UIButton * shareButon;
@property (nonatomic,strong) UIButton * numSharesButton;
@property (nonatomic, strong) UILabel * pageNumberLabel;


@property (strong, nonatomic) UIImage* likeButtonNotLikedImage;
@property (strong, nonatomic) UIImage* likeButtonLikedImage;


#define BUTTON_WALLOFFSET 5.f
#define NUMBER_FONT_SIZE 18.f
#define ICON_SPACING_GAP 5.f
@end



@implementation POVLikeAndShareBar



-(instancetype) initWithFrame:(CGRect)frame numberOfLikes:(NSNumber *) numLikes numberOfShares:(NSNumber *) numShares numberOfPages:(NSNumber *) numPages andStartingPageNumber:(NSNumber *) startPage {
    
    self = [super initWithFrame:frame];
    if(self){
        [self creatButtonsWithNumLike:numLikes andNumShare:numShares];
    }
    return self;
}


-(void) creatButtonsWithNumLike:(NSNumber *) numLikes andNumShare:(NSNumber *) numShares{
    
    //create like button
    CGRect likeButtonFrame = CGRectMake(BUTTON_WALLOFFSET, BUTTON_WALLOFFSET,
                                        LIKE_BUTTON_SIZE_WIDTH, LIKE_BUTTON_SIZE_HEIGHT);
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setFrame:likeButtonFrame];
    self.likeButtonLikedImage = [UIImage imageNamed:LIKE_ICON];
    self.likeButtonNotLikedImage = [UIImage imageNamed:LIKE_PRESSED_ICON];
    [self.likeButton setImage:self.likeButtonNotLikedImage forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.likeButton];
    
    
    //create Number of likes button
    self.numLikesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //create "followers" text
    NSDictionary * followersTextAttributes =@{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName: [UIFont fontWithName:TAB_BAR_FOLLOWERS_FONT size:NUMBER_FONT_SIZE]};
    
    NSAttributedString * followersText = [[NSAttributedString alloc] initWithString:numLikes.stringValue attributes:followersTextAttributes];
    
    [self.numLikesButton setAttributedTitle:followersText forState:UIControlStateNormal];
    CGSize textSize = [numLikes.stringValue sizeWithAttributes:followersTextAttributes];
    
    CGRect likeNumberButtonFrame = CGRectMake(self.likeButton.frame.origin.x +
                                              self.likeButton.frame.size.width + ICON_SPACING_GAP, BUTTON_WALLOFFSET,
                                              textSize.width, self.frame.size.height - (BUTTON_WALLOFFSET*2));
     [self.numLikesButton setFrame:likeNumberButtonFrame];
    
    [self.numLikesButton addTarget:self action:@selector(numLikesButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.numLikesButton];
    
    
    
    //create share button
    CGRect shareButtonFrame = CGRectMake(self.numLikesButton.frame.origin.x +
                                        self.numLikesButton.frame.size.width + ICON_SPACING_GAP,
                                        BUTTON_WALLOFFSET,
                                        LIKE_BUTTON_SIZE_WIDTH, LIKE_BUTTON_SIZE_WIDTH);
    
    self.shareButon = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButon setFrame:shareButtonFrame];
    [self.shareButon setImage:[UIImage imageNamed:SHARE_ICON] forState:UIControlStateNormal];
    [self.shareButon addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.shareButon];
    
    
    
    //create numSharesButton of likes button
    self.numSharesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //create "followers" text
    
    NSAttributedString * sharesText = [[NSAttributedString alloc] initWithString:numShares.stringValue attributes:followersTextAttributes];
    
    [self.numSharesButton setAttributedTitle:sharesText forState:UIControlStateNormal];
    CGSize textSizeNumShares = [numShares.stringValue sizeWithAttributes:followersTextAttributes];
    CGRect shareNumberButtonFrame = CGRectMake(self.shareButon.frame.origin.x +
                                               self.shareButon.frame.size.width +
                                               BUTTON_WALLOFFSET, BUTTON_WALLOFFSET,
                                              textSizeNumShares.width, self.frame.size.height - (BUTTON_WALLOFFSET*2));
    [self.numSharesButton setFrame:shareNumberButtonFrame];
    
    [self.numSharesButton addTarget:self action:@selector(numSharesButtonSelected) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.numSharesButton];
}

-(void)shareButtonPressed{
    
}

-(void) likeButtonSelected {
    
}

-(void) numLikesButtonSelected {
    
}

-(void) numSharesButtonSelected {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
