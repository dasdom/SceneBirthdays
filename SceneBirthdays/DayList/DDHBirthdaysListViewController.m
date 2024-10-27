//  Created by Dominik Hauser on 27.10.24.
//  
//


#import "DDHBirthdaysListViewController.h"
#import "DDHBirthdaysListView.h"
#import "DDHBirthdayCell.h"
#import "DDHBirthday.h"

@interface DDHBirthdaysListViewController ()
@property (nonatomic, strong) UITableViewDiffableDataSource *dataSource;
@property (nonatomic, strong) NSArray<DDHBirthday *> *birthdays;
@property (nonatomic, strong) NSPersonNameComponentsFormatter *nameFormatter;
@end

@implementation DDHBirthdaysListViewController

- (instancetype)initWithBirthdays:(NSArray<DDHBirthday *> *)birthdays {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _birthdays = birthdays;

        _nameFormatter = [[NSPersonNameComponentsFormatter alloc] init];
        _nameFormatter.style = NSPersonNameComponentsFormatterStyleMedium;
    }
    return self;
}

- (DDHBirthdaysListView *)contentView {
    return (DDHBirthdaysListView *)self.view;
}

- (void)loadView {
    self.view = [[DDHBirthdaysListView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UITableView *tableView = [self contentView].tableView;

    [tableView registerClass:[DDHBirthdayCell self] forCellReuseIdentifier:[DDHBirthdayCell identifier]];

    _dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:tableView cellProvider:^UITableViewCell * _Nullable(UITableView * _Nonnull tableView, NSIndexPath * _Nonnull indexPath, NSUUID * _Nonnull uuid) {

        DDHBirthdayCell *cell = [tableView dequeueReusableCellWithIdentifier:[DDHBirthdayCell identifier] forIndexPath:indexPath];

        NSUInteger index = [self.birthdays indexOfObjectPassingTest:^BOOL(DDHBirthday * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [obj.uuid isEqual:uuid];
        }];

        if (NSNotFound != index) {
            DDHBirthday *birthday = self.birthdays[index];

            [cell updateWithBirthday:birthday nameFormatter:self.nameFormatter];
        }

        return cell;
    }];

    [self updateWithBirthdays:self.birthdays];
}

- (void)updateWithBirthdays:(NSArray<DDHBirthday *> *)birthdays {
    NSDiffableDataSourceSnapshot *snapshot = [[NSDiffableDataSourceSnapshot alloc] init];
    [snapshot appendSectionsWithIdentifiers:@[@"main"]];

    NSMutableArray *ids = [[NSMutableArray alloc] initWithCapacity:[birthdays count]];
    for (DDHBirthday *birthday in birthdays) {
        [ids addObject:birthday.uuid];
    }

    [snapshot appendItemsWithIdentifiers:ids];
    [self.dataSource applySnapshot:snapshot animatingDifferences:YES];
}

@end
