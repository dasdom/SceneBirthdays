//  Created by Dominik Hauser on 03.05.24.
//  
//


#import "DDHSolarSystemView.h"
#import "DDHNodesCreator.h"

@interface DDHSolarSystemView ()
@property (nonatomic, strong) SCNNode *sun;
@property (nonatomic, strong) SCNNode *earthPath;
@end

@implementation DDHSolarSystemView

- (instancetype)initWithFrame:(CGRect)frame options:(nullable NSDictionary<NSString *,id> *)options {
  if (self = [super initWithFrame:frame options:options]) {
    _sun = [DDHNodesCreator sun];
    
    _cameraOrbit = [DDHNodesCreator cameraOrbit:SCNVector3Make(0, 0.2, 0) verticalCameraAngle:-0.5];
    [_cameraOrbit addChildNode:[DDHNodesCreator directionalLightNode]];
    [_cameraOrbit addChildNode:[DDHNodesCreator ambientLightNode]];

    _earthPath = [DDHNodesCreator earthPath];

    SCNScene *scene = [[SCNScene alloc] init];
    [scene.rootNode addChildNode:_sun];
    [scene.rootNode addChildNode:_cameraOrbit];
    [scene.rootNode addChildNode:_earthPath];
    [scene.rootNode addChildNode:[DDHNodesCreator earth]];

    // show statistics such as fps and timing information
    self.showsStatistics = YES;

    // configure the view
    self.backgroundColor = [UIColor blackColor];

    self.scene = scene;
  }
  return self;
}

@end
