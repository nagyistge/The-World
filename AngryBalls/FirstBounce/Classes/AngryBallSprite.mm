//
//  AngryBallBaseObject.m
//  FirstBounce
//
//  Created by Anna Hentzel on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AngryBallSprite.h"



@implementation AngryBallSprite
@synthesize body, inPlay;


- (id) initWithDictionary:(NSDictionary*) dict andWorld:(b2World*) world {
  NSString * type = [dict objectForKey:@"type"];
  NSString * filePath;
  bool inPlay = NO;
  if ([type isEqualToString:@"main"]) {
    filePath = @"mediumball.png";
    inPlay = YES;
  } else if ([type isEqualToString:@"disappear"]) {
    filePath = @"greenandwhiteball.jpeg";
  } else {
    filePath = @"seeker.png";
  }
  int x = [[dict objectForKey:@"x"] intValue];
  int y = [[dict objectForKey:@"y"] intValue];
  
  self = [super initWithFile:filePath];
  self.inPlay = inPlay;
  self.position = CGPointMake(x, y);
  CGPoint p = self.position;
  int width = [self boundingBox].size.width/2;

  NSLog(@"width %d", width);
  
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
  bodyDef.linearDamping = 0.4f;
  bodyDef.angularDamping = 0.4f;
  
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = self;
	body = world->CreateBody(&bodyDef);
	
  b2CircleShape circle;
  circle.m_radius = width/(float)PTM_RATIO;
  
  b2FixtureDef ballShapeDef;
  ballShapeDef.shape = &circle;
  ballShapeDef.density = 1.0;
  ballShapeDef.friction = 0.6f;
  ballShapeDef.restitution = 0.6f;
  body->CreateFixture(&ballShapeDef);
  
  return self;
  
  
}

- (void) dealloc {
  //delete body;
  [super dealloc];
  
}

@end
