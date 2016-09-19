//
//  ChannelOrUsernameCV.h
//  Verbatm
//
//  Created by Iain Usiri on 1/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
#import "Comment.h"


/*
 Cells that display different names in V. from comments to usernames
 */
@protocol VerbatmNameLabelViewProtocol <NSObject>

-(void)deleteCommentSelected:(Comment *)comment;

@end

@interface ChannelOrUsernameCV : UITableViewCell

@property(nonatomic, weak) id <VerbatmNameLabelViewProtocol> delegate;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isChannel:(BOOL) isChannel;

-(void)presentChannel:(Channel *) channel;

-(void)presentComment:(Comment *) commentObject;

-(void)clearView;

+(CGFloat)getHeightForCellFromCommentObject:(Comment *) commentObject;

@end
