//
//  SharingLinkView.h
//  Verbatm
//
//  Created by Iain Usiri on 6/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 This view appears to prompt the user to share to FB, TW, SMS and to copy a link.
 This is not a reblog view  -- it only appears in the publish screen for now
 */

@protocol ShareLinkViewProtocol <NSObject>

-(void) continueToPublish;
-(void) cancelPublishing;


@end


@interface SharingLinkView : UIView
@property (nonatomic, weak) id <ShareLinkViewProtocol> delegate;
@end
