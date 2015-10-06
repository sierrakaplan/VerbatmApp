//
//  UseFulFunctions.m
//  Verbatm
//
//  Created by Iain Usiri on 9/27/15.
//  Copyright © 2015 Verbatm. All rights reserved.
//

#import "UtilityFunctions.h"


@implementation UtilityFunctions


+(NSData *) convertALAssetRepresentationToData: (ALAssetRepresentation *) assetRep {
    Byte *buffer = (Byte*)malloc((NSUInteger)assetRep.size);
    NSUInteger buffered = [assetRep getBytes:buffer fromOffset:0.0 length:(NSUInteger)assetRep.size error:nil];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return data;
}

@end
