//
//  AStarPathMaker.h
//  TileGame
//
//  Created by EFB on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

/****************** PathFindNode <--- Object that holds node information (cost, x, y, etc.) */
/*********************************************************************************/
@interface PathFindNode : NSObject {
@public
	int nodeX,nodeY;
	int cost;
	PathFindNode *parentNode;
}
+ (id)node;
@end


@interface AStarPathMaker : NSObject {
	
	NSMutableArray *pointerToOpenList;
	CCTMXTiledMap *tileMap;
  CCTMXLayer *blockingLayer;

}

- (id) initWithBlockingLayer:(CCTMXLayer*)layer forMap:(CCTMXTiledMap*)map;
- (NSArray*)findPath:(int)startX :(int)startY :(int)endX :(int)endY;


@end
