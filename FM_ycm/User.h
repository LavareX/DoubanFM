//
//  User.h
//  FM_ycm
//
//  Created by yangcaimu on 14-2-9.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;

@end
