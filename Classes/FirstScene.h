
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class PlayerCharacter;
// FirstScene Layer
@interface FirstScene : CCLayer {
	
	CCTMXTiledMap *_tileMap;
	CCTMXLayer *_background;
	CCTMXLayer *_foreground;
	CCTMXLayer *_meta;
	CCSprite *_player;

	PlayerCharacter *playerCharacter;	
	CGPoint lastPoint;
}

@property (nonatomic, retain) CCTMXLayer *foreground;
@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCSprite *player;

// returns a Scene that contains the FirstScene as the only child
+ (id) scene;

@end
