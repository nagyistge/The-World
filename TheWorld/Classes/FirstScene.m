// The World - Game
//

#import "FirstScene.h"
#import "PlayerCharacter.h"
#import "AStarPathMaker.h"


@implementation FirstScene
@synthesize tileMap = _tileMap;
@synthesize foreground = _foreground, background = _background, meta = _meta;
@synthesize player = _player;


#pragma mark -
#pragma mark teardown and init methods

- (void) dealloc {
	self.tileMap = nil;
	self.background = nil;
	self.foreground = nil;
  self.meta = nil;	
	self.player = nil;    
	[playerCharacter release];
	[super dealloc];
}


+ (id) scene {
	CCScene *scene = [CCScene node];	
	FirstScene *layer = [FirstScene node];	
	[scene addChild:layer];
	return scene;
}


// init the home map, where the user will learn to collect things and make his house
- (id) init {
	if ( (self = [super init]) ) {
		self.isTouchEnabled = YES;
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap.tmx"];
		[self addChild:_tileMap z:-1];
		self.background = [_tileMap layerNamed:@"Background"];
		self.foreground = [_tileMap layerNamed:@"Foreground"];
		self.meta = [_tileMap layerNamed:@"Meta"];
		_meta.visible = NO;

		CCTMXObjectGroup *objects = [_tileMap objectGroupNamed:@"Objects"];
		NSAssert(objects != nil, @"'Objects' object group not found");
	
		NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];        
		NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
		int x = [[spawnPoint valueForKey:@"x"] intValue];
		int y = [[spawnPoint valueForKey:@"y"] intValue];
		self.player = [CCSprite spriteWithFile:@"Player.png"];
		_player.position = ccp(x, y);
		[self addChild:_player]; 
		
		playerCharacter = [[PlayerCharacter alloc]init];
	}
	return self;
}


# pragma mark -
# pragma mark resource/item collection methods
// these methods remove items and resources from the map,
// and add them to the character's stuff

// if the player has an axe, he can cut down trees he lands on
- (void)harvestWood:(CGPoint)tileCoord; {	
	if ([playerCharacter.tools containsObject:@"axe"]) {
		// harvest wood
		[playerCharacter.resources addObject:@"wood"];
		[_foreground removeTileAt:tileCoord];
	} else {
		UIAlertView *av = [[[UIAlertView alloc]initWithTitle:@"Need Axe" 
																								 message:@"You need an axe to harvest wood from trees" 
																								delegate:nil 
																			cancelButtonTitle:@"OK" 
																			 otherButtonTitles:nil]autorelease];
		[av show];
	}
}
	
	
// branches into a function for each kind of resource
- (void)harvestResource:(CGPoint)tileCoord; {	
	int tileGid = [_foreground tileGIDAt:tileCoord];
	if (tileGid) {
    NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
    if (properties) {
			NSString *resourceType = [properties valueForKey:@"resourceType"];
			if (resourceType && [resourceType compare:@"wood"] == NSOrderedSame) {
				[self harvestWood:tileCoord];
			}
    }
	}
}


// checks if a tile in the foreground is a resource tile
- (BOOL)spaceIsResource:(CGPoint)tileCoord; {	
	int tileGid = [_foreground tileGIDAt:tileCoord];
	if (tileGid) {
    NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
    if (properties) {
			NSString *isResource = [properties valueForKey:@"isResource"];
			if (isResource && [isResource compare:@"True"] == NSOrderedSame) {
				return YES;
			}
    }
	}
	return NO;	
}


// removes an items from the foreground map at tileCoord,
// and adds it to the players tools
- (void) collectItem:(CGPoint)tileCoord {
	int tileGid = [_foreground tileGIDAt:tileCoord];
	NSDictionary *properties = [_tileMap propertiesForGID:tileGid];	
	if (properties) {
		NSString *itemType = [properties valueForKey:@"itemType"];
		if (itemType) {
			[playerCharacter.tools addObject:itemType];
		}
  }
	[_foreground removeTileAt:tileCoord];
	[_meta removeTileAt:tileCoord];
}


// returns YES of the meta layer has a collectible (green) tile at this coordinate
- (BOOL) spaceIsCollectible:(CGPoint)tileCoord {
	int tileGid = [_meta tileGIDAt:tileCoord];
	NSDictionary *properties = [_tileMap propertiesForGID:tileGid];	
	if (properties) {
		NSString *isCollectible = [properties valueForKey:@"isCollectible"];
		if (isCollectible && [isCollectible compare:@"True"] == NSOrderedSame) {
			return YES;
		}
	}
	return NO;
}
		

# pragma mark -
# pragma mark collect things along A* strings of tiles

// the screen is 32x24 tiles, each tile is 32px square
// the screen is 1024x748 (or is that 768?)

// convert a tileCoord to a screen coord
- (CGPoint) positionForTileCoord:(CGPoint)tileCoord {
	return ccp(tileCoord.x*32+16, 748+tileCoord.y*-32);
}


// convert a screen coord to a tileCoord
- (CGPoint)tileCoordForPosition:(CGPoint)position {
	int x = position.x / _tileMap.tileSize.width;
	int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
	return ccp(x, y);
}


// whenever crossing a tile, the character harvests the resources
// and collects items on the tile
- (void) activateTileAtCoords:(CGPoint)tileCoord {
	if ([self spaceIsResource:tileCoord]) {
		[self harvestResource:tileCoord];
	}
	if ([self spaceIsCollectible:tileCoord]) {
		[self collectItem:tileCoord];
	}
}	


// find the tile from the sprite's position
// and do any actions for that tile
- (void) doActionAtSpritesLocation:(id)sender {
	CCSprite *sprite = (CCSprite *)sender;
	CGPoint position = sprite.position;
	CGPoint tileCoord = [self tileCoordForPosition:position];
	[self activateTileAtCoords:tileCoord];	
}


// each action gets pushed to the front of the list
// because it's a backwards A* list
- (void) addActionForPoint:(CGPoint)point toActionList:(NSMutableArray*)actions {
	id actionMove = [CCMoveTo actionWithDuration:.1 
																			position:point];
	id arriveMove = [CCCallFuncN actionWithTarget:self selector:@selector(doActionAtSpritesLocation:)];
	[actions insertObject:arriveMove atIndex:0];
	[actions insertObject:actionMove atIndex:0];
}	


// last action goes at end of list
- (void) addLastActionForPoint:(CGPoint)point toActionList:(NSMutableArray*)actions {
	id actionMove = [CCMoveTo actionWithDuration:.1 
																			position:point];
	id arriveMove = [CCCallFuncN actionWithTarget:self selector:@selector(doActionAtSpritesLocation:)];
	[actions addObject:actionMove];	
	[actions addObject:arriveMove];
}	


// return an action array that moves the sprite to each node
// and does any appropriate actions at each tile, such as collect resources
- (NSArray*) getActionArray:(NSArray*)nodes {
	
	NSMutableArray *actions = [NSMutableArray array];
	for (PathFindNode *node in nodes) {
		CGPoint tilePoint = {node->nodeX,node->nodeY};
		CGPoint point = [self positionForTileCoord:tilePoint];
		[self addActionForPoint:point toActionList:actions];
	}	

	// add the point that was last touched to the end of the list, with an action for that tile
	CGPoint point = [self positionForTileCoord:lastPoint];
	[self addLastActionForPoint:point toActionList:actions];
	
	return actions;
}	
	

// turns an action array into an action sequence - very exciting
- (CCFiniteTimeAction *) getActionSequence: (NSArray *) nodes {
	CCFiniteTimeAction *seq = nil;
	for (CCFiniteTimeAction *anAction in [self getActionArray:nodes]) {
		if (!seq) {
			seq = anAction;
		} else {
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}
	return seq;
}


// when the user touches the map, 
// move the character to thet place and do stuff along the path
- (void)doActionsAlongPath:(int)startX :(int)startY :(int)endX :(int)endY {
	
	// find the A* path
	AStarPathMaker *apm = [[[AStarPathMaker alloc]initWithBlockingLayer:_meta forMap:_tileMap]autorelease];
	NSArray *nodes = [apm findPath:startX :startY :endX :endY];
	if (!nodes) return;
	
	// walk the guy and do the actions
	CCFiniteTimeAction *seq = [self getActionSequence:nodes];
	[_player runAction:seq];
}


# pragma mark -
# pragma mark Cocos2D touch delegate methods

// on touch, use A* to move the character to the touched spot
- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint touchPosition = [touch locationInView: [touch view]];		
	touchPosition = [[CCDirector sharedDirector] convertToGL: touchPosition];
	lastPoint = [self tileCoordForPosition:[self convertToNodeSpace:touchPosition]];
	CGPoint playerPosition = [self tileCoordForPosition:_player.position];
	[self doActionsAlongPath: playerPosition.x :playerPosition.y :lastPoint.x :lastPoint.y];
}


// start listening for touches, using this self as the delegate
- (void) registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
																									 priority:0 
																						swallowsTouches:YES];
}


// returns YES to allow all touches
- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}


@end
