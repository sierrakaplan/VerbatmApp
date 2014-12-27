//
//  v_Analyzer.h
//  Verbatm
//
//  Created by Lucio Dery Jnr Mwinmaarong on 12/23/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface v_Analyzer : NSObject
@property(strong, nonatomic) NSMutableArray* pinchedObjects;
@property(nonatomic) CGRect preferedFrame;
-(NSMutableArray*)processPinchedObjects;
@end
