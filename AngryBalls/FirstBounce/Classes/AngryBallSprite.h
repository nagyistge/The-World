//
//  AngryBallBaseObject.h
//  FirstBounce
//
//  Created by Anna Hentzel on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

#define PTM_RATIO 32

@interface AngryBallSprite : CCSprite {
  b2Body* body;
  bool inPlay;
  

}

@property (nonatomic, assign) b2Body* body;
@property (nonatomic, assign) bool inPlay;

@end
