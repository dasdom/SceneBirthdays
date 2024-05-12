//  Created by Dominik Hauser on 03.05.24.
//  
//


#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHBirthday;
@class DDHSceneMonth;

@interface DDHNodesCreator : NSObject
+ (SCNNode *)sun;
//+ (SCNNode *)earth;
+ (SCNNode *)earthPath;
+ (SCNNode *)cameraOrbit:(SCNVector3)cameraPosition verticalCameraAngle:(CGFloat)verticalCameraAngle;
+ (SCNNode *)directionalLightNode;
+ (SCNNode *)ambientLightNode;
+ (SCNNode *)birthdayHostNodeForDaysLeft:(NSInteger)daysLeft numberOfDaysInYear:(NSInteger)numberOfDaysInYear eulerAngles:(SCNVector3)eulerAngles;
+ (SCNNode *)addBirthdayNodeForBirthday:(DDHBirthday *)birthday toNode:(SCNNode *)node;
+ (NSArray<SCNNode *> *)significantIntervalsIndicatorNodesWithNumberOfDaysInYear:(NSInteger)numberOfDaysInYear;
+ (NSArray<SCNNode *> *)monthNodesWithNumberOfDaysInYear:(NSInteger)numberOfDaysInYear sceneMonth:(NSArray<DDHSceneMonth *> *)sceneMonths;
@end

NS_ASSUME_NONNULL_END
