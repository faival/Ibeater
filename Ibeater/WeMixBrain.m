//
//  WeMixBrain.m
//  wemix
//
//  Created by Pablo Molina Pelaez on 16/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import "WeMixBrain.h"
#import "MixPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface WeMixBrain ()

@property (nonatomic) int currentSong;
@property (nonatomic, strong) MixPlayer *track0;
@property (nonatomic, strong) MixPlayer *track1;
@property (nonatomic, strong) MixPlayer *track2;
@property (nonatomic) float volumeTrack0;
@property (nonatomic) float volumeTrack1;
@property (nonatomic, strong) NSDictionary *songsDB;
@property (nonatomic, strong) NSNumber *songClickedPlayTStamp;

@end


@implementation WeMixBrain

@synthesize songsDB = _songsDB;

@synthesize track0 = _track0;
@synthesize track1 = _track1;
@synthesize track2 = _track2;

@synthesize songClickedPlayTStamp = _songClickedPlayTStamp;
@synthesize currentSong = _currentSong;

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

- (void) initialisePlayers
{

    NSMutableArray *songNames = [self getSongNames];
    NSArray *nameArray = nil;
    NSString *songParsed = nil;
    NSString *archiveOrgUrl = nil;
    MixPlayer *newMixPlayer = nil;
    NSString *currentSong = nil;
    int numSongs = [songNames count];
    
    for (int i = 0; i < numSongs && i < 2; i++) {
        
        
        currentSong = [songNames objectAtIndex:i];

        nameArray = [currentSong componentsSeparatedByString:@"-"];
        songParsed = [[[nameArray firstObject]stringByAppendingString:@"/"] stringByAppendingString:[nameArray lastObject]];
        archiveOrgUrl = [@"https://www.archive.org/download/" stringByAppendingString:songParsed];
        
        NSLog(@">>>> init player for: %@", archiveOrgUrl);
        newMixPlayer = [[MixPlayer alloc] init];
        

        NSDictionary *songItemInfo = [[NSDictionary alloc] initWithDictionary:[self.songsDB objectForKey:currentSong]];
        NSDictionary *songInfo = [[NSDictionary alloc] initWithDictionary:[songItemInfo objectForKey:@"songData"]];
        NSDictionary *beatsInfo = [[NSDictionary alloc] initWithDictionary: [songItemInfo objectForKey:@"beatsData"]];
        
        
        NSLog(@">>>> song objects got for: %@", archiveOrgUrl);
        
    
        NSEnumerator *beats = [beatsInfo keyEnumerator];
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
            beatClass = [NSString stringWithFormat:@"%@",[[beatsInfo objectForKey: beatKey] objectForKey:@"class"]];
            [onsets addObject: [NSNumber numberWithDouble: beatStamp]];
            [beatClasses addObject: beatClass];
            beatIndex++;
        }
        
        [newMixPlayer setSongURL:archiveOrgUrl];
        
        NSLog(@" setting song beat stamps: %@", onsets);
        [newMixPlayer setSongBeatStamps: onsets];
        [newMixPlayer setSongBeatClasses: beatClasses];
        
        if (i == 0) {
            self.track0 = newMixPlayer;
        } else if( i == 1){
            self.track1 = newMixPlayer;
        } else if (i == 2) {
            self.track2 = newMixPlayer;
        }
    }
}

- (MixPlayer *) getMixPlayer: (int)mixNumber
{
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
    if (songIndex > 2)
        return;
    
    self.currentSong = songIndex;
    
    
    MixPlayer *mixPlayer = [self getMixPlayer: self.currentSong];
//    [[MixPlayer alloc] init];
    //  mixPlayer = [self getMixPlayer: self.currentSong];
    

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
    
    NSLog(@"performCommand: %@", command);
}


- (void) volumeTrack0: (float) volumeValue
{
    self.volumeTrack0 = volumeValue;
    [self.track0 setVolume:self.volumeTrack0];
}

- (void) volumeTrack1: (float) volumeValue
{
    self.volumeTrack1 = volumeValue;
    [self.track1 setVolume:self.volumeTrack1];
}




@end
