//
//  WeMixBrain.m
//  wemix
//
//  Created by Pablo Molina Pelaez on 16/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import "WeMixBrain.h"
#import "MixPlayer.h"
#import "IBeaterViewController.h"
#import "MixerHostAudio.h"
#import <AVFoundation/AVFoundation.h>

NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";

@interface WeMixBrain ()

@property (nonatomic) int currentSong;
@property (nonatomic) int tempoTickCounter;
@property (nonatomic) float currentTempo;
@property (nonatomic, strong) IBeaterViewController *mixUIController;
@property (nonatomic, strong) MixPlayer *track0;
@property (nonatomic, strong) MixPlayer *track1;
@property (nonatomic, strong) MixPlayer *track2;
@property (nonatomic, strong) MixerHostAudio *mixerHost;
@property (nonatomic) float volumeTrack0;
@property (nonatomic) float volumeTrack1;
@property (nonatomic, strong) NSDictionary *songsDB;
@property (nonatomic, strong) NSMutableArray *songsNames;
@property (nonatomic, strong) NSMutableArray *masterSongBeatStamps;
@property (nonatomic, strong) NSNumber *songClickedPlayTStamp;

@end


@implementation WeMixBrain


@synthesize mixUIController = _mixUIController;
@synthesize songsDB = _songsDB;

@synthesize mixerHost = _mixerHost;

@synthesize track0 = _track0;
@synthesize track1 = _track1;
@synthesize track2 = _track2;

@synthesize songClickedPlayTStamp = _songClickedPlayTStamp;
@synthesize tempoTickCounter = _tempoTickCounter;
@synthesize currentSong = _currentSong;
@synthesize currentTempo = _currentTempo;

-(IBeaterViewController *)mixUIController
{
    if(!_mixUIController) _mixUIController = [[IBeaterViewController alloc] init];
    return _mixUIController;
}

-(NSMutableArray *)songsNames
{
    if(!_songsNames) {
        _songsNames = [[NSMutableArray alloc] init];
    }
    return _songsNames;
}

-(NSMutableArray *)masterSongBeatStamps
{
    if(!_masterSongBeatStamps) {
        _masterSongBeatStamps = [[NSMutableArray alloc] init];
    }
    return _masterSongBeatStamps;
}

-(MixPlayer *)track0
{
    if (!_track0) _track0 = [[MixPlayer alloc] init];
    return _track0;
}

-(MixPlayer *)track1
{
    if (!_track1) _track1 = [[MixPlayer alloc] init];
    return _track1;
}

-(MixPlayer *)track2
{
    if (!_track2) _track2 = [[MixPlayer alloc] init];
    return _track2;
}


-(NSDictionary *)songsDB
{
    if (!_songsDB) _songsDB = [[NSDictionary alloc] init];
    return _songsDB;
}


-(NSNumber *)songClickedPlayTStamp
{
    if(!_songClickedPlayTStamp) _songClickedPlayTStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    return _songClickedPlayTStamp;
    
}

- (void) registerForAudioObjectNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handlePlaybackStateChanged:)
                               name: MixerHostAudioObjectPlaybackStateDidChangeNotification
                             object: self.mixerHost];
}

- (void) initializeMixerSettingsToUI {
    
    // Initialize mixer settings to UI
    [self.mixerHost enableMixerInput: 0 isOn: true];
    [self.mixerHost enableMixerInput: 1 isOn: true];
    
    [self.mixerHost setMixerOutputGain: 1.0f];
    [self.mixerHost setMixerInput: 0 gain: 1.0f];
    [self.mixerHost setMixerInput: 1 gain: 1.0f];
}

- (void) initialisePlayers
{

    NSMutableArray *songNames = [self getSongNames];
    NSArray *nameArray = nil;
    NSString *songParsed = nil;
    NSString *archiveOrgUrl = nil;
    //MixPlayer *newMixPlayer = nil;
    NSString *currentSong = nil;
    
    MixerHostAudio *newAudioObject = [[MixerHostAudio alloc] init];
    self.mixerHost = newAudioObject;
    
    [self registerForAudioObjectNotifications];
    [self initializeMixerSettingsToUI];
    
    
    int numSongs = [songNames count];
    
    for (int i = 0; i < 2; i++) {
        
        currentSong = [songNames objectAtIndex:i];
        [self.songsNames addObject:currentSong];

        /*
        nameArray = [currentSong componentsSeparatedByString:@"+$$%%$$+"];
        songParsed = [[[nameArray firstObject]stringByAppendingString:@"/"] stringByAppendingString:[nameArray lastObject]];
        */
        
        archiveOrgUrl = [@"https://www.archive.org/download/" stringByAppendingString:currentSong];
        
        
        
        NSLog(@">>>> init player for: %@", archiveOrgUrl);
        //newMixPlayer = [[MixPlayer alloc] init];
        

        

        NSDictionary *songItemInfo = [[NSDictionary alloc] initWithDictionary:[self.songsDB objectForKey:currentSong]];
        NSDictionary *songInfo = [[NSDictionary alloc] initWithDictionary:[songItemInfo objectForKey:@"songData"]];
        NSDictionary *beatsInfo = [[NSDictionary alloc] initWithDictionary: [songItemInfo objectForKey:@"beatsData"]];
        
        
        NSLog(@">>>> song objects got for: %@", archiveOrgUrl);
        

        NSMutableArray *onsets = [[NSMutableArray alloc] init];
        NSMutableArray *beatClasses = [[NSMutableArray alloc] init];
                           
      

        int beatIndex = 0;
        int beatsSize = [beatsInfo count];
        NSLog(@">>>> getting beats info total: %d", beatsSize);
        
        NSString *beatKey = nil;
        NSString *beatClass = nil;
        double beatStamp = 0;
        while (beatIndex < beatsSize) {
            beatKey = [NSString stringWithFormat:@"%d", beatIndex];
            beatStamp = [[[beatsInfo objectForKey: beatKey] objectForKey:@"beatStamp"] doubleValue];
            [onsets addObject: [NSNumber numberWithDouble: beatStamp]];
            
            beatClass = [NSString stringWithFormat:@"%@",[[beatsInfo objectForKey: beatKey] objectForKey:@"beatDescriptor"]];
            [beatClasses addObject: beatClass];
            beatIndex++;
        }
    
        
        //[newMixPlayer setSongURL:archiveOrgUrl];
        float songBpm = [(NSNumber *)[songInfo objectForKey:@"bpm"] floatValue];
        //[newMixPlayer setOriginalRate:songBpm];
        //[newMixPlayer setRate:1];
        NSLog(@" setting song beat stamps: %@", onsets);
        //[newMixPlayer setSongBeatStamps: onsets];
        //[newMixPlayer setSongBeatClasses: beatClasses];
        /*
        if (i == 0) {
            self.track0 = newMixPlayer;
        } else if( i == 1){
            self.track1 = newMixPlayer;
        } else if (i == 2) {
            self.track2 = newMixPlayer;
        }
         */
    }

}

- (MixPlayer *) getMixPlayer: (int)mixNumber
{
    /*
    NSLog(@">>>> get player : %d", mixNumber);
    switch (mixNumber) {
        case 0:
            return self.track0;
            break;
        case 1:
            return self.track1;
            break;
        case 2:
            return self.track2;
            break;
        default:
            break;
    }
    */
    return nil;
}

- (void) addSongsDB: (NSDictionary *) songsDB
{
    self.songsDB = songsDB;
    [self initialisePlayers];
}

-(NSMutableArray *) getSongNames
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSEnumerator *songsInPlaylist = [self.songsDB keyEnumerator];
    NSString *songId = nil;
    songId = [songsInPlaylist nextObject];
    while(songId != nil) {
        [result addObject:songId];
        songId = [songsInPlaylist nextObject];
    }
    return result;
}

- (void) performCommand:(NSString *)command
{
    NSArray *commandParams = [command componentsSeparatedByString:@"><"];
    NSString *action = [commandParams firstObject];
    NSString *songIndexStr = [commandParams lastObject];
 
    int songIndex = [songIndexStr integerValue];
    if (songIndex >= [self.songsNames count])
        return;
    
    self.currentSong = songIndex;
    /*
    
    MixPlayer *mixPlayer = [self getMixPlayer: self.currentSong];
    
    if([@"play" isEqual: action]) {
        
        NSLog(@"play: %@", command);
        [mixPlayer play];
    }
    else if ([@"pause" isEqual: action]) {
        NSLog(@"pause: %@", command);
        [mixPlayer pause];
    }
    else if([@"loop" isEqual: action]) {
        NSLog(@"loop: %@", command);
        [mixPlayer loop];
    }
    else if ([@"unloop" isEqual: action]) {
        NSLog(@"unloop: %@", command);
        [mixPlayer unloop];
    }
    */
    NSLog(@"performCommand: %@", command);
}


- (void) volumeTrack0: (float) volumeValue
{
    self.volumeTrack0 = volumeValue;
    
    //[self.track0 setVolume:self.volumeTrack0];
}

- (void) volumeTrack1: (float) volumeValue
{
    self.volumeTrack1 = volumeValue;
    //[self.track1 setVolume:self.volumeTrack1];
}

- (void) pushBeatClassesUIArray: (NSMutableArray *) currentClasses
{
    
    NSLog(@"updating ui with classes: %lu", (unsigned long)[currentClasses count]);
    [self.mixUIController updateBeatArrayUI: currentClasses];
}

- (void) updateTempoTickCounter
{
    self.tempoTickCounter++;
    if (self.tempoTickCounter > 8) {
        self.tempoTickCounter = 0;
    }
}


- (void) updateCurrentMasterSongTick
{
    
    NSLog(@"song: %d is ticking", self.currentSong);
    //update global tempoTick
    [self updateTempoTickCounter];
}


- (void) setMasterTempo: (float) tempo
{


    self.currentTempo = tempo;
    NSLog(@"tempo set: %f", self.currentTempo);
    
    
    NSDictionary *songDict  = [[NSDictionary alloc] init];
    NSString *masterSong = (NSString *)[self.songsNames objectAtIndex:self.currentSong];

    songDict = [[self.songsDB objectForKey:masterSong] objectForKey:@"songData"];
    NSLog(@"songInfo: %@", songDict);
    float masterTempo = [(NSNumber *)[songDict valueForKey:@"bpm"] floatValue];
    float indexTempo = masterTempo;
    int index = 0;
    
    //MixPlayer *targetTrack = nil;
    /*
    NSLog(@"mastertempo %f", masterTempo);

    //adjust rate of master track
    targetTrack = [self getMixPlayer:self.currentSong];
    [targetTrack setRate:self.currentTempo];
    [targetTrack setMaster];
    
    //adjust rate based on masterTempo on all other players
    NSString *songName = (NSString *)[self.songsNames firstObject];
    while (index < [self.songsNames count]) {
        if (index != self.currentSong) {
            songDict = [[self.songsDB objectForKey:[self.songsNames objectAtIndex:index]] objectForKey:@"songData"];
            indexTempo = [(NSNumber *)[songDict valueForKey:@"bpm"] floatValue];
            targetTrack = (MixPlayer *)[self getMixPlayer:index];
            [targetTrack setRate:self.currentTempo];
            [targetTrack setSlave];
        }
        index++;
    }
     */
}


@end
