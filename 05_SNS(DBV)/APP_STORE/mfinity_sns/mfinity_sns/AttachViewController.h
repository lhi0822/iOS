//
//  AttachViewController.h
//  mfinity_sns
//
//  Created by hilee on 2020/06/26.
//  Copyright © 2020 com.dbvalley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "PHLibListViewController.h"

@interface AttachViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

//@property (weak, nonatomic) PHPhotoLibrary *photoLibrary;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIDocumentPickerViewController *docPicker;

@end
