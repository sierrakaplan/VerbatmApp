//
//  ChannelOrUsernameCV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "ChannelOrUsernameCV.h"
#import "SizesAndPositions.h"
#import "Styles.h"


@interface ChannelOrUsernameCV ()

    @property (nonatomic) BOOL isAChannel;
    @property (nonatomic) BOOL isAChannelIFollow;

    @property (nonatomic) UILabel * cellTextLabel;
    @property (nonatomic) NSString * cellText;

@end

@implementation ChannelOrUsernameCV

- (void)awakeFromNib {
    // Initialization code
}


- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel isAChannelThatIFollow:(BOOL) channelThatIFollow {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier] ;
    
    if (self) {
        
        self.backgroundColor = CHANNEL_TAB_BAR_BACKGROUND_COLOR_UNSELECTED;
        self.isAChannel = isChannel;
        self.isAChannelIFollow = channelThatIFollow;
        
        
    }
    
    return self;
}



#pragma mark - Edit Cell formatting -


-(void)setCellTextTitle:(NSString *) title {
    self.cellText = title;
}

-(void)layoutSubviews {
    //do formatting here
    [self setLabelAndPresent];
}


-(void)setLabelAndPresent {
   
    
    if(!self.cellTextLabel){
        
        CGRect labelFrame = CGRectMake(-5.f, 0.f, self.frame.size.width + 10, self.frame.size.height);
        
        self.cellTextLabel = [[UILabel alloc] initWithFrame:labelFrame];
        
        self.cellTextLabel.backgroundColor = [UIColor clearColor];
        
        //add thin white border
        self.cellTextLabel.layer.borderWidth = 0.3;
        self.cellTextLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        
        [self addSubview:self.cellTextLabel];
    }
    
    if(![self.cellTextLabel.text isEqualToString:self.cellText]){
        NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
        paragraphStyle.alignment    = NSTextAlignmentCenter;
        
        NSDictionary * informationAttribute = @{NSForegroundColorAttributeName:
                                                    [UIColor whiteColor],
                                                NSFontAttributeName:
                                                    [UIFont fontWithName:USER_CHANNEL_LIST_FONT size:USER_CHANNEL_LIST_FONT_SIZE],
                                                NSParagraphStyleAttributeName:paragraphStyle};
        
        NSAttributedString * titleAttributed = [[NSAttributedString alloc] initWithString:self.cellText attributes:informationAttribute];
        
        [self.cellTextLabel setAttributedText:titleAttributed];
    }
    

}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
