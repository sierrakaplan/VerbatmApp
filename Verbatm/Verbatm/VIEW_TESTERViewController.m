//
//  VIEW_TESTERViewController.m
//  Verbatm
//
//  Created by Iain Usiri on 3/23/15.
//  Copyright (c) 2015 Verbatm. All rights reserved.
//

/* UNUSED! Buggy

#import "VIEW_TESTERViewController.h"
#import "PhotoVideoAVE.h"
#import "VerbatmImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define ALBUM_NAME @"Verbatm"

@interface VIEW_TESTERViewController ()
@property (strong, nonatomic) PhotoVideoAVE* pv_ave;
@property (strong, nonatomic) VerbatmImageView * imageV;
@property (strong, nonatomic) VerbatmImageView * videoV;
@property (strong, nonatomic) NSMutableArray * media;
@property (strong, nonatomic) ALAssetsGroup * folder;
@end



@implementation VIEW_TESTERViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)getVerbatmMediaFolder
{
    //get the album
    __weak VIEW_TESTERViewController* weakSelf = self;
    ALAssetsLibrary *  assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                      usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                          if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString: ALBUM_NAME]) {
                                              NSLog(@"found album %@", ALBUM_NAME);
                                              weakSelf.folder = group;
                                              [self fillArrayWithMedia];
                                              return;
                                          }
                                      }
                                    failureBlock:^(NSError* error) {
                                        NSLog(@"failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                    }];
}

-(void) fillArrayWithMedia
{
    __weak VIEW_TESTERViewController* weakSelf = self;
    [self.folder enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
        if(result)
        {
            if(![weakSelf.media containsObject:result])
            {
                [weakSelf.media addObject:result];
            }
        }else if (!result)
        {
            [self dotherest];
        }
    }];
}

-(void) dotherest
{
    for (int i=0; i < self.media.count; i++)
    {
        
        if([[self.media[i] valueForProperty: ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
        {
            self.videoV = [[VerbatmImageView alloc] init];
            self.videoV.isVideo = YES;
            self.videoV.asset = self.media[i];
        }else{
            self.imageV = [[VerbatmImageView alloc] init];
            self.imageV.asset = self.media[i];
            self.imageV.isVideo = NO;
        }
        
        if(self.imageV && self.videoV) break;
    }
    
    self.pv_ave = [[PhotoVideoAVE alloc]initWithFrame:self.view.frame Image:self.imageV andVideo:self.videoV];
    [self.view addSubview:self.pv_ave];
}



-(NSMutableArray *) media
{
    if(!_media) _media = [[NSMutableArray alloc] init];
    return _media;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end

*/
