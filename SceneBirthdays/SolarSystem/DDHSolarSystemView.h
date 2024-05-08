//  Created by Dominik Hauser on 03.05.24.
//  
//


#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDHSolarSystemView : SCNView
@property (nonatomic, strong) SCNNode *cameraOrbit;
@property (nonatomic, strong) UIButton *addButton;
@end

NS_ASSUME_NONNULL_END
