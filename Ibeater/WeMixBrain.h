//
//  WeMixBrain.h
//  wemix
//
//  Created by Pablo Molina Pelaez on 16/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeMixBrain : NSObject

- (void) addSongsDB: (NSDictionary *) songsDB;
- (void) performCommand: (NSString *) command;

- (void) volumeTrack0: (float) volumeValue;
- (void) volumeTrack1: (float) volumeValue;
- (void) setMasterTempo: (float) tempo;
- (void) updateCurrentMasterSongTick;
- (void) pushBeatClassesUIArray: (NSMutableArray *) currentClasses;

@end
