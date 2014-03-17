//
//  IBeaterViewController.m
//  Ibeater
//
//  Created by Pablo Molina Pelaez on 23/02/2014.
//  Copyright (c) 2014 studios.faival.music. All rights reserved.
//
#import "WeMixBrain.h"
#import "IBeaterViewController.h"
#import "SocketIOPacket.h"
#import "SCUI.h"

@interface IBeaterViewController ()

@property (nonatomic) BOOL userIsplaying;
@property (nonatomic) BOOL userIsLooping;
@property (nonatomic, strong) WeMixBrain *weMixBrain;


@end

@implementation IBeaterViewController


@synthesize weMixBrain = _weMixBrain;
@synthesize trackAVolume = _trackAVolume;
@synthesize trackBVolume = _trackBVolume;
@synthesize crossfade = _crossfade;

@synthesize beatButton0 = _beatButton0;
@synthesize beatButton1 = _beatButton1;
@synthesize beatButton2 = _beatButton2;
@synthesize beatButton3 = _beatButton3;
@synthesize beatButton4 = _beatButton4;
@synthesize beatButton5 = _beatButton5;
@synthesize beatButton6 = _beatButton6;
@synthesize beatButton7 = _beatButton7;

-(UIButton *) beatButton0
{
    if (!_beatButton0)
        _beatButton0 = [[UIButton alloc] init];
    return _beatButton0;
}


-(WeMixBrain *)weMixBrain
{
    if(!_weMixBrain) _weMixBrain = [[WeMixBrain alloc] init];
    return _weMixBrain;
}

- (IBAction) login:(id) sender
{
    /*
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentModalViewController:loginViewController animated:YES];
    }];
     */
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI_2);
    self.trackAVolume.transform = trans;
    self.trackBVolume.transform = trans;
    
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    [_socketIO connectToHost:@"localhost" onPort:3000];
    
    
   
    
    NSMutableDictionary *joinData = [NSMutableDictionary dictionary];
    [joinData setObject:@"pabla" forKey:@"pName"];
    [joinData setObject:@"delahabla" forKey:@"pRoom"];
    NSLog(@"joinData = %@", joinData);
    
    [_socketIO sendEvent:@"join" withData: joinData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    
    NSLog(@"didReceiveMessage() >>> data: %@", packet.data);
    
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    
    NSLog(@"didReceiveJSON() >>> data: %@", packet.data);
    
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    
    NSDictionary *data = [packet.dataAsJSON valueForKey:@"args"];
    NSString *action = (NSString *)[[data  valueForKey:@"action"] firstObject];
    NSLog(@">>>>> action: %@", action);
    
    if ([@"joinData" isEqual: action]) {
       
        
        
        
        
        
        
        
        
        NSLog(@">>> gettingSongsKeys:");
        NSDictionary *playlist = (NSDictionary *)[[data valueForKey:@"tracks"] firstObject];
        
        if(playlist != nil) {
            NSLog(@"gettingPlaylist >>> song: %@", playlist);
            [self.weMixBrain addSongsDB:playlist];
        }

    }
   
}


- (IBAction)playPressed:(UIButton *)sender {

    NSString *defaultPlay = @"play";
    NSString *defaultPause = @"pause";
    NSString *playCommand = [defaultPlay stringByAppendingString:@"><"];
    NSString *pauseComand = [defaultPause stringByAppendingString:@"><"];
    NSString *newText;

    NSString *command = [sender titleForState:UIControlStateNormal];


    NSString *buttonId = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    if ([command isEqualToString:defaultPlay]) {
        newText= [ playCommand stringByAppendingString:buttonId];
        [sender setTitle:defaultPause forState:UIControlStateNormal];

    } else {
        newText= [ pauseComand stringByAppendingString:buttonId];
        [sender setTitle:defaultPlay forState:UIControlStateNormal];
    }
    
    [self.weMixBrain performCommand: newText];
}

- (IBAction)loopPressed:(UIButton *)sender {
    NSString *defaultLoop = @"loop";
    NSString *defaultUnloop = @"unloop";
    NSString *loopCommand = [defaultLoop stringByAppendingString:@"><"];
    NSString *unloopCommand = [defaultUnloop stringByAppendingString:@"><"];
    NSString *newText;

    NSString *command = [sender titleForState:UIControlStateNormal];
    
    NSString *buttonId = [NSString stringWithFormat:@"%ld", (long)[sender tag]];
    
    if ([command isEqualToString:defaultLoop]) {
        newText= [loopCommand stringByAppendingString: buttonId];
        [sender setTitle:defaultUnloop forState:UIControlStateNormal];

    } else {
        newText= [ unloopCommand stringByAppendingString: buttonId];
        [sender setTitle:defaultLoop forState:UIControlStateNormal];
    }
    
    [self.weMixBrain performCommand: newText];

}


-(void) computeTrackVolumes:(float)crossfadeValue
{
    
    float log0 = log(crossfadeValue)/10;
    float log1 = log(1- crossfadeValue)/10;
    float targetVolume0 = [self.trackAVolume value] + log1;
    float targetVolume1 = [self.trackBVolume value] + log0;
    if (targetVolume0 < 0 || targetVolume0 == NAN) {
        targetVolume0 = 0;
    }
    if (targetVolume1 < 0 || targetVolume1 == NAN) {
        targetVolume1 = 0;
    }
    NSLog(@"volume0 : %f", targetVolume0);
    NSLog(@"volume1 : %f", targetVolume1);
    
    [self.weMixBrain volumeTrack0:targetVolume0];
    [self.weMixBrain volumeTrack1:targetVolume1];

}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    [self computeTrackVolumes: self.crossfade.value];
}


-(void) updateBeatArrayUI:(NSArray *) beatClasses
{
    
    NSLog(@"setting labels for");
    
    [self.beatButton0 setTitle:[beatClasses objectAtIndex:0] forState: UIControlStateNormal];
    [self.beatButton1 setTitle:[beatClasses objectAtIndex:1] forState: UIControlStateNormal];
    
    NSString *beatClass = @"!";
    int beatIndex = 0;
    for (beatClass in beatClasses) {
        NSString *key = [NSString stringWithFormat:@"beatButton%d", beatIndex];

        NSLog(@"betting self button for %@",key);
        
        UIButton *button =  (UIButton *)[self valueForKey:key];

        NSLog(@"setting label for %@", beatClass);
        NSLog(@"setting label for button %@", [button titleForState:UIControlStateNormal]);
        [button setTitle:beatClass forState: UIControlStateNormal];
        beatIndex++;
    }
}

@end
