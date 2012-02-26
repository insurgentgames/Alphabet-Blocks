//
//  BlockLayer.h
//  AlphabetBlocks
//
//  Created by micah on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AlphabetBlocksAppDelegate.h"
#import "cocos2d.h"
#import "Box2D.h"

#define tagTap 50

@interface BlockLayer : Layer {
	AlphabetBlocksAppDelegate* appDelegate;
	b2World* world;
	b2Body* body;
	BOOL tapped;
	
	NSInteger previousBlock;
	BOOL canAddNewBlock;
}
+ (id) scene;
- (id) init;
- (void) addNewSpriteWithCoords:(CGPoint)p;
- (void) playSound:(NSUInteger)letter;
- (void) resetCanAddNewBlock:(id)sender;
@end
