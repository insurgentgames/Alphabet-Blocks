//
//  Options.m
//  AlphabetBlocks
//
//  Created by micah on 9/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Options.h"

@implementation Options

@synthesize options;
@synthesize musicEnabled;

- (id) init {
	if((self = [super init])) {
		NSLog(@"Options init");
		[self load];
	}
	return self;
}

- (void) dealloc {
	NSLog(@"Options dealloc");
	[super dealloc];
}

- (NSString*)getFilePath {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"Options.plist"];
}

- (void) load {
	if([[NSFileManager defaultManager] fileExistsAtPath:[self getFilePath]]) {
		NSLog(@"Loading options");
		options = [NSArray arrayWithContentsOfFile:[self getFilePath]];
		musicEnabled = [[options objectAtIndex:0] boolValue];
	} else {
		NSLog(@"Create new options files");
		options = [NSArray arrayWithObject:[NSNumber numberWithBool:YES]];
		musicEnabled = YES;
		[self save];
	}
}

- (void) save {
	NSLog(@"Saving options");
	options = [NSArray arrayWithObject:[NSNumber numberWithBool:musicEnabled]];
	[options writeToFile:[self getFilePath] atomically:YES];
}

@end
