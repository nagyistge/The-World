//
//  HelloWorldScene.h
//  FirstBounce
//
//  Created by Anna Hentzel on 3/20/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#define PTM_RATIO 32

@class AngryBallSprite;
// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
  AngryBallSprite * mainBall;
}

@property (nonatomic, retain) AngryBallSprite * mainBall;
// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

// adds a new sprite at a given coordinate
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(b2Body*) spriteWithFile:(NSString*)filePath andPoint:(CGPoint)p;

@end
