
//  Created by Iain Usiri on 8/30/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/* Controls the presentation of a single article. It simply manages laying out Pages as well as the playing/stoping of a page when it in/out of view.
 */

#import <UIKit/UIKit.h>

@interface POVView : UIScrollView
-(instancetype)initWithFrame:(CGRect)frame andArticleList: (NSMutableArray *) articlePages;
@end
