//
//  postHolderCollecitonRV.m
//  Verbatm
//
//  Created by Iain Usiri on 1/18/16.
//  Copyright © 2016 Verbatm. All rights reserved.
//

#import "POVView.h"
#import "postHolderCollecitonRV.h"

@interface postHolderCollecitonRV ()

@property (nonatomic) POVView * ourCurrentPOV;
@end

@implementation postHolderCollecitonRV





#pragma mark -lazy instantiation-
-(POVView *) ourCurrentPOV{
    if(!_ourCurrentPOV) _ourCurrentPOV = [[POVView alloc] initWithFrame:self.bounds andPOVInfo:nil];
    return _ourCurrentPOV;
}

@end
