//
//  verbatmCustomImageView.m
//  Verbatm
//
//  Created by Iain Usiri on 11/25/14.
//  Copyright (c) 2014 Verbatm. All rights reserved.
//

#import "VerbatmImageView.h"

@interface VerbatmImageView()
@property (strong, nonatomic) ALAssetsLibrary* assetLibrary;
#define IS_VIDEO @"isVideo"
#define ASSET_DATA @"assetData"
@end

@implementation VerbatmImageView


//These two funcitons offer a "freeze dry" feature to store the custom image view in order to push to the cloud
//this is how you save any custom object
//note that we are not using this right now we are instead saving media elements individually and reconstructing when needed
//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if(self){
//        self.isVideo = (BOOL)[aDecoder decodeObjectForKey:IS_VIDEO];
//        NSData* data = (NSData*)[aDecoder decodeObjectForKey:ASSET_DATA];
//        if(self.isVideo){
//            [self saveVideoToVerbatmAlbum:data];
//        }else{
//            [self saveImageToVerbatmAlbum:data];
//        }
//    }
//    return self;
//}
//
//-(void)encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeBool:self.isVideo forKey:IS_VIDEO];
//    [aCoder encodeObject:[self dataFromAsset] forKey:ASSET_DATA];
//}


-(NSData*)dataFromAsset
{
    NSData* data = nil;
    if(self.asset){
        ALAssetRepresentation *assetRepresentation = [self.asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(assetRepresentation.size);
        //do a bit of error checking on this later
        NSUInteger buffered = [assetRepresentation getBytes:buffer fromOffset:0.0 length:assetRepresentation.size error:nil];
        data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    }
    return data;
}
-(void)saveVideoToVerbatmAlbum:(NSData*)data
{
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"download.mov"]];
    [data writeToFile:databasePath atomically:YES];
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    [self.assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:databasePath]
                                          completionBlock:^(NSURL *assetURL, NSError *error) {
                                              [self.assetLibrary assetForURL:assetURL
                                                                 resultBlock:^(ALAsset *asset) {
                                                                     // assign the photo to the album
                                                                     self.asset = asset;
                                                                 }
                                                                failureBlock:^(NSError* error) {
                                                                    NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                                }];
                                          }];
}


-(void)saveImageToVerbatmAlbum:(NSData*)data
{
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    [self.assetLibrary writeImageDataToSavedPhotosAlbum:data
                                               metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                                                   if (error.code == 0) {
                                                       NSLog(@"saved image completed:\nurl: %@", assetURL);
                                                       // try to get the asset
                                                       [self.assetLibrary assetForURL:assetURL
                                                                          resultBlock:^(ALAsset *asset) {
                                                                              // assign the photo to the album
                                                                              self.asset = asset;
                                                                          }
                                                                         failureBlock:^(NSError* error) {
                                                                             NSLog(@"failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                                         }];
                                                   }
                                                   else {
                                                       NSLog(@"saved image failed.\nerror code %li\n%@", (long)error.code, [error localizedDescription]);
                                                   }
                                               }];
}
@end
