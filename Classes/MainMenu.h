//
//  Menu.h
//  AlphabetBlocks
//
//  Created by micah on 9/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Options.h"
#import "AlphabetBlocksAppDelegate.h"

#define tagMusicButton 100

@interface MainMenu : Layer {
	AlphabetBlocksAppDelegate* appDelegate;
}

+ (id) scene;
- (void) onLetters;
- (void) onNumbers;
- (void) onBoth;
- (void) onMusic;

@end
