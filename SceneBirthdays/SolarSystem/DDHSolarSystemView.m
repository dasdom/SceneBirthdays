//  Created by Dominik Hauser on 03.05.24.
//  
//


#import "DDHSolarSystemView.h"
#import "DDHNodesCreator.h"

@interface DDHSolarSystemView ()
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
    self.scene = scene;

    UIButtonConfiguration *addButtonConfiguration = [UIButtonConfiguration plainButtonConfiguration];
    addButtonConfiguration.image = [UIImage systemImageNamed:@"plus"];
    _addButton = [UIButton buttonWithConfiguration:addButtonConfiguration primaryAction:nil];
    _addButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.showsStatistics = YES;

    self.backgroundColor = [UIColor blackColor];

    [self addSubview:_addButton];

    [NSLayoutConstraint activateConstraints:@[
      [_addButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:16],
      [_addButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-16],
    ]];
  }
  return self;
}

@end
