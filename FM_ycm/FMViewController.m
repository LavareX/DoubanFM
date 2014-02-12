//
//  FMViewController.m
//  FM_ycm
//
//  Created by yangcaimu on 14-1-24.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import "FMViewController.h"
#import "AFNetworking.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "Track.h"
#import "LoginViewController.h"
#import "Channel.h"
#import "ChannelsViewController.h"
#import "User.h"

@interface FMViewController ()

@end

@implementation FMViewController{
    NSMutableArray *tracks;
    DOUAudioStreamer *streamer;
    NSInteger currentIndex;
    Track *track;
    NSMutableArray *channels;
    Channel *channel;
    NSMutableDictionary *songParameters;
    NSMutableDictionary *loginParameters;
    NSDictionary *loginMess;
    BOOL isLogin;
}

@synthesize managedObjectContext =__managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAllValue];
}


-(void)initAllValue{
    //初始化所有值
    currentIndex=0;
    [self.progress setValue:0.0f];
    [self.sliderVolume setValue:[DOUAudioStreamer volume]];
    
    //设置音乐进度条
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setSliderValue) userInfo:nil repeats:YES];
    
    //Get、Post参数
    songParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"n",@"type",@"4",@"channel",nil];
    loginParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name",
        @"100",@"version", nil];
    
    //获取歌曲列表、频道列表
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getTracks];
        [self getChannels];
    });
    
    //歌曲图片以圆形呈现
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 125;
    
    //歌曲图片增加单击事件
    UITapGestureRecognizer *singTapShow=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImageShow)];
    [self.imageView addGestureRecognizer:singTapShow];
    UITapGestureRecognizer *singTapHidden=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImageHidden)];
    [self.audioVisualizerView addGestureRecognizer:singTapHidden];
    
    //取得上次登陆成功与否
    isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    if (isLogin) {
        NSArray *fetchedObjects = [self userDataFetchRequest];
        for (User *user in fetchedObjects) {
            [loginParameters setObject:user.email forKey:@"email"];
            [loginParameters setObject:user.password forKey:@"password"];
        }
        [self getLogin:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma  mark - songImage singTap

-(void)onClickImageShow{
    [self.audioVisualizerView setHidden:NO];
}

-(void)onClickImageHidden{
    [self.audioVisualizerView setHidden:YES];
}

#pragma mark - Tracks methods

-(void)getTracks{
    NSString *url=@"http://douban.fm/j/app/radio/people";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSLog(@"current channel--->%@",[songParameters objectForKey:@"channel"]);
    [manager GET:url parameters:songParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseSongs=[responseObject objectForKey:@"song"];
        if (tracks != nil) {
            [tracks removeAllObjects];
        }
        tracks=[NSMutableArray array];
        for (NSDictionary *song in responseSongs) {
            //依次赋值给track
            track=[[Track alloc] init];
            track.artist=[song objectForKey:@"artist"];
            track.title=[song objectForKey:@"title"];
            track.sid=[song objectForKey:@"sid"];
            track.url=[NSURL URLWithString:[song objectForKey:@"url"]];
            track.picture=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[song objectForKey:@"picture"]]]];
            [tracks addObject:track];
        }
        int a=0;
        for (Track *temp in tracks) {
            a++;
             NSLog(@"temp[%d]%@",a,temp.title);
        }
        //读取获得的Tracks
        [self loadTracks];
         NSLog(@"get Tracks success");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[getTracks]Network connect failure:error--->%@",error);
    }];
}

-(void)loadTracks{
    [self removeObserverForStreamer];
    track=[tracks objectAtIndex:currentIndex];
    streamer=[DOUAudioStreamer streamerWithAudioFile:track];
    [streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self setSliderValue];
    NSString *title=[NSString stringWithFormat:@"%@--%@",track.title,track.artist];
    [self.songTitle setText:title];
    [self.imageView setImage:[track picture]];
    [streamer play];
}

-(void)removeObserverForStreamer{
    if (streamer != nil) {
        [streamer removeObserver:self forKeyPath:@"status"];
        streamer=nil;
    }
}

-(BOOL)reGetTracks{
    if (currentIndex == [tracks count]-1 ) {
        currentIndex=0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self getTracks];
        });
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Channels method
-(void)getChannels{
    NSString *url=@"http://douban.fm/j/app/radio/channels";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    if (channels != nil) {
        channels = nil;
    }
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseChannels=[responseObject objectForKey:@"channels"];
        channels=[NSMutableArray array];
        for (NSDictionary *dicChannels in responseChannels) {
            //依次赋值给channel
            channel=[[Channel alloc] init];
            channel.name=[dicChannels objectForKey:@"name"];
            channel.channel_id=[dicChannels objectForKey:@"channel_id"];
            [channels addObject:channel];
        }
        NSLog(@"get Channels success");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"[getChannels]Network connect failure:error--->%@",error);
    }];
}

#pragma mark - ChannelsViewControllerDelegate method
-(void)ChannelsViewControllerDidSelect:(ChannelsViewController *)controller didChannel:(Channel *)selectChannel{
    NSLog(@"channel_id--->name:%@--->%@",selectChannel.channel_id,selectChannel.name);
    [songParameters setValue:selectChannel.channel_id forKey:@"channel"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getTracks];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Login method
-(void)getLogin:(LoginViewController *)controller{
    
    NSString *url=@"http://www.douban.com/j/app/login";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager POST:url parameters:loginParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        loginMess=(NSDictionary *)responseObject;
        
        if ( [[[loginMess objectForKey:@"r"] stringValue] isEqualToString:@"0"] ) {
            //登陆成功
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogin"];
            [songParameters setObject:[loginMess objectForKey:@"user_id"] forKey:@"user_id"];
            [songParameters setObject:[loginMess objectForKey:@"expire"] forKey:@"expire"];
            [songParameters setObject:[loginMess objectForKey:@"token"] forKey:@"token"];
            [self.navigationItem setTitle:[loginMess objectForKey:@"user_name"]];
            [self deleteCoreData];
            [self insertCoreData];
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"login success");
            
        }else if ( [[[loginMess objectForKey:@"r"] stringValue] isEqualToString:@"1"] ){
            //登陆失败
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
            [self deleteCoreData];
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Login failure" message:[NSString stringWithFormat:@"%@",[loginMess objectForKey:@"err"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [controller.nameText setText:@""];
            [controller.passwordText setText:@""];
            NSLog(@"login failure");
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //网络连接失败
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
        NSLog(@"[getLogin]Network connect failure:error--->%@",error);
    }];
}

#pragma mark - LoginViewControllerDelegate method

-(void)loginViewControllerDidCancel:(LoginViewController *)controller{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loginViewControllerDidSave:(LoginViewController *)controller{
    if (controller.nameText.text.length != 0 && controller.passwordText.text.length != 0) {
        [loginParameters setObject:controller.nameText.text forKey:@"email"];
        [loginParameters setObject:controller.passwordText.text forKey:@"password"];
        [self getLogin:controller];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Login failure" message:@"Please enter the email address and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - CoreData store
//- (void)saveContext{
//    NSLog(@"method[saveContext] is called");
//    NSError *error=nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            NSLog(@"Unresolved error %@, %@",error,[error userInfo]);
//            abort();
//        }
//    }
//}

- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)managedObjectContext{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *) managedObjectModel{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modeURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel=[[NSManagedObjectModel alloc] initWithContentsOfURL:modeURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return __persistentStoreCoordinator;
}

- (void)insertCoreData{
    NSManagedObjectContext *context = [self managedObjectContext];
    User *user=[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    if ( [[loginParameters objectForKey:@"email"] length] != 0 && [[loginParameters objectForKey:@"password"] length] != 0) {
        user.email=[loginParameters objectForKey:@"email"];
        user.password=[loginParameters objectForKey:@"password"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"不能保存：%@",[error localizedDescription]);
        }
    }
}

- (void)deleteCoreData{
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSArray *fetchedObjects = [self userDataFetchRequest];
    if ( fetchedObjects != nil) {
        for (User *user in fetchedObjects) {
            for (NSManagedObject *obj in fetchedObjects) {
                [context deleteObject:obj];
            }
            if (![context save:&error]) {
                NSLog(@"error:%@",error);
            }
        }
    }
}

- (NSArray *)userDataFetchRequest{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ( fetchedObjects != nil ) {
        NSLog(@"[fetchedObjects count]--->%d",[fetchedObjects count]);
        for (User *user in fetchedObjects) {
            [loginParameters setObject:user.email forKey:@"email"];
            [loginParameters setObject:user.password forKey:@"password"];
        }
    }
    return fetchedObjects;
}

#pragma mark - KVO delegate method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"] ) {
        if ([streamer status] == DOUAudioStreamerFinished){
            [self performSelector:@selector(nextAction:)
                         onThread:[NSThread mainThread]
                       withObject:nil
                    waitUntilDone:NO];
        }
    }
}

-(void)setSliderValue{
    if (streamer.duration == 0.0) {
        [self.progress setValue:0.0f animated:NO];
    }else{
        [self.progress setValue:[streamer currentTime] / [streamer duration] animated:YES];
    }
}

#pragma mark - segue method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"login"]) {
        LoginViewController *loginvc=(LoginViewController *)segue.destinationViewController;
        loginvc.delegate=self;
    }
    if ([segue.identifier isEqualToString:@"channels"]) {
        ChannelsViewController *chvc=(ChannelsViewController *)segue.destinationViewController;
        chvc.channels=channels;
        chvc.delegate=self;
    }
}

#pragma mark - action method
/*
 DOUAudioStreamerPlaying,
 DOUAudioStreamerPaused,
 DOUAudioStreamerIdle,
 DOUAudioStreamerFinished,
 DOUAudioStreamerBuffering,
 DOUAudioStreamerError
 */
- (IBAction)playingAction:(id)sender {
    if ([streamer status] == DOUAudioStreamerPaused || [streamer status] == DOUAudioStreamerIdle) {
        [streamer play];
        [self.playing setTitle:@"Pause" forState:UIControlStateNormal];
    }else{
        [streamer pause];
        [self.playing setTitle:@"play" forState:UIControlStateNormal];
    }
}

- (IBAction)nextAction:(id)sender {
    [self.unLove setTitle:@"unLove" forState:UIControlStateNormal];
    if ([self reGetTracks]) {
        currentIndex++;
        [self loadTracks];
    }
}

- (IBAction)downloadAction:(id)sender {

}

- (IBAction)loveAction:(id)sender {
    NSString *loveURL=@"http://douban.fm/j/app/radio/people";
    NSMutableDictionary *loveParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"n",@"type",@"4",@"channel",nil];
    [loveParameters setObject:@"r" forKey:@"type"];
    [loveParameters setObject:track.sid forKey:@"sid"];
    if (loginMess != nil) {
        [loveParameters setObject:[loginMess objectForKey:@"user_id"] forKey:@"user_id"];
        [loveParameters setObject:[loginMess objectForKey:@"expire"] forKey:@"expire"];
        [loveParameters setObject:[loginMess objectForKey:@"token"] forKey:@"token"];
    }
    AFHTTPSessionManager *loveManager=[AFHTTPSessionManager manager];
    [loveManager GET:loveURL parameters:loveParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.unLove setTitle:@"Love" forState:UIControlStateNormal];
        NSLog(@"Love is success");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error%@",error);
    }];
    
}

- (IBAction)progressAction:(id)sender {
    [self.progress setValue:self.progress.value animated:YES];
    [streamer setCurrentTime:[streamer duration] * [self.progress value]];
}

- (IBAction)VolumeAction:(id)sender {
    [DOUAudioStreamer setVolume:self.sliderVolume.value];
}
@end
