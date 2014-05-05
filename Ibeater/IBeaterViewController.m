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

@interface IBeaterViewController ()

@property (nonatomic) BOOL userIsplaying;
@property (nonatomic) BOOL userIsLooping;
@property (nonatomic, strong) WeMixBrain *weMixBrain;
@property (nonatomic, strong) NSMutableArray *buttons1;
@property (nonatomic, strong) NSMutableArray *labels1;
@property (nonatomic, strong) IBOutlet UILabel *currentLabel;
@property (nonatomic, strong) IBOutlet UIButton *currentButton;

@end

@implementation IBeaterViewController


@synthesize weMixBrain = _weMixBrain;
@synthesize trackAVolume = _trackAVolume;
@synthesize trackBVolume = _trackBVolume;
@synthesize tempoControl = _tempoControl;
@synthesize crossfade = _crossfade;
@synthesize buttons1 = _buttons1;
@synthesize currentButton = _currentButton;
@synthesize currentLabel = _currentLabel;

//@synthesize labels1 = _labels1;

/*
-(NSMutableArray *)buttons1
{
    if (!_buttons1){
        _buttons1 = [[NSMutableArray alloc] init];
    }
    return _buttons1;
}
-(NSMutableArray *)labels1
{
    if (!_labels1){
        _labels1 = [[NSMutableArray alloc] init];
    }
    return _labels1;
}
*/

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
            [self computeTrackVolumes: self.crossfade.value];
        }
    }
}

- (IBAction)beatButtonClickedForTrack1:(UIButton*) beatButton
{
    
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
    
    // apply crossFade logarithmic scale to the gain on both tracks
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
    
    [self.weMixBrain volumeTrack0:targetVolume0];
    [self.weMixBrain volumeTrack1:targetVolume1];

}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    [self computeTrackVolumes: self.crossfade.value];
}

- (IBAction)tempoControlChanged:(UISlider *)sender
{
    [self.weMixBrain setMasterTempo: sender.value];
}

-(void) updateBeatArrayUI:(NSMutableArray *) beatClasses
{
    
    int beatIndex = 0;
    while (beatIndex < 8) {
        NSLog(@"getting label for %d", beatIndex);
        self.currentLabel = [self.labels1 objectAtIndex:beatIndex];
        NSLog(@"getting beatClass for label %@", [self.currentLabel text]);
        NSString *beatClass = (NSString *)[beatClasses objectAtIndex:beatIndex];
        NSLog(@"setting label for button %@", beatClass);
        [self.currentLabel setText: beatClass];
        beatIndex++;
    }
}

/*
- (void)addButtonsToView
{
    
    if (!self.buttons1)
        self.buttons1 = [[NSMutableArray alloc] init];
    
    
    NSArray *buttons = @[@{@"Tag":@100,@"Title":@"red",@"Color":[UIColor redColor]},
                         @{@"Tag":@200,@"Title":@"blue",@"Color":[UIColor blueColor]},
                         @{@"Tag":@300,@"Title":@"green",@"Color":[UIColor greenColor]}];
    
    CGRect frame = CGRectMake(0.0f, 0.0f, 50.0f, 30.0f);
    for (NSDictionary *dict in buttons)
    {
        UIButton *button =[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = frame;
        button.tag = [dict[@"Tag"] integerValue];
        [button setTitle:dict[@"Title"]
                forState:UIControlStateNormal];
        button.backgroundColor = dict[@"Color"];
        [button setTitleColor:[UIColor blackColor]
                     forState:UIControlStateNormal];
        //[button addTarget:self action:@selector(buttonAction:)
        //forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:button];
        [self.buttons1 addObject: button];
        NSLog(@"initialising button: %@", dict[@"Title"]);
        frame.origin.x+=frame.size.width+20.0f;
    }
    
    CGSize contentSize = self.view.frame.size;
    contentSize.width = frame.origin.x;
}
*/
@end
