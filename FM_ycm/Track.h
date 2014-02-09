//
//  Track.h
//  FM_ycm
//
//  Created by yangcaimu on 14-1-28.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioStreamer.h"

@interface Track : NSObject<DOUAudioFile>

@property (nonatomic,strong) NSString *artist;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) UIImage *picture;

@end
