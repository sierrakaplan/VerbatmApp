//
//  AdjustableBlurEffect.m
//  Verbatm
//
//  Created by Sierra Kaplan-Nelson on 9/4/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

#import "AdjustableBlurEffect.h"

#import <objc/runtime.h>

@interface UIBlurEffect (Protected)
@property (nonatomic, readonly) id effectSettings;
@end

@implementation AdjustableBlurEffect

+ (instancetype)effectWithStyle:(UIBlurEffectStyle)style
{
	id result = [super effectWithStyle:style];
	object_setClass(result, self);

	return result;
}

- (id)effectSettings
{
	id settings = [super effectSettings];
	[settings setValue:@15 forKey:@"blurRadius"];
	return settings;
}

- (id)copyWithZone:(NSZone*)zone
{
	id result = [super copyWithZone:zone];
	object_setClass(result, [self class]);
	return result;
}

@end
