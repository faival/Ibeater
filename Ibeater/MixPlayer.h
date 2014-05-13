//
//  MixPlayer.h
//  Ibeater
//
//  Created by Pablo Molina Pelaez on 04/03/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "WeMixBrain.h"
#import "AudioStreamer.h"

@interface MixPlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AudioStreamer *streamPlayer;

@property (nonatomic, strong) WeMixBrain *mixController;
@property (nonatomic) BOOL isMaster;



- (void) setSongURL:(NSString *)songUrl;
- (void) setRate:(float) tempo;
- (void) setOriginalRate:(float) tempo;

- (void) setSongBeatStamps:(NSMutableArray *) songBeats;
- (NSMutableArray *) getSongBeatStamps;
- (void) setSongBeatClasses:(NSMutableArray *) beatClasses;
- (void) play;
- (void) pause;
- (void) loop;
- (void) unloop;
- (void) setVolume: (float) volume;

- (void) setMaster;
- (void) setSlave;


@end
