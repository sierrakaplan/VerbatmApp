//
//  GMImagePickerController.m
//  GMPhotoPicker
//
//  Created by Guillermo Muntaner Perelló on 19/09/14.
//  Copyright (c) 2014 Guillermo Muntaner Perelló. All rights reserved.
//

#import "GMImagePickerController.h"
#import "GMAlbumsViewController.h"
#import "SizesAndPositions.h"


@import Photos;

@interface GMImagePickerController () <UINavigationControllerDelegate>

@property (nonatomic) BOOL selectOneImage;

@end

@implementation GMImagePickerController

- (id)init {
    if (self = [super init]){
        _selectedAssets = [[NSMutableArray alloc] init];
		_selectOneImage = NO;
        
        //Default values:
        _displaySelectionInfoToolbar = YES;
        _displayAlbumsNumberOfAssets = YES;
        
        //Grid configuration:
        _colsInPortrait = GALLERY_COLUMNS_PORTRAIT;
        _colsInLandscape = GALLERY_COLUMNS_LANDSCAPE;
        _minimumInteritemSpacing = 2.0;
        
        //Sample of how to select the collections you want to display:
        _customSmartCollections = @[@(PHAssetCollectionSubtypeSmartAlbumFavorites),
                                    @(PHAssetCollectionSubtypeSmartAlbumRecentlyAdded),
                                    @(PHAssetCollectionSubtypeSmartAlbumVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumSlomoVideos),
                                    @(PHAssetCollectionSubtypeSmartAlbumTimelapses),
                                    @(PHAssetCollectionSubtypeSmartAlbumBursts),
                                    @(PHAssetCollectionSubtypeSmartAlbumPanoramas)];
        //If you don't want to show smart collections, just put _customSmartCollections to nil;
        //_customSmartCollections=nil;
        
        self.preferredContentSize = kPopoverContentSize;
        
        [self setupNavigationController];
    }
    return self;
}

- (void)dealloc{
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Navigation Controller

- (void)setupNavigationController {
    _albumsViewController = [[GMAlbumsViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:_albumsViewController];
    _navigationController.delegate = self;
    
    [_navigationController willMoveToParentViewController:self];
    [_navigationController.view setFrame:self.view.frame];
    [self.view addSubview:_navigationController.view];
    [self addChildViewController:_navigationController];
    [_navigationController didMoveToParentViewController:self];
}


#pragma mark - Set select one image -

-(void) setSelectOnlyOneImage:(BOOL)selectOneImage {
	self.selectOneImage = selectOneImage;
	self.albumsViewController.onlyOneImage = self.selectOneImage;
}

#pragma mark - Select / Deselect Asset

- (BOOL)selectAsset:(PHAsset *)asset {
    
    if(![self reachedMaxSelectionAmount]){
        [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count];
        if (self.selectOneImage) {
            [self finishPickingAssets:self];
            return true;
        }
        [self updateDoneButton];
        
        if(self.displaySelectionInfoToolbar) {
            [self updateToolbar];
        }
        return true;
    }
    return false;
}

-(BOOL)reachedMaxSelectionAmount{
    
//    if(self.selectedAssets.count == 10){
//        //alert the user this is max
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Only allowed to pick 10 elements per selection round" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//        return true;
//    }
//    
    //temp
    return false;
}

- (void)deselectAsset:(PHAsset *)asset {
    
    
    [self.selectedAssets removeObjectAtIndex:[self.selectedAssets indexOfObject:asset]];
    if(self.selectedAssets.count == 0) {
        [self updateDoneButton];
	}

    if(self.displaySelectionInfoToolbar) {
        [self updateToolbar];
	}
}

- (void)updateDoneButton
{
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers)
        viewController.navigationItem.rightBarButtonItem.enabled = (self.selectedAssets.count > 0);
}

- (void)updateToolbar
{
    UINavigationController *nav = (UINavigationController *)self.childViewControllers[0];
    for (UIViewController *viewController in nav.viewControllers)
    {
        [[viewController.toolbarItems objectAtIndex:1] setTitle:[self toolbarTitle]];
        [viewController.navigationController setToolbarHidden:(self.selectedAssets.count == 0) animated:YES];
    }
}

#pragma mark - User finish Actions

- (void)dismiss:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerControllerDidCancel:)])
        [self.delegate assetsPickerControllerDidCancel:self];

//	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)finishPickingAssets:(id)sender {
    if ([self.delegate respondsToSelector:@selector(assetsPickerController:didFinishPickingAssets:)])
        [self.delegate assetsPickerController:self didFinishPickingAssets:self.selectedAssets];
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Toolbar Title

- (NSPredicate *)predicateOfAssetType:(PHAssetMediaType)type
{
    return [NSPredicate predicateWithBlock:^BOOL(PHAsset *asset, NSDictionary *bindings) {
        return (asset.mediaType==type);
    }];
}

- (NSString *)toolbarTitle
{
    if (self.selectedAssets.count == 0)
        return nil;
    
    NSPredicate *photoPredicate = [self predicateOfAssetType:PHAssetMediaTypeImage];
    NSPredicate *videoPredicate = [self predicateOfAssetType:PHAssetMediaTypeVideo];
    
    NSInteger nImages = [self.selectedAssets filteredArrayUsingPredicate:photoPredicate].count;
    NSInteger nVideos = [self.selectedAssets filteredArrayUsingPredicate:videoPredicate].count;
    
    if (nImages>0 && nVideos>0)
    {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"picker.selection.multiple-items", @"GMImagePicker", @"%@ Items Selected" ), @(nImages+nVideos)];
    }
    else if (nImages>1)
    {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"picker.selection.multiple-photos", @"GMImagePicker", @"%@ Photos Selected"), @(nImages)];
    }
    else if (nImages==1)
    {
        return NSLocalizedStringFromTable(@"picker.selection.single-photo", @"GMImagePicker", @"1 Photo Selected" );
    }
    else if (nVideos>1)
    {
        return [NSString stringWithFormat:NSLocalizedStringFromTable(@"picker.selection.multiple-videos", @"GMImagePicker", @"%@ Videos Selected"), @(nVideos)];
    }
    else if (nVideos==1)
    {
        return NSLocalizedStringFromTable(@"picker.selection.single-video", @"GMImagePicker", @"1 Video Selected");
    }
    else
    {
        return nil;
    }
}


#pragma mark - Toolbar Items

- (UIBarButtonItem *)titleButtonItem
{
    UIBarButtonItem *title =
    [[UIBarButtonItem alloc] initWithTitle:self.toolbarTitle
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    
    [title setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [title setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    [title setEnabled:NO];
    
    return title;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

- (NSArray *)toolbarItems
{
    UIBarButtonItem *title = [self titleButtonItem];
    UIBarButtonItem *space = [self spaceButtonItem];
    
    return @[space, title, space];
}



@end
