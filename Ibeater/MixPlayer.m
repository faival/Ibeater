//
//  MixPlayer.m
//  Ibeater
//
//  Created by Pablo Molina Pelaez on 04/03/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import "MixPlayer.h"
#import "IBeaterAppDelegate.h"
#import "SCUI.h"


@interface MixPlayer()

@property (nonatomic, strong) NSMutableArray *songBeats;
@property (nonatomic, strong) NSMutableArray *beatClasses;

@property (nonatomic) int currentBeat;
@property (nonatomic, strong) NSString *songUrl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *peakTimer;
@property (nonatomic, strong) NSTimer *poakTimer;
@property (nonatomic, strong) NSTimer *beatTimer;

@property (nonatomic) double lastTime;

@property (nonatomic) float playerVolume;

@end

@implementation MixPlayer

@synthesize controller = _controller;
@synthesize songBeats = _songBeats;
@synthesize beatClasses = _beatClasses;
@synthesize songUrl = _songUrl;
@synthesize currentBeat = _currentBeat;
@synthesize timer = _timer;
@synthesize peakTimer = _peakTimer;
@synthesize poakTimer = _poakTimer;
@synthesize playerVolume = _playerVolume;

-(IBeaterViewController *)controller
{
    if(!_controller) _controller = [[IBeaterViewController alloc] init];
    return _controller;
}

-(NSMutableArray *)songBeats
{
    if (_songBeats == nil) _songBeats = [[NSMutableArray alloc] init];
    return _songBeats;
}

-(NSMutableArray *)beatClasses
{
    if (_beatClasses == nil) _beatClasses = [[NSMutableArray alloc] init];
    return _beatClasses;
}


- (void) setSongURL:(NSString *)songUrl
{
    self.songUrl = songUrl;
    self.playerVolume = 0.0;
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:self.songUrl]
             usingParameters:nil
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 
                 NSError *playerError;
                 self.player = [[AVAudioPlayer alloc] initWithData:data error: &playerError];
                 NSLog(@"Player created for: %@", self.songUrl);
                 [self.player prepareToPlay];
                 [self.player play];
                 [self.player pause];
                 [self.player setVolume:self.playerVolume];
             }];
}
- (void) setSongBeatStamps:(NSMutableArray *) songBeats
{
    self.songBeats = songBeats;
}

- (void) setSongBeatClasses:(NSMutableArray *) beatClasses
{
    self.beatClasses = beatClasses;
}

- (void) setBeatIndex:(int) currentBeat
{
    if (currentBeat < [self.songBeats count])
        self.currentBeat = currentBeat;
}

- (int) getBeatIndex: (double) beatTime
{
    /*
    
    for(NSNumber *currentBeat in self.songBeats) {
        if([currentBeat doubleValue] > [[NSNumber numberWithDouble:beatTime] doubleValue]) {
            break;
        }
        beatIndex++;
    }
    beatIndex--;
    */
    
    int beatIndex = -1;
    int beatsSize = [self.beatClasses count];
    int startBeat = self.currentBeat - 4;
    int endBeat = self.currentBeat + 4;
    
    while (startBeat < endBeat && startBeat > 4 && endBeat < beatsSize) {
        if ([[self.beatClasses objectAtIndex: startBeat] isEqualToString: @"LOW"]) {
            NSLog(@"beatclass LOW found at: %d", startBeat);
            beatIndex = startBeat;
            break;
        }
        startBeat++;
    }
    
    return beatIndex;
}

- (void) updateBeat:(NSTimer *)aTimer
{
    [self updateBeatTicker];
}



- (void) updateBeatTicker
{
    // if playing default to beat at current time
    double interval= 0;
    double beatStamp = 0;
    double nextBeatStamp = 0;
    
    //restart song
    if (self.currentBeat < 0 || self.currentBeat > [self.songBeats count] - 1) {
        self.currentBeat = 0;
        [self pause];
        [self play];
    }
    
    beatStamp = [[self.songBeats objectAtIndex:self.currentBeat] doubleValue];
    nextBeatStamp = [[self.songBeats objectAtIndex:self.currentBeat+1] doubleValue];
    interval = nextBeatStamp - beatStamp;
    
    if (self.currentBeat > 4 && self.currentBeat < [self.beatClasses count]- 5)
        [self updateBeatUIArray];
    
    NSLog(@"currentBeat: %d",self.currentBeat);
    NSLog(@"nextBeat in: %f",interval);
    NSLog(@"currentBeat class: %@", [self.beatClasses objectAtIndex: self.currentBeat]);
    
    self.beatTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateBeat:) userInfo:nil repeats:NO];
    
    self.currentBeat++;
}

- (void) updateBeatUIArray
{
    
    NSLog(@"preparing beats labels array!");
    int startBeat = self.currentBeat - 4;
    int endBeat = self.currentBeat + 4;
    NSString *beatLabel = @"";

    NSMutableArray *beatClassesUI = [[NSMutableArray alloc] init];
    
    while (startBeat < endBeat ) {
        beatLabel = [self.beatClasses objectAtIndex: startBeat];
        [beatClassesUI addObject:beatLabel];
        startBeat++;
    }
    [self.controller updateBeatArrayUI:beatClassesUI];
}



- (void) play
{
  /*  
   NSData *objectData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.songUrl]];
   
   self.player = [[AVAudioPlayer alloc] initWithData:objectData error:&playerError];
   
   [self.player prepareToPlay];
   [self.player play];
   [self.player setVolume:1.0];
   
   */
    
    NSLog(@"play called on: %@", self.songUrl);

    
    
    if(!self.player){

        NSLog(@"Player created for: %@", self.songUrl);
        
        /*

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
        */

        
    }
    double currentTime = [self.player currentTime];
    NSLog(@"currentTime: %@", [NSNumber numberWithDouble:currentTime]);
    int beatIndex = [self getBeatIndex:currentTime];
    
    if (beatIndex > 0 && beatIndex < [self.songBeats count]) {
        self.currentBeat = beatIndex;
    }
    
    [self updateBeatTicker];
    double beatStamp = [[self.songBeats objectAtIndex:self.currentBeat] doubleValue];
    [self.player setCurrentTime: beatStamp];
    [self.player prepareToPlay];
    [self.player play];
    [self.player setVolume:self.playerVolume];
    
}

- (void) pause
{
    if(self.player)[self.player pause];
    [self.beatTimer invalidate];
    self.beatTimer = nil;
}




- (void) loop
{
    
    double currentTime = [self.player currentTime];
    
    NSLog(@"currentTime: %@", [NSNumber numberWithDouble:currentTime]);
    
    //find beatStamp at current playing time

    int loopSize = 8;
    [self.songBeats firstObject];
    
    double beatStamp = 0;
    double interval= 0;
    int beatIndex = [self getBeatIndex:currentTime];
    
    int beatEnd = beatIndex + (loopSize+1);
    // if playing default to beat at current time + loopSize
    if ( beatIndex > 0 && beatEnd < [self.songBeats count]) {
        beatStamp = [[self.songBeats objectAtIndex:beatIndex] doubleValue];
        interval = [[self.songBeats objectAtIndex:beatEnd] doubleValue] - beatStamp;
    } else {
        // default to start beat + loopSize
        beatStamp = [[self.songBeats objectAtIndex: 0] doubleValue];
        interval =  [[self.songBeats objectAtIndex:loopSize] doubleValue] - beatStamp;
    }
    
    NSLog(@"beatIndex: %d", beatIndex);
    NSLog(@"beatStamp: %@", [NSNumber numberWithDouble:beatStamp]);
    NSLog(@"interval: %@", [NSNumber numberWithDouble:interval]);
    
    if (!_timer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        self.timer = timer;
    }
    
    
    if (!_peakTimer) {
        
        double peakDelay = interval - (double) 0.0011;
        NSLog(@"pEakDelay: %@", [NSNumber numberWithDouble:peakDelay]);
        self.peakTimer = [NSTimer scheduledTimerWithTimeInterval:peakDelay target:self selector:@selector(updatePeakTimer:) userInfo:nil repeats:YES];
        
    }
    
    if (!_poakTimer) {
        double poakDelay = interval + (double) 0.015;
        
        NSLog(@"pOakDelay: %@", [NSNumber numberWithDouble:poakDelay]);
        
        self.poakTimer = [NSTimer scheduledTimerWithTimeInterval:poakDelay target:self selector:@selector(updatePoakTimer:) userInfo:nil repeats:YES];
    }
    
    self.currentBeat = 0;
    self.lastTime = beatStamp;
    
}


- (void)updateTimer:(NSTimer *)aTimer {
    
    NSLog(@"loopStartAt: %@", [NSNumber numberWithDouble:[self.player currentTime]]);
    
    [self.player setCurrentTime:self.lastTime];
    
}

- (void)updatePeakTimer:(NSTimer *)aTimer {
    NSLog(@"firePeakAt: %@", [NSNumber numberWithDouble:[self.player currentTime]]);
    [self.player setVolume:0.0];
}

- (void)updatePoakTimer:(NSTimer *)aTimer {
    NSLog(@"firePoakAt: %@", [NSNumber numberWithDouble:[self.player currentTime]]);
    [self.player setVolume:1.0];
}

- (void) unloop
{
    
    [self.timer invalidate];
    self.timer = nil;
    [self.peakTimer invalidate];
    self.peakTimer = nil;
    [self.poakTimer invalidate];
    self.poakTimer = nil;
}

- (void) setVolume: (float) volume
{
    self.playerVolume = volume;
    [self.player setVolume:self.playerVolume];
}


@end


