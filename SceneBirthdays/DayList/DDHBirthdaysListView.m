//  Created by Dominik Hauser on 27.10.24.
//  
//


#import "DDHBirthdaysListView.h"

@implementation DDHBirthdaysListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tableView = [[UITableView alloc] init];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.backgroundColor = [UIColor colorNamed:@"cellBackground"];

        self.layer.borderColor = UIColor.grayColor.CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 10;

        [self addSubview:_tableView];

        [NSLayoutConstraint activateConstraints:@[
            [_tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [_tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
            [_tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [_tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        ]];
    }
    return self;
}

@end
