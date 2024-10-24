//  Created by Dominik Hauser on 03.05.24.
//  
//


#import "DDHNodesCreator.h"
#import <SceneKit/SceneKit.h>
#import "DDHBirthday.h"
#import "UIImage+Extenstion.h"
#import "DDHSceneMonth.h"

const CGFloat sunRadius = 695700;
const CGFloat earthRadius = 6378;
const CGFloat earthOrbit = 149598022;
const CGFloat orbitScaleFactor = 1.0/6790562;
const CGFloat scaledEarthPathRadius = earthOrbit * orbitScaleFactor;

@implementation DDHNodesCreator

- (instancetype)init {
  if (self = [super init]) {
    _sun = [self sun];
    _earthPath = [self earthPath];

  }
  return self;
}

- (SCNNode *)sun {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  material.diffuse.contents = [UIImage imageNamed:@"2k_sun"];
  material.multiply.contents = [UIColor whiteColor];

  SCNSphere *sphere = [SCNSphere sphereWithRadius:sunRadius * orbitScaleFactor];
  sphere.materials = @[material];

  SCNNode *node = [SCNNode nodeWithGeometry:sphere];
  node.position = SCNVector3Make(0, 0, 0);
  node.categoryBitMask = 1 << 1;

  return node;
}

//+ (SCNNode *)earth {
//  SCNMaterial *material = [[SCNMaterial alloc] init];
//  material.diffuse.contents = [UIImage imageNamed:@"2k_earth_daymap"];
//
//  SCNSphere *sphere = [SCNSphere sphereWithRadius:[self earthRadius] * [self orbitScaleFactor]];
//  sphere.materials = @[material];
//
//  SCNNode *node = [SCNNode nodeWithGeometry:sphere];
//  node.position = SCNVector3Make(0, 0, [self scaledEarthPathRadius]);
//
//  return node;
//}

- (SCNNode *)earthPath {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  material.diffuse.contents = [UIColor colorWithWhite:0.8 alpha:1];

  SCNTorus *torus = [SCNTorus torusWithRingRadius:scaledEarthPathRadius pipeRadius:0.005];
  torus.ringSegmentCount = 200;
  torus.materials = @[material];

  return [SCNNode nodeWithGeometry:torus];
}

- (SCNNode *)cameraOrbit:(SCNVector3)cameraPosition verticalCameraAngle:(CGFloat)verticalCameraAngle {
  SCNNode *cameraOrbit = [[SCNNode alloc] init];

  SCNNode *cameraNode = [[SCNNode alloc] init];
  cameraNode.camera = [[SCNCamera alloc] init];
//  cameraNode.camera.zFar = 100;
  cameraNode.camera.zNear = 0.1;
  cameraNode.eulerAngles = SCNVector3Make(verticalCameraAngle, 0, 0);
  cameraNode.position = cameraPosition;

  [cameraOrbit addChildNode:cameraNode];

  return cameraOrbit;
}

- (SCNNode *)directionalLightNode {
  SCNNode *lightNode = [[SCNNode alloc] init];
  lightNode.light = [[SCNLight alloc] init];
  lightNode.light.type = SCNLightTypeDirectional;
  lightNode.light.intensity = 20000;
  lightNode.light.temperature = 10000;
  lightNode.light.categoryBitMask = 1 << 1;
  lightNode.position = SCNVector3Make(0, 0, 10);
  return lightNode;
}

- (SCNNode *)ambientLightNode {
  SCNNode *ambientLightNode = [[SCNNode alloc] init];
  ambientLightNode.light = [[SCNLight alloc] init];
  ambientLightNode.light.type = SCNLightTypeAmbient;
  ambientLightNode.light.intensity = 1000;
  ambientLightNode.light.temperature = 6000;
  return ambientLightNode;
}

- (SCNNode *)birthdayHostNodeForDaysLeft:(NSInteger)daysLeft numberOfDaysInYear:(NSInteger)numberOfDaysInYear eulerAngles:(SCNVector3)eulerAngles {
  SCNMaterial *dotMaterial = [[SCNMaterial alloc] init];
  dotMaterial.diffuse.contents = [UIColor whiteColor];

  SCNSphere *sphere = [SCNSphere sphereWithRadius:0.3];
  sphere.materials = @[dotMaterial];

  SCNNode *dotNode = [SCNNode nodeWithGeometry:sphere];
  dotNode.name = [NSString stringWithFormat:@"%ld", daysLeft];

  CGFloat angle = 360.0/numberOfDaysInYear * daysLeft;
  CGFloat z = scaledEarthPathRadius * cos(angle * M_PI / 180.0);
  CGFloat x = scaledEarthPathRadius * sin(angle * M_PI / 180.0);
  dotNode.position = SCNVector3Make(x, 0, z);

  dotNode.eulerAngles = eulerAngles;

  return dotNode;
}

- (SCNNode *)addBirthdayNodeForBirthday:(DDHBirthday *)birthday toNode:(SCNNode *)node {
  SCNNode *birthdayNode = [self birthdayIndicatorForBirthday:birthday];
  [node addChildNode:birthdayNode];
  [self positionChildNodesInNode:node];
  return birthdayNode;
}

- (void)positionChildNodesInNode:(SCNNode *)node {
  CGFloat zPosFactor = -0.001;
  NSInteger numberOfChilds = [node.childNodes count];
  CGFloat radius;
  if (numberOfChilds < 2) {
    radius = [self birthdayIndicatorWidth]/2;
  } else {
    radius = [self birthdayIndicatorWidth]/4;
  }
  [node.childNodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull childNode, NSUInteger idx, BOOL * _Nonnull stop) {
    if (numberOfChilds < 2) {
      ((SCNPlane*)childNode.geometry).width = [self birthdayIndicatorWidth];
      ((SCNPlane*)childNode.geometry).height = [self birthdayIndicatorWidth];
    } else {
      ((SCNPlane*)childNode.geometry).width = [self birthdayIndicatorWidth]/2;
      ((SCNPlane*)childNode.geometry).height = [self birthdayIndicatorWidth]/2;
    }
    CGFloat angle = 360.0/numberOfChilds * idx + 180;
    CGFloat x = radius * sin(angle * M_PI / 180.0);
    CGFloat y = radius * cos(angle * M_PI / 180.0);
    childNode.position = SCNVector3Make(x, y + 2 * radius + 0.4, zPosFactor * idx);
  }];
}

- (CGFloat)birthdayIndicatorWidth {
  return 6;
}

- (SCNNode *)birthdayIndicatorForBirthday:(DDHBirthday *)birthday {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  UIImage *image = [UIImage imageWithData:birthday.imageData];
  UIImage *roundedImage = [image roundedWithColor:[UIColor whiteColor] width:10 targetSize:CGSizeMake(500, 500)];
  material.diffuse.contents = roundedImage;

  SCNPlane *plane = [SCNPlane planeWithWidth:[self birthdayIndicatorWidth]/2 height:[self birthdayIndicatorWidth]/2];
  plane.cornerRadius = [self birthdayIndicatorWidth]/4;
  plane.materials = @[material];

  SCNNode *node = [SCNNode nodeWithGeometry:plane];
//  CGFloat zPosFactor = -0.001;
//  node.position = SCNVector3Make(0, [self birthdayIndicatorWidth]/2 + 0.4, zPosFactor * index);
  node.categoryBitMask = 1 << 0;

  SCNMaterial *textMaterial = [[SCNMaterial alloc] init];
  textMaterial.diffuse.contents = [UIColor systemGrayColor];

  SCNText *text = [SCNText textWithString:[NSString stringWithFormat:@"%@", birthday.personNameComponents.givenName] extrusionDepth:0.1];
  text.materials = @[textMaterial];
  text.font = [UIFont boldSystemFontOfSize:0.6];
  text.chamferRadius = 0.02;

  SCNNode *textNode = [SCNNode nodeWithGeometry:text];
  textNode.position = SCNVector3Make(0, -[self birthdayIndicatorWidth]/2 - 1.1 , 0);
  [self center:textNode];

  [node addChildNode:textNode];

  return node;
}

- (NSArray<SCNNode *> *)significantIntervalsIndicatorNodesWithNumberOfDaysInYear:(NSInteger)numberOfDaysInYear {
  SCNMaterial *dotMaterial = [[SCNMaterial alloc] init];
  dotMaterial.diffuse.contents = [UIColor redColor];

  SCNSphere *sphere = [SCNSphere sphereWithRadius:0.1];
  sphere.materials = @[dotMaterial];

  NSMutableArray<SCNNode *> *nodes = [[NSMutableArray alloc] init];
  [@[@7, @14, @22, @52, @100] enumerateObjectsUsingBlock:^(id  _Nonnull daysLeft, NSUInteger idx, BOOL * _Nonnull stop) {
    SCNNode *dotNode = [SCNNode nodeWithGeometry:sphere];

    CGFloat angle = 360.0/numberOfDaysInYear * [daysLeft integerValue];
    CGFloat z = scaledEarthPathRadius * cos(angle * M_PI / 180.0);
    CGFloat x = scaledEarthPathRadius * sin(angle * M_PI / 180.0);
    dotNode.position = SCNVector3Make(x, 0, z);

    SCNText *text = [SCNText textWithString:[NSString stringWithFormat:@"%@", daysLeft] extrusionDepth:0.01];
    text.materials = @[dotMaterial];
    text.font = [UIFont systemFontOfSize:1];

    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    textNode.position = SCNVector3Make(0, -1, 0);
    [self center:textNode];

    [dotNode addChildNode:textNode];

    [nodes addObject:dotNode];
  }];

  return [nodes copy];
}

- (void)center:(SCNNode *)node {
  SCNVector3 min;
  SCNVector3 max;

  [node getBoundingBoxMin:&min max:&max];

  float translationX = (max.x + min.x) * 0.5;
  float translationY = (max.y + min.y) * 0.5;

  [node setPivot:SCNMatrix4MakeTranslation(translationX, translationY, 0)];
}

- (NSArray<SCNNode *> *)monthNodesWithNumberOfDaysInYear:(NSInteger)numberOfDaysInYear sceneMonth:(NSArray<DDHSceneMonth *> *)sceneMonths {

  NSMutableArray<SCNNode *> *nodes = [[NSMutableArray alloc] initWithCapacity:[sceneMonths count]];
  [sceneMonths enumerateObjectsUsingBlock:^(DDHSceneMonth * _Nonnull sceneMonth, NSUInteger idx, BOOL * _Nonnull stop) {
//    UIBezierPath *path = [[UIBezierPath alloc] init];

    CGFloat angle1 = 360.0/numberOfDaysInYear * sceneMonth.start;
    CGFloat z1 = scaledEarthPathRadius * cos(angle1 * M_PI / 180.0);
    CGFloat x1 = scaledEarthPathRadius * sin(angle1 * M_PI / 180.0);

//    [path moveToPoint:CGPointZero];
//    [path addLineToPoint:CGPointMake(x1, z1)];
//
//    CGFloat angle2 = 360.0/numberOfDaysInYear * sceneMonth.end;
//    CGFloat z2 = [self scaledEarthPathRadius] * cos(angle2 * M_PI / 180.0);
//    CGFloat x2 = [self scaledEarthPathRadius] * sin(angle2 * M_PI / 180.0);
//
//    [path addLineToPoint:CGPointMake(x2, z2)];
//
//    SCNShape *shape = [SCNShape shapeWithPath:path extrusionDepth:0.01];
//
//    SCNMaterial *material = [[SCNMaterial alloc] init];
//    material.diffuse.contents = [[UIColor systemGray6Color] colorWithAlphaComponent:0.4];
//
//    shape.materials = @[material];
//
//    SCNNode *node = [SCNNode nodeWithGeometry:shape];

    SCNMaterial *dotMaterial = [[SCNMaterial alloc] init];
    dotMaterial.diffuse.contents = [UIColor systemOrangeColor];

    SCNSphere *sphere = [SCNSphere sphereWithRadius:0.1];
    sphere.materials = @[dotMaterial];

    SCNNode *dotNode = [SCNNode nodeWithGeometry:sphere];

//    CGFloat z = [self scaledEarthPathRadius] * cos(angle1 * M_PI / 180.0);
//    CGFloat x = [self scaledEarthPathRadius] * sin(angle1 * M_PI / 180.0);
    dotNode.position = SCNVector3Make(x1, 0, z1);

//    [node addChildNode:dotNode];


    SCNMaterial *textMaterial = [[SCNMaterial alloc] init];
    textMaterial.diffuse.contents = [UIColor systemOrangeColor];

    SCNText *text = [SCNText textWithString:[NSString stringWithFormat:@"%@", sceneMonth.name] extrusionDepth:0.01];
    text.materials = @[textMaterial];
    text.font = [UIFont systemFontOfSize:1.5];

    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    CGFloat angle2 = 360.0/numberOfDaysInYear * (sceneMonth.start + sceneMonth.end) / 2.0;
    CGFloat z2 = scaledEarthPathRadius * 1.13 * cos(angle2 * M_PI / 180.0);
    CGFloat x2 = scaledEarthPathRadius * 1.13 * sin(angle2 * M_PI / 180.0);
    textNode.position = SCNVector3Make(x2, 0, z2);
    [self center:textNode];

//    [node addChildNode:textNode];

//    node.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);
    textNode.eulerAngles = SCNVector3Make(-M_PI_2, angle2 * M_PI / 180.0, 0);
//    dotNode.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);

    [nodes addObject:textNode];
    [nodes addObject:dotNode];
  }];

  return nodes;
}

@end
