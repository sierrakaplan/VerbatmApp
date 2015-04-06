//
//  verbatmArticleDownloader.m
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 3/27/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "verbatmArticleDownloader.h"

@interface verbatmArticleDownloader()
#define ARTICLE_AUTHOR_RELATIONSHIP @"articleAuthorRelation"

@end
@implementation verbatmArticleDownloader

-(Article*)downloadArticleWithTitle:(NSString *)title andAuthor:(VerbatmUser *)user
{
    PFQuery* query = [PFQuery queryWithClassName: @"Article"];
    [query whereKey: ARTICLE_AUTHOR_RELATIONSHIP equalTo:user];
    [query whereKey: @"title" equalTo:title];
    return [[query findObjects]firstObject];
}

-(NSArray*)downloadAllVerbatmArticle
{
    PFQuery* query = [PFQuery queryWithClassName:@"Article"];
    return [query findObjects];
}

@end
