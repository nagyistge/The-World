//
//  AStarPathMaker.m
//  TileGame
//
//  Created by EFB on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AStarPathMaker.h"

/****************** PathFindNode <--- Object that holds node information (cost, x, y, etc.) */
@implementation PathFindNode
+ (id)node {
	return [[[PathFindNode alloc] init] autorelease];
}
@end
/*********************************************************************************/

@implementation AStarPathMaker


- (void) dealloc {
	[blockingLayer release];
	[tileMap release];
	[super dealloc];
}


- (BOOL)spaceIsBlocked:(int)x :(int)y; {
	int tileGid = [blockingLayer tileGIDAt:CGPointMake(x,y)];
	if (tileGid) {
    NSDictionary *properties = [tileMap propertiesForGID:tileGid];
    if (properties) {
			NSString *collision = [properties valueForKey:@"Collidable"];
			if (collision && [collision compare:@"True"] == NSOrderedSame) {
				return YES;
			}
    }
	}
	return NO;
}


- (PathFindNode*)nodeInArray:(NSMutableArray*)a withX:(int)x Y:(int)y {
	//Quickie method to find a given node in the array with a specific x,y value
	NSEnumerator *e = [a objectEnumerator];
	PathFindNode *n;
	if(e) {
		while((n = [e nextObject])) {
			if((n->nodeX == x) && (n->nodeY == y)) {
				return n;
			}
		}
	}
	return nil;
}


- (PathFindNode*)lowestCostNodeInArray:(NSMutableArray*)a {
	//Finds the node in a given array which has the lowest cost
	PathFindNode *n, *lowest;
	lowest = nil;
	NSEnumerator *e = [a objectEnumerator];
	if(e) {
		while((n = [e nextObject])) {
			if (lowest == nil) {
				lowest = n;
			} else {
				if (n->cost < lowest->cost) {
					lowest = n;
				}
			}
		}
		return lowest;
	}
	return nil;
}


- (NSArray*)findPath:(int)startX :(int)startY :(int)endX :(int)endY {
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
	int x,y;
	int newX,newY;
	int currentX,currentY;
	NSMutableArray *openList, *closedList;
	
	if((startX == endX) && (startY == endY))
		return nil;
	
	openList = [NSMutableArray array];
	pointerToOpenList = openList;
	closedList = [NSMutableArray array];
	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	PathFindNode *startNode = [PathFindNode node];
	startNode->nodeX = startX;
	startNode->nodeY = startY;
	startNode->parentNode = nil;
	startNode->cost = 0;
	[openList addObject: startNode];
	
	while ([openList count]) {
		currentNode = [self lowestCostNodeInArray: openList];
		
		if ((currentNode->nodeX == endX) && (currentNode->nodeY == endY)) {
			//********** PATH FOUND ********************				
			aNode = currentNode->parentNode;
			NSMutableArray *nodes = [NSMutableArray array];
			while(aNode->parentNode != nil) {
				[nodes addObject:aNode];
				aNode = aNode->parentNode;
			}
			return nodes;
			//*****************************************//
		} else {
			[closedList addObject: currentNode];
			[openList removeObject: currentNode];
			currentX = currentNode->nodeX;
			currentY = currentNode->nodeY;
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++)
			{
				newY = currentY+y;
				for(x=-1;x<=1;x++)
				{
					newX = currentX+x;
					if(y || x)
					{
						//simple bounds check for the demo app's array
						if((newX>=0)&&(newY>=0)&&(newX<32)&&(newY<24))
						{
							if(![self nodeInArray: openList withX: newX Y:newY])
							{
								if(![self nodeInArray: closedList withX: newX Y:newY])
								{
									if(![self spaceIsBlocked: newX :newY])
									{
										aNode = [PathFindNode node];
										aNode->nodeX = newX;
										aNode->nodeY = newY;
										aNode->parentNode = currentNode;
										aNode->cost = currentNode->cost + 1;
										
										//Compute your cost here. This demo app uses a simple manhattan
										//distance, added to the existing cost
										aNode->cost += (abs((newX) - endX) + abs((newY) - endY));
										
										[openList addObject: aNode];
									}
								}
							}
						}
					}
				}
			}
		}		
	}
	//**** NO PATH FOUND *****
	return nil;
}


- (id) initWithBlockingLayer:(CCTMXLayer*)layer forMap:(CCTMXTiledMap*)map {
	self = [super init];
	blockingLayer = [layer retain];
	tileMap = [map retain];
	pointerToOpenList = nil;
	return self;
}



@end
