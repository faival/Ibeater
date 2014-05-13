//
//  MixPlayer.m
//  Ibeater
//
//  Created by Pablo Molina Pelaez on 04/03/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import "MixPlayer.h"
#import "IBeaterAppDelegate.h"


@interface MixPlayer()

#define USE_STREAM_PLAYER 1
#define USE_AV_PLAYER 0
#define LOOP_SIZE 4

@property (nonatomic, strong) NSMutableArray *songBeats;
@property (nonatomic, strong) NSMutableArray *beatClasses;

@property (nonatomic) int currentBeat;
@property (nonatomic) double loopStartTime;
@property (nonatomic, strong) NSString *songUrl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *peakTimer;
@property (nonatomic, strong) NSTimer *poakTimer;
@property (nonatomic, strong) NSTimer *beatTimer;



@property (nonatomic) double lastTime;
@property (nonatomic) float tempo;
@property (nonatomic) float originalTempo;
@property (nonatomic) float tempoRate;

@property (nonatomic) float playerVolume;

@end

@implementation MixPlayer

@synthesize streamPlayer = _streamPlayer;
@synthesize mixController = _mixController;
@synthesize songBeats = _songBeats;
@synthesize beatClasses = _beatClasses;
@synthesize songUrl = _songUrl;
@synthesize currentBeat = _currentBeat;
@synthesize timer = _timer;
@synthesize peakTimer = _peakTimer;
@synthesize poakTimer = _poakTimer;
@synthesize tempo = _tempo;
@synthesize originalTempo = _originalTempo;
@synthesize playerVolume = _playerVolume;

-(WeMixBrain *)mixController
{
    if(!_mixController) _mixController = [[WeMixBrain alloc] init];
    return _mixController;
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


-(void) setSongURL:(NSString *)songUrl
{
    self.songUrl = songUrl;
    self.currentBeat = 0;
    
#if USE_STREAM_PLAYER
    NSLog(@"using: USE_STREAM_PLAYER");
    self.streamPlayer = [[AudioStreamer alloc] init];
    self.streamPlayer = [self.streamPlayer initWithURL:[NSURL URLWithString:self.songUrl]];
#endif
    
#if USE_AV_PLAYER == 1
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:self.songUrl]
             usingParameters:nil
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 
                 NSError *playerError;
                  self.player = [[AVAudioPlayer alloc] initWithData:data error: &playerError];
                  NSLog(@"Player created for: %@", self.songUrl);
                  
                  
                  self.player.enableRate = true;
                  [self.player prepareToPlay];
                  [self.player play];
                  [self.player pause];
                  [self.player setVolume:self.playerVolume];
                  
                  }];
#endif
}





- (void) setSongBeatStamps:(NSMutableArray *) songBeats
{
    self.songBeats = songBeats;
}

- (NSMutableArray *) getSongBeatStamps
{
    return self.songBeats;
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
    int beatIndex = 1;
    int beatsSize = [self.beatClasses count];
    int startBeat = self.currentBeat - 4;
    int endBeat = self.currentBeat + 4;
    double beatDescriptorCompareFactor = 0.01;
    
    while (startBeat < endBeat && startBeat > 4 && endBeat < beatsSize) {
        
        double beatDescriptor = [[self.beatClasses objectAtIndex: startBeat] doubleValue];
        double currentBeatDescriptor = [[self.beatClasses objectAtIndex: startBeat] doubleValue];
        if (beatDescriptor > currentBeatDescriptor + beatDescriptorCompareFactor &&
            beatDescriptor < currentBeatDescriptor - beatDescriptorCompareFactor) {
            NSLog(@"beatclass compare found at: %d", startBeat);
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
    
    self.currentBeat++;
}



- (void) updateBeatTicker
{
    // if playing default to beat at current time
    double interval= 0;
    double beatStamp = 0;
    double nextBeatStamp = 0;
    int beatsSize = (int)[self.songBeats count] - 2;
    
    //restart song
    if (self.currentBeat < 0 || self.currentBeat > beatsSize) {
        self.currentBeat = 0;
        //TODO use only setCurrentTime on beat position
        [self pause];
        [self play];
        return;
    }
    /*
    if (self.isMaster) {
        [self.mixController updateCurrentMasterSongTick];
        if (self.currentBeat % 8 == 0 && self.currentBeat > 5 && self.currentBeat < beatsSize - 5)
            [self.mixController pushBeatClassesUIArray:
             [self getBeatClassesUIArray:self.currentBeat]];
    }
     */
    
    beatStamp = [[self.songBeats objectAtIndex:self.currentBeat] doubleValue];
    nextBeatStamp = [[self.songBeats objectAtIndex:self.currentBeat+1] doubleValue];
    interval = nextBeatStamp - beatStamp;
    
    interval = interval / self.tempoRate;
    
    NSLog(@"currentBeat: %d",self.currentBeat);
    NSLog(@"nextBeat in: %f",interval);
    NSLog(@"currentBeat class: %@", [self.beatClasses objectAtIndex: self.currentBeat]);
    
    
    self.beatTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateBeat:) userInfo:nil repeats:NO];

}

- (NSMutableArray *) getBeatClassesUIArray: (int) currentBeat
{
    NSLog(@"preparing beats labels array for beat: %d", currentBeat);


    int startBeat = currentBeat - 4;
    int endBeat = currentBeat + 4;
    NSString *beatLabel = nil;
    NSMutableArray *beatClassesUI = [[NSMutableArray alloc] init];
    while (startBeat < endBeat ) {

        beatLabel = [self.beatClasses objectAtIndex: startBeat];
        NSLog(@"getting currentClass: %@", beatLabel);
        [beatClassesUI addObject:beatLabel];
        startBeat++;
    }
    return beatClassesUI;
}



- (void) play
{
    NSLog(@"play called on: %@", self.songUrl);
    

    double currentTime = 10.0;
    //TODO PLAYER SPECIFIC
#if USE_AV_PLAYER
    currentTime = [self.player currentTime];
#endif

    NSLog(@"currentTime: %@", [NSNumber numberWithDouble:currentTime]);
    int beatIndex = [self getBeatIndex:currentTime];
    
    if (beatIndex > 0 && beatIndex < [self.songBeats count]) {
        self.currentBeat = beatIndex;
    }
    
    [self updateBeatTicker];
    double beatStamp = [[self.songBeats objectAtIndex:self.currentBeat] doubleValue];

    NSLog(@"currentTime: %@", [NSNumber numberWithDouble:currentTime]);
    NSLog(@"beatStamp: %@", [NSNumber numberWithDouble:beatStamp]);
    
#if USE_STREAM_PLAYER
    NSLog(@"using: USE_STREAM_PLAYER");
    if (![self.streamPlayer isPlaying]) {
        [self.streamPlayer start];
    }
    [self.streamPlayer seekToTime:beatStamp];
    [self.streamPlayer setVolume:self.playerVolume];
#endif
#if USE_AV_PLAYER
    NSLog(@"using: USE_AV_PLAYER");
    [self.player setCurrentTime: beatStamp];
    [self.player play];
    [self.player setVolume:self.playerVolume];
#endif
    
}

- (void) pause
{
    
#if USE_STREAM_PLAYER
    [self.streamPlayer pause];
#endif
#if USE_AV_PLAYER
    [self.player pause];
#endif
    [self.beatTimer invalidate];
    self.beatTimer = nil;
}


- (void) loop
{
    if (self.currentBeat  + LOOP_SIZE > [self.songBeats count]) {
        return;
    }
    self.loopStartTime = [[self.songBeats objectAtIndex:self.currentBeat] doubleValue];
    double loopEndTime = [[self.songBeats objectAtIndex:self.currentBeat + LOOP_SIZE] doubleValue];
#if USE_STREAM_PLAYER
    NSLog(@"loopStartTime: %f loopEndTime: %f", self.loopStartTime , loopEndTime);
    [self.streamPlayer loop: self.loopStartTime : loopEndTime];
#endif
    
#if USE_AV_PLAYER
    
    //TODO PLAYER SPECIFIC
    double currentTime = 0.0;
    int loopSize = 8;
    [self.songBeats firstObject];
    
    double beatStamp = 0;
    double interval= 0;
    int beatIndex = self.currentBeat;//[self getBeatIndex:currentTime];
    currentTime = [self.player currentTime];
    
    NSLog(@"currentTime: %@", [NSNumber numberWithDouble:currentTime]);
    
    //find beatStamp at current playing time

    
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
    
    interval = interval / self.tempoRate;
    
    if (!_timer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: (interval * self.tempoRate) target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        self.timer = timer;
    }
    
    
    if (!_peakTimer) {
        
        double peakDelay = (interval - (double) 0.0011) * self.tempoRate;
        NSLog(@"pEakDelay: %@", [NSNumber numberWithDouble: peakDelay]);
        self.peakTimer = [NSTimer scheduledTimerWithTimeInterval:peakDelay target:self selector:@selector(updatePeakTimer:) userInfo:nil repeats:YES];
        
    }
    
    if (!_poakTimer) {
        
        double poakDelay = (interval + (double) 0.015) * self.tempoRate;
        NSLog(@"pOakDelay: %@", [NSNumber numberWithDouble:poakDelay]);
        self.poakTimer = [NSTimer scheduledTimerWithTimeInterval:poakDelay target:self selector:@selector(updatePoakTimer:) userInfo:nil repeats:YES];
    }
    self.lastTime = beatStamp;
    
#endif
    
}


- (void)updateTimer:(NSTimer *)aTimer {
    
#if USE_AV_PLAYER
    [self.player setCurrentTime:self.lastTime];
#endif
}

- (void)updatePeakTimer:(NSTimer *)aTimer
{
   
#if USE_AV_PLAYER
    [self.player setVolume:0.0];
#endif

}

- (void)updatePoakTimer:(NSTimer *)aTimer
{
#if USE_AV_PLAYER
    [self.player setVolume:1.0];
#endif
    
}

- (void) unloop
{

#if USE_STREAM_PLAYER
    [self.streamPlayer unloop];
#endif
    
#if USE_AV_PLAYER
    [self.timer invalidate];
    self.timer = nil;
    [self.peakTimer invalidate];
    self.peakTimer = nil;
    [self.poakTimer invalidate];
    self.poakTimer = nil;
#endif

}

- (void) setVolume: (float) volume
{
    self.playerVolume = volume;
#if USE_AV_PLAYER
    [self.player setVolume:self.playerVolume];
#endif
    
#if USE_STREAM_PLAYER
    [self.streamPlayer setVolume: self.playerVolume];
#endif
    
    
}


- (void) setOriginalRate:(float) tempo
{
    self.originalTempo = tempo;
}

- (void) setRate: (float) tempo
{
    self.tempo = tempo;
#if USE_AV_PLAYER
    [self.player setRate:tempo];
#endif
    
#if USE_STREAM_PLAYER
    self.tempoRate = self.tempo;
    [self.streamPlayer setRate: self.tempoRate];
#endif
}

- (void) setPitch: (float) pitch
{
#if USE_STREAM_PLAYER
    [self.streamPlayer setPitch: pitch];
#endif
}

- (void) setMaster
{
    self.isMaster = true;
}

- (void) setSlave
{
    self.isMaster = false;
}










@end


