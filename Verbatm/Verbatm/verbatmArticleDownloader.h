//
//  verbatmArticleDownloader.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 3/27/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "VerbatmUser.h"
#import <Parse/Parse.h>

@interface verbatmArticleDownloader : NSObject

/*THIS METHOD DOWNLOADS AN ARTICLE SPECIFIED BY THE TITLE AND AUTHOR GIVE*/
/*THIS METHOD BLOCKS: AVOID CALLING ON MAIN THREAD*/
-(Article*)downloadArticleWithTitle:(NSString*)title andAuthor:(VerbatmUser*)user;


@end
