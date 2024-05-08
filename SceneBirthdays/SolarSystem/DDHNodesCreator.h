//  Created by Dominik Hauser on 03.05.24.
//  
//


#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHBirthday;

@interface DDHNodesCreator : NSObject
+ (SCNNode *)sun;
+ (SCNNode *)earth;
+ (SCNNode *)earthPath;
+ (SCNNode *)cameraOrbit:(SCNVector3)cameraPosition verticalCameraAngle:(CGFloat)verticalCameraAngle;
+ (SCNNode *)directionalLightNode;
+ (SCNNode *)ambientLightNode;
+ (SCNNode *)birthdayIndicatorForBirthday:(DDHBirthday *)birthday;
@end

NS_ASSUME_NONNULL_END
