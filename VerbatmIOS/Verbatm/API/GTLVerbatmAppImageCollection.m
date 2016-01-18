/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLVerbatmAppImageCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLVerbatmAppImageCollection (0 custom class methods, 1 custom properties)

#import "GTLVerbatmAppImageCollection.h"

#import "GTLVerbatmAppImage.h"

// ----------------------------------------------------------------------------
//
//   GTLVerbatmAppImageCollection
//

@implementation GTLVerbatmAppImageCollection
@dynamic items;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = @{
    @"items" : [GTLVerbatmAppImage class]
  };
  return map;
}

@end
