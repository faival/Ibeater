//
//  MixPlayer.h
//  Ibeater
//
//  Created by Pablo Molina Pelaez on 04/03/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SCUI.h"
#import "IBeaterViewController.h"

@interface MixPlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) IBeaterViewController *controller;

- (void) setSongURL:(NSString *)songUrl;
- (void) setSongBeatStamps:(NSMutableArray *) songBeats;
- (void) setSongBeatClasses:(NSMutableArray *) beatClasses;
- (void) play;
- (void) pause;
- (void) loop;
- (void) unloop;
- (void) setVolume: (float) volume;
@end
