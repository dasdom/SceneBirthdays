//  Created by Dominik Hauser on 03.05.24.
//  
//


#import "DDHSolarSystemViewController.h"
#import "DDHSolarSystemView.h"
#import "DDHContactsManager.h"
#import "DDHNodesCreator.h"
#import "DDHBirthday.h"
#import "DDHDateHelper.h"

@interface DDHSolarSystemViewController () <CAAnimationDelegate>
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, strong) NSDictionary<NSUUID *, SCNNode *> *birthdayNodes;
@property (nonatomic, assign) CGFloat verticalAngle;
@end

@implementation DDHSolarSystemViewController

- (DDHSolarSystemView *)contentView {
  return (DDHSolarSystemView *)self.view;
}

- (void)loadView {
  DDHSolarSystemView *contentView = [[DDHSolarSystemView alloc] initWithFrame:CGRectZero options:nil];
  [contentView.addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
  self.view = contentView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.verticalAngle = -0.5;

  UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
  [self.view addGestureRecognizer:panRecognizer];

//  NSArray<SCNNode *> *intervalNodes = [DDHNodesCreator significantIntervalsIndicatorNodesWithNumberOfDaysInYear:[self daysInYear]];
//  [intervalNodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
//    [[self contentView].scene.rootNode addChildNode:node];
//  }];

  NSArray<DDHSceneMonth *> *sceneMonths = [DDHDateHelper sceneMonths];
  NSArray<SCNNode *> *monthsNodes = [DDHNodesCreator monthNodesWithNumberOfDaysInYear:[self daysInYear] sceneMonth:sceneMonths];
  [monthsNodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
    [[self contentView].scene.rootNode addChildNode:node];
  }];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  SCNVector3 startPosition = SCNVector3Make(0, 0.2, 0.3);
  SCNVector3 endPosition = SCNVector3Make(0, 13, 35);

  SCNNode *cameraNode = [self contentView].cameraOrbit.childNodes.firstObject;
  cameraNode.position = startPosition;

  CABasicAnimation *changeCameraPositionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
  changeCameraPositionAnimation.fromValue = [NSValue valueWithSCNVector3:startPosition];
  changeCameraPositionAnimation.toValue = [NSValue valueWithSCNVector3:endPosition];
  changeCameraPositionAnimation.duration = 1;
  changeCameraPositionAnimation.beginTime = CACurrentMediaTime() + 0.6;
  changeCameraPositionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  changeCameraPositionAnimation.removedOnCompletion = NO;
  changeCameraPositionAnimation.fillMode = kCAFillModeForwards;
  [cameraNode addAnimation:changeCameraPositionAnimation forKey:@"changeCameraPosition"];
}

// MARK: - Rotation
- (void)rotateToRotationAngle:(CGFloat)rotationAngle {
  [self updateCameraAndBirthdayIndicatorsWithRotationAngle:rotationAngle];
}

- (void)updateCameraAndBirthdayIndicatorsWithRotationAngle:(CGFloat)rotationAngle {
  SCNVector3 cameraOrbitEulerAngles = [self contentView].cameraOrbit.eulerAngles;
  self.contentView.cameraOrbit.eulerAngles = SCNVector3Make(cameraOrbitEulerAngles.x, rotationAngle, cameraOrbitEulerAngles.z);

  [self.birthdayNodes enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, SCNNode * _Nonnull node, BOOL * _Nonnull stop) {
    SCNVector3 nodeEulerAngles = node.eulerAngles;
    node.eulerAngles = SCNVector3Make(nodeEulerAngles.x, rotationAngle, nodeEulerAngles.z);
  }];
}

// MARK: - Animation
- (CFTimeInterval)animationDurationForMovingFromStartAngle:(CGFloat)startAngle toEndAngle:(CGFloat)endAngle {
  CGFloat angleDistance = fabs(endAngle - startAngle);
  return 1.8 * angleDistance / (2 * M_PI);
}

- (void)animateCameraAndBirthdaysToRotationAngle:(CGFloat)rotationAngle animationDuration:(CFTimeInterval)animationDuration {
  self.view.userInteractionEnabled = NO;
  DDHSolarSystemView *contentView = [self contentView];
  CGFloat currentAngle = contentView.cameraOrbit.presentationNode.eulerAngles.y;
  CGFloat angleDistance = contentView.cameraOrbit.eulerAngles.y;
  if (animationDuration < 0.01) {
    animationDuration = [self animationDurationForMovingFromStartAngle:currentAngle toEndAngle:angleDistance];
  }

  NSString *eulerAnglesKey = @"eulerAngles";
  CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:eulerAnglesKey];
  rotate.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(0, currentAngle, 0)];
  rotate.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(0, rotationAngle, 0)];
  rotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  rotate.duration = animationDuration;
  rotate.delegate = self;
  [contentView.cameraOrbit addAnimation:rotate forKey:eulerAnglesKey];

  CABasicAnimation *birthdayRotate = [CABasicAnimation animationWithKeyPath:eulerAnglesKey];
  birthdayRotate.fromValue = [NSValue valueWithSCNVector3:SCNVector3Make(self.verticalAngle, rotationAngle, 0)];
  birthdayRotate.toValue = [NSValue valueWithSCNVector3:SCNVector3Make(self.verticalAngle, rotationAngle, 0)];
  birthdayRotate.duration = animationDuration;
  birthdayRotate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [self.birthdayNodes enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, SCNNode * _Nonnull node, BOOL * _Nonnull stop) {
    [node addAnimation:birthdayRotate forKey:eulerAnglesKey];
  }];
}

// MARK: - Update birthdays
- (void)updateForBirthdays:(NSArray<DDHBirthday *> *)birthdays {
  [self.birthdayNodes enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, SCNNode * _Nonnull node, BOOL * _Nonnull stop) {
    [node removeFromParentNode];
  }];

  NSMutableDictionary<NSNumber *, SCNNode *> *nodesForDaysLeft = [[NSMutableDictionary alloc] init];
  NSMutableDictionary<NSUUID *, SCNNode *> *birthdayNodes = [[NSMutableDictionary alloc] initWithCapacity:[birthdays count]];
  [birthdays enumerateObjectsUsingBlock:^(DDHBirthday * _Nonnull birthday, NSUInteger idx, BOOL * _Nonnull stop) {

    NSInteger daysLeft = birthday.daysLeft;

    SCNNode *hostNode = nodesForDaysLeft[@(daysLeft)];
    if (nil != hostNode) {
      SCNMaterial *material = [[SCNMaterial alloc] init];
      material.diffuse.contents = [UIColor yellowColor];
      hostNode.geometry.materials = @[material];
    } else {
      hostNode = [DDHNodesCreator birthdayHostNodeForDaysLeft:daysLeft numberOfDaysInYear:[self daysInYear] eulerAngles:SCNVector3Make(self.verticalAngle, [self contentView].cameraOrbit.eulerAngles.y, 0)];
      [DDHNodesCreator addBirthdayNodeForBirthday:birthday toNode:hostNode];
      [[self contentView].earthPath addChildNode:hostNode];

      birthdayNodes[birthday.uuid] = hostNode;
      nodesForDaysLeft[@(daysLeft)] = hostNode;
    }
  }];
  self.birthdayNodes = birthdayNodes;
}

- (NSInteger)daysInYear {
  NSDate *now = [NSDate now];

  NSDate *dateInOneYear = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitYear value:1 toDate:now options:0];
  if (nil == dateInOneYear) {
    return 365;
  }
  NSInteger numberOfDays = [NSCalendar.currentCalendar components:NSCalendarUnitDay fromDate:now toDate:dateInOneYear options:0].day;
  return MAX(numberOfDays, 365);
}

// MARK: - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  self.view.userInteractionEnabled = YES;
}

// MARK: - Actions
- (void)add:(UIButton *)sender {
  DDHContactsManager *contactsManager = [[DDHContactsManager alloc] init];
  [contactsManager requestContactsAccess:^(BOOL granted) {
    if (granted) {
      [contactsManager fetchImportableContactsIgnoringExitingIds:@[] completionHandler:^(NSArray<CNContact *> * _Nonnull contacts) {
        NSArray<DDHBirthday *> *birthdays = [contactsManager birthdaysFromContacts:contacts];
        dispatch_async(dispatch_get_main_queue(), ^{
          [self updateForBirthdays:birthdays];
        });
      }];
    }
  }];
}

- (void)pan:(UIPanGestureRecognizer *)sender {
  CGPoint translation = [sender translationInView:self.view];

  CGFloat angle = translation.x / self.view.bounds.size.width * M_PI;

  if (sender.state == UIGestureRecognizerStateBegan) {
    self.startAngle = self.contentView.cameraOrbit.eulerAngles.y;
  }

  CGFloat rotationAngle = MIN(2 * M_PI, self.startAngle - angle);
  
  if (sender.state == UIGestureRecognizerStateEnded) {
    if ([self contentView].cameraOrbit.eulerAngles.y < 0) {
      [self resetCamera];
    }
  } else if (rotationAngle < 0) {
    [self rotateToRotationAngle:rotationAngle/8];
    CGFloat scale = 1 - rotationAngle;
    [self contentView].sun.scale = SCNVector3Make(scale, scale, scale);
  } else {
    [self rotateToRotationAngle:rotationAngle];
  }
}

- (void)resetCamera {
  NSTimeInterval duration = 0.2;

  [[self contentView].sun runAction:[SCNAction scaleTo:1 duration:duration]];
  [self runRotateToZeroActionForNodes:@[[self contentView].cameraOrbit] withDuration:duration];

  [self runRotateToZeroActionForNodes:self.birthdayNodes.allValues withDuration:duration];
}

- (void)runRotateToZeroActionForNodes:(NSArray<SCNNode *> *)nodes withDuration:(NSTimeInterval)duration {
  [nodes enumerateObjectsUsingBlock:^(SCNNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
    [node runAction:[SCNAction rotateToX:node.eulerAngles.x y:0 z:node.eulerAngles.z duration:duration shortestUnitArc:YES]];
  }];
}

@end
