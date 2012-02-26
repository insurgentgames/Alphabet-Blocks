//
//  AlphabetBlocksAppDelegate.m
//  AlphabetBlocks
//
//  Created by micah on 8/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AlphabetBlocksAppDelegate.h"
#import "cocos2d.h"
#import "BlockLayer.h"
#import "MainMenu.h"

@implementation AlphabetBlocksAppDelegate

@synthesize music;
@synthesize options;
@synthesize typeOfBlocks;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:YES];
	
	// must be called before any othe call to the director
	[Director useFastDirector];
	
	// AnimationInterval doesn't work with FastDirector, yet
	//[[Director sharedDirector] setAnimationInterval:1.0/60];
	//[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];
	
	// And you can later, once the openGLView was created
	// you can change it's properties
	[[[Director sharedDirector] openGLView] setMultipleTouchEnabled:YES];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// load the options
	options = [[Options alloc] init];
	
	// initialize the music
	NSString *path = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"];
	music = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
	music.delegate = self;
	music.numberOfLoops = -1;
	
	// set default type of blocks to both
	typeOfBlocks = TypeOfBlocksBoth;
	
	// go to the menu
	[window makeKeyAndVisible];
	[[Director sharedDirector] runWithScene: [MainMenu scene]];
}

- (void) dealloc {
	[music release];
	[options release];
	[window release];
	[super dealloc];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application {
	[[Director sharedDirector] resume];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	NSLog(@"applicationDidReceiveMemoryWarning");
	//[[TextureMgr sharedTextureMgr] removeAllTextures];
	
	/*// delete the sounds
	NSEnumerator* enumerator = [sounds objectEnumerator];
	AVAudioPlayer* value;
	while((value = [enumerator nextObject])) {
		[value release];
	}
	[sounds removeAllObjects];*/
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[player release];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	[player pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
	[player play];
}

@end
