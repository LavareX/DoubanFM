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

@interface FMViewController (){
    NSMutableArray *tracks;
    DOUAudioStreamer *streamer;
    NSInteger currentIndex;
    Track *track;
    NSMutableArray *channels;
    Channel *channel;
    NSMutableDictionary *songParameters;
    NSMutableDictionary *loginParameters;
    NSDictionary *loginMess;
}

@end

@implementation FMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initAllValue];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)initAllValue{
    currentIndex=0;
    [self.progress setValue:0.0f];
    [self.sliderVolume setValue:[DOUAudioStreamer volume]];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setSliderValue) userInfo:nil repeats:YES];
    songParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"n",@"type",@"4",@"channel",nil];
    loginParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version", nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getTracks];
        [self getChannels];
    });
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 125;
    UITapGestureRecognizer *singTapShow=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImageShow)];
    [self.imageView addGestureRecognizer:singTapShow];
    UITapGestureRecognizer *singTapHidden=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImageHidden)];
    [self.audioVisualizerView addGestureRecognizer:singTapHidden];
}

-(void)onClickImageShow{
    [self.audioVisualizerView setHidden:NO];
}

-(void)onClickImageHidden{
    [self.audioVisualizerView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tracks method

-(void)getTracks{
    NSString *url=@"http://douban.fm/j/app/radio/people";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSLog(@"channel-----%@",[songParameters objectForKey:@"channel"]);
    [manager GET:url parameters:songParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseSongs=[responseObject objectForKey:@"song"];
        if (tracks != nil) {
            [tracks removeAllObjects];
        }
        tracks=[NSMutableArray array];
        for (NSDictionary *song in responseSongs) {
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
        [self loadTracks];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error%@",error);
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
            channel=[[Channel alloc] init];
            channel.name=[dicChannels objectForKey:@"name"];
            channel.channel_id=[dicChannels objectForKey:@"channel_id"];
            [channels addObject:channel];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@",error);
    }];
}

#pragma mark - ChannelsViewControllerDelegate method
-(void)ChannelsViewControllerDidSelect:(ChannelsViewController *)controller didChannel:(Channel *)selectChannel{
    NSLog(@"channel_id:%@-----name:%@",selectChannel.channel_id,selectChannel.name);
    [songParameters setValue:selectChannel.channel_id forKey:@"channel"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getTracks];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - login method
-(void)getLogin{
    NSString *url=@"http://www.douban.com/j/app/login";
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager POST:url parameters:loginParameters success:^(NSURLSessionDataTask *task, id responseObject) {
        loginMess=(NSDictionary *)responseObject;
        NSLog(@"%@",loginMess);
        if ([loginMess objectForKey:@"r"] == 0) {
            [songParameters setObject:[loginMess objectForKey:@"user_id"] forKey:@"user_id"];
            [songParameters setObject:[loginMess objectForKey:@"expire"] forKey:@"expire"];
            [songParameters setObject:[loginMess objectForKey:@"token"] forKey:@"token"];
            NSLog(@"user_id%@",[loginMess objectForKey:@"user_id"]);
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Login failure" message:[NSString stringWithFormat:@"%@",[loginMess objectForKey:@"err"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error%@",error);
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
        [self getLogin];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Login failure" message:@"Please enter the email address and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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
