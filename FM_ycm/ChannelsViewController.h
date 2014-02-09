//
//  ChannelsViewController.h
//  FM_ycm
//
//  Created by yangcaimu on 14-2-4.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel.h"
@class ChannelsViewController;

@protocol ChannelsViewControllerDelegate <NSObject>

-(void)ChannelsViewControllerDidSelect:(ChannelsViewController *)controller didChannel:(Channel *)selectChannel;

@end

@interface ChannelsViewController : UITableViewController

@property (nonatomic,strong) id <ChannelsViewControllerDelegate> delegate;
@property (nonatomic,strong) NSMutableArray *channels;
@property (nonatomic,strong) Channel *channel;

@end
