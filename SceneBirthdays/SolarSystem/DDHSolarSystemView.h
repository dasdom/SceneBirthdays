//  Created by Dominik Hauser on 03.05.24.
//  
//


#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHNodesCreator;

@interface DDHSolarSystemView : SCNView
@property (nonatomic, strong) SCNNode *cameraOrbit;
@property (nonatomic, strong) SCNNode *earthPath;
@property (nonatomic, strong) SCNNode *sun;
@property (nonatomic, strong) UIButton *addButton;
- (instancetype)initWithNodesCreator:(DDHNodesCreator *)nodesCreator;
@end

NS_ASSUME_NONNULL_END
