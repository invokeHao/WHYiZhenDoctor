//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUAVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "RecordAudio.h"

@interface UUAVAudioPlayer ()<AVAudioPlayerDelegate>

@end

@implementation UUAVAudioPlayer

+ (UUAVAudioPlayer *)sharedInstance
{
    static UUAVAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });    
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl{
    
    dispatch_async(dispatch_queue_create("playSoundFromUrl", NULL), ^{
        [self.delegate UUAVAudioPlayerBeiginLoadVoice];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:songUrl]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self playSoundWithData:data];
        });
    });
}

-(void)playSongWithData:(NSData *)songData{
    [self setupPlaySound];
    [self playSoundWithData:songData];
}

-(void)playSoundWithData:(NSData *)soundData{
    if (_player) {
        [_player stop];
        _player.delegate = nil;
        _player = nil;
    }
    NSError *playerError;
    RecordAudio*record=[[RecordAudio alloc]init];
    
    NSData* o = [record decodeAmr:soundData];
    
    _player = [[AVAudioPlayer alloc]initWithData:o error:&playerError];
    [_player prepareToPlay];
    _player.volume = 1.0f;
    if (_player == nil){
        NSLog(@"ERror creating player: %@", [playerError description]);
    }
    _player.delegate = self;
    [_player play];
    [self.delegate UUAVAudioPlayerBeiginPlay];
}

-(void)setupPlaySound{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.delegate UUAVAudioPlayerDidFinishPlay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;{
    //解码错误执行的动作
    NSLog(@"解析错误");
}

- (void)stopSound
{
    if (_player && _player.isPlaying) {
        [_player stop];
        [self.delegate UUAVAudioPlayerStopPlay];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [self.delegate UUAVAudioPlayerDidFinishPlay];
}

@end