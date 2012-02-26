//
//  Options.h
//  AlphabetBlocks
//
//  Created by micah on 9/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Options : NSObject {
	NSArray* options;
	BOOL musicEnabled;
}

@property (nonatomic,retain) NSArray* options;
@property (readwrite) BOOL musicEnabled;

- (NSString*)getFilePath;
- (void) load;
- (void) save;

@end
