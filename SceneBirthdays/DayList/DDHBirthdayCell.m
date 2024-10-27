//  Created by Dominik Hauser on 27.10.24.
//  
//


#import "DDHBirthdayCell.h"
#import "DDHBirthday.h"

@interface DDHBirthdayCell ()
@property (nonatomic, strong) UIImageView *personImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *daysLeftLabel;
@end

@implementation DDHBirthdayCell

+ (NSString *)identifier {
    return NSStringFromClass(self);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor colorNamed:@"cellBackground"];
    }
    return self;
}

- (void)updateWithBirthday:(DDHBirthday *)birthday nameFormatter:(NSPersonNameComponentsFormatter *)nameFormatter {
    self.imageView.image = [UIImage imageWithData:birthday.imageData];
    self.textLabel.text = [nameFormatter stringFromPersonNameComponents:birthday.personNameComponents];
}

@end
