//
//  IBeaterViewController.h
//  Ibeater
//
//  Created by Pablo Molina Pelaez on 23/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//
#import "SocketIO.h"
#import <UIKit/UIKit.h>

@interface IBeaterViewController : UIViewController<SocketIODelegate>

@property (nonatomic,strong) SocketIO* socketIO;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *loopButton;

@property (weak, nonatomic) IBOutlet UISlider *trackAVolume;
@property (weak, nonatomic) IBOutlet UISlider *trackBVolume;
@property (weak, nonatomic) IBOutlet UISlider *crossfade;

@property (weak, nonatomic) IBOutlet UISlider *tempoControl;


-(void) updateBeatArrayUI:(NSMutableArray *) beatClasses;


@end
