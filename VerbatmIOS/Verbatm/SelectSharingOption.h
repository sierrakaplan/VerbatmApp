//
//  SelectSharingOption.h
//  Verbatm
//
//  Created by Iain Usiri on 1/2/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Shows the user what options they have for sharing
 and allows them to select one.
 What's shown is a logo, company name and a select button.
 */


typedef enum ShareOptions{
    Verbatm = 0,
    Twitter = 1,
    Facebook = 2,
}ShareOptions;


@protocol SelectSharingOptionProtocol <NSObject>
-(void)shareOptionSelected:(ShareOptions) shareOption;
-(void)shareOptionDeselected:(ShareOptions) shareOption;

@end


@interface SelectSharingOption : UIScrollView
@property (nonatomic) id <SelectSharingOptionProtocol> delegate;
//removes all selected content
-(void)unselectAllOptions;
@end
