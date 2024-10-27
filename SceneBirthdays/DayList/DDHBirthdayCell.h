//  Created by Dominik Hauser on 27.10.24.
//  
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDHBirthday;

@interface DDHBirthdayCell : UITableViewCell
+ (NSString *)identifier;
- (void)updateWithBirthday:(DDHBirthday *)birthday nameFormatter:(NSPersonNameComponentsFormatter *)nameFormatter;
@end

NS_ASSUME_NONNULL_END
