//
//  verbatmArticleAquirer.h
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
@interface verbatmArticleAquirer : NSObject
-(Article*)downloadArticleWithTitle:(NSString*)title andAuthor:(VerbatmUser*)user;
-(BOOL)saveArticleWithPinchObjects:(NSArray *)pinch;
@end
