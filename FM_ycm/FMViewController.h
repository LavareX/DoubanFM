//
//  FMViewController.h
//  FM_ycm
//
//  Created by yangcaimu on 14-1-24.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "ChannelsViewController.h"

@interface FMViewController : UIViewController<LoginViewControllerDelegate,ChannelsViewControllerDelegate>

//控件
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIView *audioVisualizerView;
@property (strong, nonatomic) IBOutlet UILabel *songTitle;
@property (strong, nonatomic) IBOutlet UISlider *progress;
@property (strong, nonatomic) IBOutlet UIButton *playing;
@property (strong, nonatomic) IBOutlet UIButton *unLove;
@property (strong, nonatomic) IBOutlet UISlider *sliderVolume;

//Core Data store
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (IBAction)playingAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)downloadAction:(id)sender;
- (IBAction)loveAction:(id)sender;
- (IBAction)progressAction:(id)sender;
- (IBAction)VolumeAction:(id)sender;
//- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
