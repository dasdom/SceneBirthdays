//  Created by Dominik Hauser on 03.05.24.
//  
//


#import "DDHNodesCreator.h"
#import <SceneKit/SceneKit.h>
#import "DDHBirthday.h"
#import "UIImage+Extenstion.h"

@implementation DDHNodesCreator

+ (CGFloat)sunRadius {
  return 695700;
}

+ (CGFloat)earthRadius {
  return 6378;
}

+ (CGFloat)earthOrbit {
  return 149598022;
}

+ (CGFloat)orbitScaleFactor {
  return 1.0/6790562;
}

+ (CGFloat)scaledEarthPathRadius {
  return [self earthOrbit] * [self orbitScaleFactor];
}

+ (SCNNode *)sun {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  material.diffuse.contents = [UIImage imageNamed:@"2k_sun"];

  SCNSphere *sphere = [SCNSphere sphereWithRadius:[self sunRadius] * [self orbitScaleFactor]];
  sphere.materials = @[material];

  SCNNode *node = [SCNNode nodeWithGeometry:sphere];
  node.position = SCNVector3Make(0, 0, 0);
  node.categoryBitMask = 1 << 1;

  return node;
}

+ (SCNNode *)earth {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  material.diffuse.contents = [UIImage imageNamed:@"2k_earth_daymap"];

  SCNSphere *sphere = [SCNSphere sphereWithRadius:[self earthRadius] * [self orbitScaleFactor]];
  sphere.materials = @[material];

  SCNNode *node = [SCNNode nodeWithGeometry:sphere];
  node.position = SCNVector3Make(0, 0, [self scaledEarthPathRadius]);

  return node;
}

+ (SCNNode *)earthPath {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  material.diffuse.contents = [UIColor colorWithWhite:0.8 alpha:1];

  SCNTorus *torus = [SCNTorus torusWithRingRadius:[self scaledEarthPathRadius] pipeRadius:0.01];
  torus.ringSegmentCount = 200;
  torus.materials = @[material];

  return [SCNNode nodeWithGeometry:torus];
}

+ (SCNNode *)cameraOrbit:(SCNVector3)cameraPosition verticalCameraAngle:(CGFloat)verticalCameraAngle {
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

+ (SCNNode *)directionalLightNode {
  SCNNode *lightNode = [[SCNNode alloc] init];
  lightNode.light = [[SCNLight alloc] init];
  lightNode.light.type = SCNLightTypeDirectional;
  lightNode.light.intensity = 20000;
  lightNode.light.temperature = 10000;
  lightNode.light.categoryBitMask = 1 << 1;
  lightNode.position = SCNVector3Make(0, 0, 10);
  return lightNode;
}

+ (SCNNode *)ambientLightNode {
  SCNNode *ambientLightNode = [[SCNNode alloc] init];
  ambientLightNode.light = [[SCNLight alloc] init];
  ambientLightNode.light.type = SCNLightTypeAmbient;
  ambientLightNode.light.intensity = 1000;
  ambientLightNode.light.temperature = 6000;
  return ambientLightNode;
}

+ (CGFloat)birthdayIndicatorWidth {
  return 10;
}

+ (SCNNode *)birthdayIndicatorForBirthday:(DDHBirthday *)birthday {
  SCNMaterial *material = [[SCNMaterial alloc] init];
  UIImage *image = [UIImage imageWithData:birthday.imageData];
  UIImage *roundedImage = [image roundedWithColor:[UIColor whiteColor] width:14 targetSize:CGSizeMake(500, 500)];
  material.diffuse.contents = roundedImage;

  SCNPlane *plane = [SCNPlane planeWithWidth:[self birthdayIndicatorWidth] height:[self birthdayIndicatorWidth]];
  plane.cornerRadius = [self birthdayIndicatorWidth]/2;
  plane.materials = @[material];

  SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
  planeNode.position = SCNVector3Make(0, [self birthdayIndicatorWidth]/2 + 0.4, 0);
  planeNode.categoryBitMask = 1 << 0;

  SCNMaterial *dotMaterial = [[SCNMaterial alloc] init];
  dotMaterial.diffuse.contents = [UIColor whiteColor];

  SCNSphere *sphere = [SCNSphere sphereWithRadius:0.3];
  sphere.materials = @[dotMaterial];

  SCNNode *dotNode = [SCNNode nodeWithGeometry:sphere];

  CGFloat angle = 360.0/365.0 * birthday.daysLeft;
  CGFloat z = [self scaledEarthPathRadius] * cos(angle * M_PI / 180.0);
  CGFloat x = [self scaledEarthPathRadius] * sin(angle * M_PI / 180.0);
  dotNode.position = SCNVector3Make(x, 0, z);

  [dotNode addChildNode:planeNode];

  return dotNode;
}

@end
