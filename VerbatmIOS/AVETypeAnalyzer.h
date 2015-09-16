//
//  v_Analyzer.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface AVETypeAnalyzer : NSObject

-(NSMutableArray*) getAVESFromPinchViews:(NSArray*) pinchViews withFrame:(CGRect)frame;

-(NSMutableArray*) getAVESFromPages: (NSArray*) pages withFrame: (CGRect) frame;
@end
