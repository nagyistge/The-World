//
//  PlayerCharacter.m
//  TileGame
//
//  Created by EFB on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlayerCharacter.h"


@implementation PlayerCharacter
@synthesize tools, resources;

- (void) dealloc {
	[resources release];
  [tools release];
	[super dealloc];
}


- (id) init {
	self = [super init];
	self.tools = [NSMutableArray array];
	self.resources = [NSMutableArray array];
  return self;
}

@end
