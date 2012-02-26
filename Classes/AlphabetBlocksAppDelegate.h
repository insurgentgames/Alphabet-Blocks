//
//  AlphabetBlocksAppDelegate.h
//  AlphabetBlocks
//
//  Created by micah on 8/16/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Options.h"

typedef enum {
	TypeOfBlocksLetter = 0,
	TypeOfBlocksNumbers = 1,
	TypeOfBlocksBoth = 2
} TypeOfBlocks;

@interface AlphabetBlocksAppDelegate : NSObject <UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate, AVAudioPlayerDelegate> {
    UIWindow* window;
	AVAudioPlayer* music;
	Options* options;
	TypeOfBlocks typeOfBlocks;
}
@property (nonatomic, retain) AVAudioPlayer* music;
@property (nonatomic, retain) Options* options;
@property (readwrite) TypeOfBlocks typeOfBlocks;
@end

