//
//  Menu.m
//  AlphabetBlocks
//
//  Created by micah on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlphabetBlocksAppDelegate.h"
#import "MainMenu.h"
#import "BlockLayer.h"

@implementation MainMenu

+ (id) scene {
	Scene* scene = [Scene node];
	MainMenu* layer = [MainMenu node];
	[scene addChild:layer];
	return scene;
}

- (id) init {
	if((self = [super init])) {
		NSLog(@"MainMenu init");
		
		// set the app delegate
		appDelegate = (AlphabetBlocksAppDelegate*)[UIApplication sharedApplication].delegate;
		
		// enable touch events
		self.isTouchEnabled = YES;
		
		// add the background
		Sprite* background = [Sprite spriteWithFile:@"menu.png"];
		background.position = ccp(240,160);
		[self addChild:background z:0];
		
		// add the moving title
		AtlasSpriteManager* title = [AtlasSpriteManager spriteManagerWithFile:@"blocks.png"];
		[self addChild:title z:1];
		
		// abc
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(0, 0, 100, 100) spriteManager:title] z:0];
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(100, 0, 100, 100) spriteManager:title] z:0];
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(200, 0, 100, 100) spriteManager:title] z:0];
		
		// 123
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(200, 300, 100, 100) spriteManager:title] z:0];
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(300, 300, 100, 100) spriteManager:title] z:0];
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(400, 300, 100, 100) spriteManager:title] z:0];
		
		// all mixed up
		int rand, x, y;
		rand = arc4random() % 26; x = rand % 8; y = rand / 8;
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(100*x, 100*y, 100, 100) spriteManager:title] z:0];
		rand = arc4random() % 9 + 26; x = rand % 8; y = rand / 8;
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(100*x, 100*y, 100, 100) spriteManager:title] z:0];
		rand = arc4random() % 26; x = rand % 8; y = rand / 8;
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(100*x, 100*y, 100, 100) spriteManager:title] z:0];
		rand = arc4random() % 9 + 26; x = rand % 8; y = rand / 8;
		[title addChild:[AtlasSprite spriteWithRect:CGRectMake(100*x, 100*y, 100, 100) spriteManager:title] z:0];
		
		// initialize them
		AtlasSprite* block;
		NSArray* blocks = [title children];
		for(int i=0; i<[blocks count]; i++) {
			block = [blocks objectAtIndex:i];
			block.scale = 0.6;
			block.rotation = -10;
			[block runAction:[RepeatForever actionWithAction:
							  [Sequence actions:
							   [RotateBy actionWithDuration:1.0 angle:20], 
							   [RotateBy actionWithDuration:1.0 angle:-20], 
							   nil]]];
			if(i >= 0 && i < 3) // abc
				block.position = CGPointMake(50+i*70, 264);
			else if(i >= 3 && i < 6) // 123
				block.position = CGPointMake(290+(i-3)*70, 264);
			else
				block.position = CGPointMake(217+(i-6)*70, 112);
		}
		
		// if music is enabled
		CGRect musicRect;
		if(appDelegate.options.musicEnabled) {
			// start music
			[appDelegate.music play];
			musicRect = CGRectMake(0, 0, 85, 85);
		} else {
			musicRect = CGRectMake(85, 0, 85, 85);
		}
		
		// music button
		AtlasSpriteManager* musicButtonMng = [AtlasSpriteManager spriteManagerWithFile:@"music_button.png"];
		[self addChild:musicButtonMng z:1 tag:tagMusicButton];
		AtlasSprite* musicButton = [AtlasSprite spriteWithRect:musicRect spriteManager:musicButtonMng];
		musicButton.position = ccp(68, 79);
		[musicButton runAction:[RepeatForever actionWithAction:
						  [Sequence actions:
						   [RotateBy actionWithDuration:1.0 angle:20], 
						   [RotateBy actionWithDuration:1.0 angle:-20], 
						   nil]]];
		[musicButtonMng addChild:musicButton];
	}
	return self;
}

- (BOOL) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	if(touch) {
		CGPoint touchPoint = [touch locationInView: [touch view]];
		CGPoint location = [[Director sharedDirector] convertCoordinate:touchPoint];
		CGRect rect;
		
		
		// letters
		rect = CGRectMake(0, 160, 240, 160);
		if(CGRectContainsPoint(rect, location)) {
			[self onLetters];
			return kEventHandled;
		}
		
		// numbers
		rect = CGRectMake(240, 160, 240, 160);
		if(CGRectContainsPoint(rect, location)) {
			[self onNumbers];
			return kEventHandled;
		}
		
		// all mixed up
		rect = CGRectMake(160, 0, 320, 160);
		if(CGRectContainsPoint(rect, location)) {
			[self onBoth];
			return kEventHandled;
		}
		
		// music
		rect = CGRectMake(25, 36, 85, 85);
		if(CGRectContainsPoint(rect, location)) {
			[self onMusic];
			return kEventHandled;
		}
	}
	
	// we ignore the event
	return kEventIgnored;
}

- (void) onLetters {
	NSLog(@"Letters selected");
	appDelegate.typeOfBlocks = TypeOfBlocksLetter;
	[[Director sharedDirector] replaceScene:[FlipYTransition transitionWithDuration:0.5 scene:[BlockLayer scene]]];
}

- (void) onNumbers {
	NSLog(@"Numbers selected");
	appDelegate.typeOfBlocks = TypeOfBlocksNumbers;
	[[Director sharedDirector] replaceScene:[FlipYTransition transitionWithDuration:0.5 scene:[BlockLayer scene]]];
}

- (void) onBoth {
	NSLog(@"All Mixed Up selected");
	appDelegate.typeOfBlocks = TypeOfBlocksBoth;
	[[Director sharedDirector] replaceScene:[FlipYTransition transitionWithDuration:0.5 scene:[BlockLayer scene]]];
}

- (void) onMusic {
	NSLog(@"Music selected");
	
	CGRect musicRect;
	AtlasSpriteManager* musicButtonMng = (AtlasSpriteManager*)[self getChildByTag:tagMusicButton];
	AtlasSprite* musicButton = [[musicButtonMng children] objectAtIndex:0];
	
	if(appDelegate.options.musicEnabled == YES) {
		// disable music
		musicRect = CGRectMake(85, 0, 85, 85);
		[musicButton setTextureRect:musicRect];
		[appDelegate.music stop];
		
		// save options
		appDelegate.options.musicEnabled = NO;
		[appDelegate.options save];
	} else {
		// enable music
		musicRect = CGRectMake(0, 0, 85, 85);
		[musicButton setTextureRect:musicRect];
		[appDelegate.music play];
		
		// save options
		appDelegate.options.musicEnabled = YES;
		[appDelegate.options save];
	}
}

- (void) dealloc {
	NSLog(@"MainMenu dealloc");
	[super dealloc];
}


@end
