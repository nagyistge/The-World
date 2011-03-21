//
//  PlayerCharacter.h
//  TileGame
//
//  Created by EFB on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PlayerCharacter : NSObject {

	NSMutableArray *tools, *resources;
	
}

@property(nonatomic, retain) NSMutableArray *tools, *resources;

@end
