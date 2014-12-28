//
//  Page.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/27/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "verbatmCustomPinchView.h"

@interface Page : PFObject
#pragma mark - required subclassing methods
+(NSString*)parseClassName;
+(void)load;

#pragma mark - methods for getting and setting page properties - 
-(instancetype)initWithPinchObject:(verbatmCustomPinchView*)p_view;
-(NSString*)getText;
-(NSMutableArray*)getMediaObjects;


#pragma mark - bools to tell what type of media make up page -
@property (readonly,nonatomic) BOOL there_is_text;
@property (readonly, nonatomic) BOOL there_is_video;
@property (readonly, nonatomic) BOOL there_is_picture;
@end
