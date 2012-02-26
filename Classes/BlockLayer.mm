//
//  BlockLayer.m
//  AlphabetBlocks
//
//  Created by micah on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BlockLayer.h"
#import "AlphabetBlocksAppDelegate.h"
#import "MainMenu.h"

@implementation BlockLayer

// Pixel to metres ratio. Box2D uses metres as the unit for measurement.
// This ratio defines how many pixels correspond to 1 Box2D "metre"
// Box2D is optimized for objects of 1x1 metre therefore it makes sense
// to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

enum {
	kTagTileMap = 1,
	kTagSpriteManager = 1,
	kTagAnimation1 = 1,
};

+ (id) scene {
	Scene* scene = [Scene node];
	BlockLayer* layer = [BlockLayer node];
	[scene addChild:layer];
	return scene;
}

- (id) init {
	if((self = [super init])) {
		CGSize screenSize = [Director sharedDirector].winSize;
		NSLog(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// set up world bounds - this should be larger than screen as any body that reaches
		// the boundary will be frozen
		b2AABB worldAABB;
		float borderSize = 192 / PTM_RATIO; //We want a 192 pixel border between the screen and the world bounds
		worldAABB.lowerBound.Set(-borderSize, -borderSize);//Bottom left
		worldAABB.upperBound.Set(screenSize.width/PTM_RATIO + borderSize, screenSize.height/PTM_RATIO + borderSize);//Top right
		
		b2Vec2 gravity(0.0f, -30.0f);//Set up gravity
		bool doSleep = true;
		
		world = new b2World(worldAABB, gravity, doSleep);
		
		// set up ground
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(screenSize.width/PTM_RATIO/2, -1.0f); // this is a mid point, hence the /2
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		b2PolygonDef groundShapeDef;
		groundShapeDef.SetAsBox(screenSize.width/PTM_RATIO/2, 1.0f); // this is a mid point, hence the /2
		groundBody->CreateShape(&groundShapeDef);
		
		// set up roof
		b2BodyDef roofBodyDef;
		roofBodyDef.position.Set(screenSize.width/PTM_RATIO/2, 11.0f); // this is a mid point, hence the /2
		b2Body* roofBody = world->CreateBody(&roofBodyDef);
		b2PolygonDef roofShapeDef;
		roofShapeDef.SetAsBox(screenSize.width/PTM_RATIO/2, 1.0f); // this is a mid point, hence the /2
		roofBody->CreateShape(&roofShapeDef);
		
		[self schedule: @selector(tick:)];
		
		// set up sprite
		AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"blocks.png" capacity:150];
		[self addChild:mgr z:0 tag:kTagSpriteManager];
		
		// add the background
		Sprite* bg = [Sprite spriteWithFile:@"background.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:-2];
		
		// add the tap
		tapped = NO;
		Sprite* tap = [Sprite spriteWithFile:@"tap.png"];
		tap.position = ccp(240, 160);
		[self addChild:tap z:1 tag:tagTap];
		
		// accept input
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		// set the previous block
		previousBlock = -1;
		canAddNewBlock = YES;
		[self schedule:@selector(resetCanAddNewBlock:) interval:0.1];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"BlockLayer dealloc");
	delete world;
	body = NULL;
	world = NULL;
	[super dealloc];
}	

#define HEAD_WIDTH 100
#define HEAD_HEIGHT 100

- (void) addNewSpriteWithCoords:(CGPoint)p {
	NSLog(@"Add sprite %0.2f x %02.f",p.x,p.y);
	AtlasSpriteManager *mgr = (AtlasSpriteManager*) [self getChildByTag:kTagSpriteManager];
	
	NSInteger block;
	AlphabetBlocksAppDelegate* d = (AlphabetBlocksAppDelegate*)[UIApplication sharedApplication].delegate;
	switch(d.typeOfBlocks) {
		case TypeOfBlocksLetter:
			// pick the next letter
			if(previousBlock == -1) {
				block = 0;
			} else {
				block = previousBlock + 1;
				if(block >= 26)
					block = 0;
			}
			break;
			
		case TypeOfBlocksNumbers:
			// pick the next number
			if(previousBlock == -1) {
				block = 26;
			} else {
				block = previousBlock + 1;
				if(block >= 35)
					block = 26;
			}
			
			break;
			
		case TypeOfBlocksBoth:
			// pick a random letter or number
			block = arc4random() % 35;
			break;
	}
	
	// play its sound
	[self playSound:block];
	
	// load the sprite
	int idx = block*HEAD_WIDTH % 800;
	int idy = (int)(block*HEAD_WIDTH / 800) * HEAD_HEIGHT;
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:CGRectMake(idx,idy,HEAD_WIDTH,HEAD_HEIGHT) spriteManager:mgr];
	[mgr addChild:sprite];
	sprite.position = ccp( p.x, p.y);
	
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	body = world->CreateBody(&bodyDef);
	b2PolygonDef shapeDef;
	shapeDef.SetAsBox(1.56f, 1.56f);//These are mid points for our 1m box
	shapeDef.density = 1.0f;
	shapeDef.friction = 0.3f;
	body->CreateShape(&shapeDef);
	body->SetMassFromShapes();
	
	previousBlock = block;
}

- (void) tick: (ccTime) dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	if(world != NULL) {
		world->Step(dt, 10, 8);//Step the physics world
		//Iterate over the bodies in the physics world
		for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
			if (b->GetUserData() != NULL) {
				//Synchronize the AtlasSprites position and rotation with the corresponding body
				AtlasSprite* myActor = (AtlasSprite*)b->GetUserData();
				myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
				myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
			}	
		}
	}
}

- (void) resetCanAddNewBlock:(id)sender {
	canAddNewBlock = YES;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(tapped == NO) {
		// make the tap fly off the screen
		Sprite* tap = (Sprite*)[self getChildByTag:tagTap];
		[tap runAction:[MoveTo actionWithDuration:1.0 position:CGPointMake(800,500)]];
		[tap runAction:[RotateBy actionWithDuration:1.0 angle:180]];
		tapped = YES;
		
		// add the back button too
		Sprite* back = [Sprite spriteWithFile:@"back.png"];
		back.position = ccp(50, 305);
		[self addChild:back z:10];
	}
	
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[Director sharedDirector] convertCoordinate: location];
	
	// back button?
	if(CGRectContainsPoint(CGRectMake(0, 290, 100, 30), location)) {
		[[Director sharedDirector] replaceScene:[FlipYTransition transitionWithDuration:0.5 scene:[MainMenu scene]]];
		return kEventHandled;
	}
	
	// add a block
	if(canAddNewBlock) {
		[self addNewSpriteWithCoords: location];
		canAddNewBlock = NO;
		return kEventHandled;
	}
	
	return kEventIgnored;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}

- (void) playSound:(NSUInteger)letter {
	NSUInteger rand = arc4random() % 2;
	NSString* name;
	if(rand == 0) { name = @"micah"; }
	else { name = @"crystal"; }
	
	NSString* filename = nil;
	if(letter == 0) filename = [NSString stringWithFormat:@"%@_a", name];
	if(letter == 1) filename = [NSString stringWithFormat:@"%@_b", name];
	if(letter == 2) filename = [NSString stringWithFormat:@"%@_c", name];
	if(letter == 3) filename = [NSString stringWithFormat:@"%@_d", name];
	if(letter == 4) filename = [NSString stringWithFormat:@"%@_e", name];
	if(letter == 5) filename = [NSString stringWithFormat:@"%@_f", name];
	if(letter == 6) filename = [NSString stringWithFormat:@"%@_g", name];
	if(letter == 7) filename = [NSString stringWithFormat:@"%@_h", name];
	if(letter == 8) filename = [NSString stringWithFormat:@"%@_i", name];
	if(letter == 9) filename = [NSString stringWithFormat:@"%@_j", name];
	if(letter == 10) filename = [NSString stringWithFormat:@"%@_k", name];
	if(letter == 11) filename = [NSString stringWithFormat:@"%@_l", name];
	if(letter == 12) filename = [NSString stringWithFormat:@"%@_m", name];
	if(letter == 13) filename = [NSString stringWithFormat:@"%@_n", name];
	if(letter == 14) filename = [NSString stringWithFormat:@"%@_o", name];
	if(letter == 15) filename = [NSString stringWithFormat:@"%@_p", name];
	if(letter == 16) filename = [NSString stringWithFormat:@"%@_q", name];
	if(letter == 17) filename = [NSString stringWithFormat:@"%@_r", name];
	if(letter == 18) filename = [NSString stringWithFormat:@"%@_s", name];
	if(letter == 19) filename = [NSString stringWithFormat:@"%@_t", name];
	if(letter == 20) filename = [NSString stringWithFormat:@"%@_u", name];
	if(letter == 21) filename = [NSString stringWithFormat:@"%@_v", name];
	if(letter == 22) filename = [NSString stringWithFormat:@"%@_w", name];
	if(letter == 23) filename = [NSString stringWithFormat:@"%@_x", name];
	if(letter == 24) filename = [NSString stringWithFormat:@"%@_y", name];
	if(letter == 25) filename = [NSString stringWithFormat:@"%@_z", name];
	if(letter == 26) filename = [NSString stringWithFormat:@"%@_1", name];
	if(letter == 27) filename = [NSString stringWithFormat:@"%@_2", name];
	if(letter == 28) filename = [NSString stringWithFormat:@"%@_3", name];
	if(letter == 29) filename = [NSString stringWithFormat:@"%@_4", name];
	if(letter == 30) filename = [NSString stringWithFormat:@"%@_5", name];
	if(letter == 31) filename = [NSString stringWithFormat:@"%@_6", name];
	if(letter == 32) filename = [NSString stringWithFormat:@"%@_7", name];
	if(letter == 33) filename = [NSString stringWithFormat:@"%@_8", name];
	if(letter == 34) filename = [NSString stringWithFormat:@"%@_9", name];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"mp3"];
	AVAudioPlayer* sound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
	sound.delegate = appDelegate;
	sound.volume = 1.0;
	[sound play];
}

@end
