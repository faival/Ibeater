//
//  WeMixBrain.h
//  wemix
//
//  Created by Pablo Molina Pelaez on 16/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WeMixBrain : NSObject


@property (nonatomic, strong) AVAudioPlayer *player;

- (void) pushSong: (NSString *) songUrl;
- (void) performCommand: (NSString *) command;

@end
