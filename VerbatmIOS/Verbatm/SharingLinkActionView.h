//
//  SharingLinkActionView.h
//  Verbatm
//
//  Created by Iain Usiri on 6/17/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ShareLinkActionViewProtocol <NSObject>

-(void) continueToPublish;
-(void) cancelPublishing;


@end

@interface SharingLinkActionView : UIView

@property (nonatomic, weak) id <ShareLinkActionViewProtocol> delegate;

@end
