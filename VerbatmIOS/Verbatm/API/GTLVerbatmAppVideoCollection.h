/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLVerbatmAppVideoCollection.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLVerbatmAppVideoCollection (0 custom class methods, 1 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLVerbatmAppVideo;

// ----------------------------------------------------------------------------
//
//   GTLVerbatmAppVideoCollection
//

// This class supports NSFastEnumeration over its "items" property. It also
// supports -itemAtIndex: to retrieve individual objects from "items".

@interface GTLVerbatmAppVideoCollection : GTLCollectionObject
@property (nonatomic, retain) NSArray *items;  // of GTLVerbatmAppVideo
@end
