//  Created by Dominik Hauser on 03.05.24.
//  
//


#import "DDHSolarSystemViewController.h"
#import "DDHSolarSystemView.h"
#import "DDHContactsManager.h"
#import "DDHNodesCreator.h"

@interface DDHSolarSystemViewController ()

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

- (void)add:(UIButton *)sender {
  DDHContactsManager *contactsManager = [[DDHContactsManager alloc] init];
  [contactsManager requestContactsAccess:^(BOOL granted) {
    if (granted) {
      NSArray<CNContact *> *contacts = [contactsManager fetchImportableContactsIgnoringExitingIds:@[]];
      NSArray<DDHBirthday *> *birthdays = [contactsManager birthdaysFromContacts:contacts];
      [birthdays enumerateObjectsUsingBlock:^(DDHBirthday * _Nonnull birthday, NSUInteger idx, BOOL * _Nonnull stop) {
        SCNNode *node = [DDHNodesCreator birthdayIndicatorForBirthday:birthday];
        [self.contentView.scene.rootNode addChildNode:node];
      }];
    }
  }];
}

@end
