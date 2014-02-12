//
//  CONSTANTS.h
//  FM_ycm
//
//  Created by yangcaimu on 14-2-4.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#ifndef FM_ycm_CONSTANTS_h
#define FM_ycm_CONSTANTS_h



#endif

//user login info
#define kUserid              @"user_id"
#define kToken               @"token"
#define kExpire              @"expire"
#define kUserName            @"user_name"


#define kErrorCode           @"r"
#define kChannelId           @"channel_id"
#define kChannelName         @"channel_name"


//load songs type , n-> return a new song list
//                  s-> next song
//                  b-> do not play this song again
//                  r-> rate this song
//                  u-> unrate this song

#define kLoadSongsTypeNew    @"n"
#define kLoadSongsTypeSkip   @"s"
#define kLoadSongsTypeBye    @"b"
#define kLoadSongsTypeRate   @"r"
#define kLoadSongsTypeUnrate @"u"
