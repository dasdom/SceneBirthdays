//  Created by Dominik Hauser on 27.10.24.
//  
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHBirthday;

@interface DDHBirthdaysListViewController : UIViewController
- (instancetype)initWithBirthdays:(NSArray<DDHBirthday *> *)birthdays;
@end

NS_ASSUME_NONNULL_END
