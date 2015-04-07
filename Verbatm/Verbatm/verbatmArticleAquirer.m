//
//  verbatmArticleAquirer.m
//  Verbatm
//
//  Created by Iain Usiri on 3/29/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmArticleAquirer.h"

@interface verbatmArticleAquirer ()
#define ARTICLE_AUTHOR_RELATIONSHIP @"articleAuthorRelation"

@end
@implementation verbatmArticleAquirer

+(Article*)downloadArticleWithTitle:(NSString *)title andAuthor:(VerbatmUser *)user
{
    PFQuery* query = [PFQuery queryWithClassName: @"Article"];
    [query whereKey: ARTICLE_AUTHOR_RELATIONSHIP equalTo:user];
    [query whereKey: @"title" equalTo:title];
    return [[query findObjects]firstObject];
}

+(BOOL)saveArticleWithPinchObjects:(NSArray *)pinchObjects title:(NSString *)title withSandwichFirst:(NSString *)firstPart andSecond:(NSString*)secondPart
{
    Article * this_article = [[Article alloc] initAndSaveWithTitle:title andPinchObjects:pinchObjects];
    [this_article setSandwich:firstPart at:secondPart];
    return [this_article save];
}

+(NSArray*)downloadAllArticles
{
    PFQuery* query = [PFQuery queryWithClassName: @"Article"];
    return [query findObjects];
}


@end
