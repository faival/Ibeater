//
//  WeMixBrain.m
//  wemix
//
//  Created by Pablo Molina Pelaez on 16/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import "WeMixBrain.h"
#import <AVFoundation/AVFoundation.h>
#import "SCUI.h"

@interface WeMixBrain ()
@property (nonatomic, strong) NSMutableArray *songsStack;

@end


@implementation WeMixBrain


@synthesize songsStack = _songsStack;
@synthesize player = _player;



-(NSMutableArray *)songsStack
{
    if (_songsStack == nil) _songsStack = [[NSMutableArray alloc] init];
    return _songsStack;
}



- (void) pushSong:(NSString *)songUrl
{
    [self.songsStack addObject:songUrl];
}

- (NSString *) popSong
{
    NSString *operandObj = [self.songsStack lastObject];
    if (operandObj) [self.songsStack removeLastObject];
    return operandObj;
}

- (void) playSong:(NSString *)song
{

    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
                              message:@"You must login first"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *streamURL = [[@"http://api.soundcloud.com/tracks/" stringByAppendingString:song] stringByAppendingString:@"/stream"];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:streamURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 NSError *playerError;
                 self.player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                 [self.player prepareToPlay];
                 [self.player play];
             }];
    

}

- (void) pauseSong:(NSString *)song
{
    if(self.player)[self.player pause];
}


- (void) performCommand:(NSString *)command
{
    NSArray *commandParams = [command componentsSeparatedByString:@"_"];
    NSString *action = [commandParams firstObject];
    NSString *songUrl = [commandParams lastObject];
 
    if([@"play" isEqual: action]) {
        [self playSong: songUrl];
    }
    else if ([@"pause" isEqual: action]) {
        [self pauseSong: songUrl];
    }
    NSLog(@"performCommand: %@", command);
}

@end
