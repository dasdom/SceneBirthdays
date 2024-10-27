//  Created by Dominik Hauser on 03.05.24.
//
//


#import "DDHSolarSystemViewController.h"
#import "DDHSolarSystemView.h"
#import "DDHContactsManager.h"
#import "DDHNodesCreator.h"
#import "DDHBirthday.h"
#import "DDHDateHelper.h"
#import "DDHBirthdaysListViewController.h"
//#import "DDHBirthdayDetailsView.h"

@interface DDHSolarSystemViewController () <CAAnimationDelegate>
@property (nonatomic, assign) CGFloat startAngle;
//@property (nonatomic, strong) NSDictionary<NSUUID *, SCNNode *> *birthdayNodes;
@property (nonatomic, strong) NSArray<DDHBirthday *> *birthdays;
@property (nonatomic, assign) CGFloat verticalAngle;
@property (nonatomic, strong) DDHNodesCreator *nodesCreator;
@property (nonatomic, strong) NSArray<SCNNode *> *hostNodes;
@property (nonatomic, strong) NSMutableArray<SCNNode *> *nodesToHide;
@property (nonatomic, strong) NSPersonNameComponentsFormatter *nameFormatter;
@property (nonatomic, strong) DDHBirthdaysListViewController *listViewController;
@end

@implementation DDHSolarSystemViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _birthdays = @[];
        _nodesCreator = [[DDHNodesCreator alloc] init];
        _nameFormatter = [[NSPersonNameComponentsFormatter alloc] init];
        _nameFormatter.style = NSPersonNameComponentsFormatterStyleDefault;
        _nodesToHide = [[NSMutableArray alloc] init];
    }
    return self;
}

- (DDHSolarSystemView *)contentView {
    return (DDHSolarSystemView *)self.view;
}

- (void)loadView {
    DDHSolarSystemView *contentView = [[DDHSolarSystemView alloc] initWithNodesCreator:self.nodesCreator];
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
    NSArray<SCNNode *> *monthsNodes = [self.nodesCreator monthNodesWithNumberOfDaysInYear:[self daysInYear] sceneMonth:sceneMonths];
    [self.nodesToHide addObjectsFromArray:monthsNodes];
    for (SCNNode *node in monthsNodes) {
        [[self contentView].scene.rootNode addChildNode:node];
    }

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapRecognizer];
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

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cameraNode.position = endPosition;
    });
}

// MARK: - Rotation
- (void)rotateToRotationAngle:(CGFloat)rotationAngle {
    [self updateCameraAndBirthdayIndicatorsWithRotationAngle:rotationAngle];
}

- (void)updateCameraAndBirthdayIndicatorsWithRotationAngle:(CGFloat)rotationAngle {
    SCNVector3 cameraOrbitEulerAngles = [self contentView].cameraOrbit.eulerAngles;
    self.contentView.cameraOrbit.eulerAngles = SCNVector3Make(cameraOrbitEulerAngles.x, rotationAngle, cameraOrbitEulerAngles.z);

    for (SCNNode *node in self.hostNodes) {
        SCNVector3 nodeEulerAngles = node.eulerAngles;
        node.eulerAngles = SCNVector3Make(nodeEulerAngles.x, rotationAngle, nodeEulerAngles.z);
    }
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

    for (SCNNode *node in self.hostNodes) {
        [node addAnimation:birthdayRotate forKey:eulerAnglesKey];
    }
}

// MARK: - Update birthdays
- (void)updateForBirthdays:(NSArray<DDHBirthday *> *)birthdays {
    for (SCNNode *node in self.hostNodes) {
        [node removeFromParentNode];
    }

    NSMutableDictionary<NSNumber *, SCNNode *> *nodesForDaysLeft = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSNumber *, NSMutableArray<DDHBirthday *> *> *birthdayNodes = [[NSMutableDictionary alloc] initWithCapacity:[birthdays count]];
    NSMutableArray<SCNNode *> *hostNodes = [[NSMutableArray alloc] initWithCapacity:[birthdays count]];

    for (DDHBirthday *birthday in birthdays) {
        NSInteger daysLeft = birthday.daysLeft;

        NSMutableArray<DDHBirthday *> *birthdaysForDaysLeft = birthdayNodes[@(daysLeft)];
        if (nil == birthdaysForDaysLeft) {
            birthdaysForDaysLeft = [[NSMutableArray alloc] init];
        }

        SCNNode *hostNode = nodesForDaysLeft[@(daysLeft)];
        if (nil != hostNode) {
            SCNMaterial *material = [[SCNMaterial alloc] init];
            material.diffuse.contents = [UIColor yellowColor];
            hostNode.geometry.materials = @[material];
        } else {
            hostNode = [self.nodesCreator birthdayHostNodeForDaysLeft:daysLeft numberOfDaysInYear:[self daysInYear] eulerAngles:SCNVector3Make(self.verticalAngle, [self contentView].cameraOrbit.eulerAngles.y, 0)];
            [hostNodes addObject:hostNode];
            [[self contentView].earthPath addChildNode:hostNode];
        }

        nodesForDaysLeft[@(daysLeft)] = hostNode;

        [birthdaysForDaysLeft addObject:birthday];
        birthdayNodes[@(daysLeft)] = birthdaysForDaysLeft;
        //    }
    }

    [nodesForDaysLeft enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull daysLeft, SCNNode * _Nonnull node, BOOL * _Nonnull stop) {
        NSArray<DDHBirthday *> *birthdays = birthdayNodes[daysLeft];
        [self.nodesCreator addBirthdayNodeForBirthdays:birthdays toNode:node];
    }];

    self.hostNodes = [hostNodes copy];
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
                self.birthdays = [self.birthdays arrayByAddingObjectsFromArray:birthdays];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateForBirthdays:self.birthdays];
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

- (void)tap:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    NSArray<SCNHitTestResult *> *hits = [[self contentView] hitTest:location options:nil];
    SCNHitTestResult *firstHit = [hits firstObject];
    SCNNode *parentNode = firstHit.node.parentNode;
    SCNVector3 parentPosition = parentNode.position;
    NSLog(@"parent: %@", parentNode.name);
    NSLog(@"parent: %lf %lf %lf", parentPosition.x, parentPosition.y, parentPosition.z);

    NSMutableArray<DDHBirthday *> *selectedBirthdays = [[NSMutableArray alloc] init];
    for (DDHBirthday *birthday in self.birthdays) {
        if (birthday.daysLeft == [parentNode.name integerValue]) {
            [selectedBirthdays addObject:birthday];
        }
    }

    NSLog(@"selectedBirthdays: %@", selectedBirthdays);

    SCNVector3 parentRelativePosition = SCNVector3Make(parentPosition.x + 8, 10, parentPosition.z + 10);
    if (SCNVector3EqualToVector3([self contentView].cameraOrbit.childNodes.firstObject.position, parentRelativePosition)) {
        return;
    }

    if ([selectedBirthdays count] > 0) {
        for (SCNNode *node in self.hostNodes) {
            if (node != parentNode) {
                [self.nodesToHide addObject:node];
            }
        }

        UIView *subview = [self showList];
        [self animateCameraFrom:SCNVector3Zero to:parentRelativePosition subview:subview];

        for (SCNNode *node in self.nodesToHide) {
            CABasicAnimation *changeCameraPositionAnimation = [self animationWithKeyPath:@"opacity" fromValue:@1 toValue:@0];
            [node addAnimation:changeCameraPositionAnimation forKey:@"changeOpacity"];

            node.opacity = 0;
        }

    } else {
        [self animateCameraFrom:SCNVector3Zero to:SCNVector3Make(0, 13, 35) subview:self.listViewController.view];
        [self hideList];

        for (SCNNode *node in self.nodesToHide) {
            CABasicAnimation *changeCameraPositionAnimation = [self animationWithKeyPath:@"opacity" fromValue:@0 toValue:@1];
            [node addAnimation:changeCameraPositionAnimation forKey:@"changeOpacity"];

            node.opacity = 1;
        }

        for (SCNNode *node in self.hostNodes) {
            [self.nodesToHide removeObject:node];
        }

    }
}

- (UIView *)showList {
    DDHBirthdaysListViewController *listViewController = [[DDHBirthdaysListViewController alloc] initWithBirthdays:self.birthdays];
    [self addChildViewController:listViewController];
    self.listViewController = listViewController;

    UIView *subview = listViewController.view;
    subview.alpha = 1;
    subview.userInteractionEnabled = true;

    [self.view addSubview:subview];

    CGRect viewFrame = self.view.frame;
    subview.frame = CGRectMake(3 * viewFrame.size.width / 2, 20, viewFrame.size.width/2, viewFrame.size.height - 40);

    [listViewController didMoveToParentViewController:self];

//   UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 dampingRatio:0.5 animations:^{
//        subview.alpha = 1;
//    }];
//    [animator startAnimation];

    return subview;
}

- (void)hideList {
    UIView *subview = self.listViewController.view;

    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:0.3 dampingRatio:0.5 animations:^{
        subview.alpha = 0;
    }];
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [subview removeFromSuperview];
        [self.listViewController removeFromParentViewController];
        [self.listViewController didMoveToParentViewController:nil];
        self.listViewController = nil;
    }];

    [animator startAnimation];
}

- (void)animateCameraFrom:(SCNVector3)startPosition to:(SCNVector3)endPosition subview:(UIView *)subview {
    SCNNode *cameraNode = [self contentView].cameraOrbit.childNodes.firstObject;
    if (SCNVector3EqualToVector3(startPosition, SCNVector3Zero)) {
        startPosition = cameraNode.position;
    } else {
        cameraNode.position = startPosition;
    }

    [CATransaction begin];
    CABasicAnimation *changeCameraPositionAnimation = [self animationWithKeyPath:@"position" fromValue:[NSValue valueWithSCNVector3:startPosition] toValue:[NSValue valueWithSCNVector3:endPosition]];
    [cameraNode addAnimation:changeCameraPositionAnimation forKey:@"changeCameraPosition"];

    CGPoint startPoint = CGPointMake(CGRectGetMidX(subview.frame), CGRectGetMidY(subview.frame));
    CGPoint endPoint = CGPointMake(self.view.frame.size.width - subview.frame.size.width/2, CGRectGetMidY(subview.frame));

    CABasicAnimation *subviewPositionAnimation = [self animationWithKeyPath:@"position" fromValue:[NSValue valueWithCGPoint:startPoint] toValue:[NSValue valueWithCGPoint:endPoint]];
    [subview.layer addAnimation:subviewPositionAnimation forKey:@"position"];

    [CATransaction commit];

    subview.layer.position = endPoint;
    cameraNode.position = endPosition;
}

- (CABasicAnimation *)animationWithKeyPath:(NSString *)keyPath fromValue:(id)fromValue toValue:(id)toValue {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = 0.5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

- (void)resetCamera {
    NSTimeInterval duration = 0.2;

    [[self contentView].sun runAction:[SCNAction scaleTo:1 duration:duration]];
    [self runRotateToZeroActionForNodes:@[[self contentView].cameraOrbit] withDuration:duration];

    [self runRotateToZeroActionForNodes:self.hostNodes withDuration:duration];
}

- (void)runRotateToZeroActionForNodes:(NSArray<SCNNode *> *)nodes withDuration:(NSTimeInterval)duration {
    for (SCNNode *node in nodes) {
        [node runAction:[SCNAction rotateToX:node.eulerAngles.x y:0 z:node.eulerAngles.z duration:duration shortestUnitArc:YES]];
    }
}

@end
