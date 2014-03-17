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

@property (weak, nonatomic) IBOutlet UIButton *beatButton0;

@property (weak, nonatomic) IBOutlet UIButton *beatButton1;
@property (weak, nonatomic) IBOutlet UIButton *beatButton2;
@property (weak, nonatomic) IBOutlet UIButton *beatButton3;
@property (weak, nonatomic) IBOutlet UIButton *beatButton4;
@property (weak, nonatomic) IBOutlet UIButton *beatButton5;
@property (weak, nonatomic) IBOutlet UIButton *beatButton6;
@property (weak, nonatomic) IBOutlet UIButton *beatButton7;

-(void) updateBeatArrayUI:(NSArray *) beatClasses;


@end
