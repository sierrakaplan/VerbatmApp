//
//  verbatmArticleUploader.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 3/27/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmArticleUploader.h"

@implementation verbatmArticleUploader

-(BOOL)saveArticleWithPinchObjects:(NSArray *)pinchObjects title:(NSString *)title withSandwichFirst:(NSString *)firstPart andSecond:(NSString*)secondPart
{
    Article* this_article = [[Article alloc] initAndSaveWithTitle:title andPinchObjects:pinchObjects];
    [this_article setSandwich:firstPart at:secondPart];
    return [this_article save];
}

@end
