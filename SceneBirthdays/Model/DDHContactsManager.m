//  Created by Dominik Hauser on 05.05.24.
//  
//


#import "DDHContactsManager.h"
#import <Contacts/Contacts.h>
#import "DDHBirthday.h"

@interface DDHContactsManager ()
@property (nonatomic, strong) CNContactStore *contactsStore;
@end

@implementation DDHContactsManager
- (instancetype)init {
  if (self = [super init]) {
    _contactsStore = [[CNContactStore alloc] init];
  }
  return self;
}

- (void)requestContactsAccess:(void(^)(BOOL granted))completionHandler {
  [self.contactsStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
    completionHandler(granted);
  }];
}

- (BOOL)isAuthorised {
  return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized;
}

- (NSArray<CNContact *> *)fetchImportableContactsIgnoringExitingIds:(NSArray<NSString *> *)existingIds {

  CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[
    CNContactGivenNameKey,
    CNContactFamilyNameKey,
    CNContactBirthdayKey,
    CNContactThumbnailImageDataKey
  ]];

  NSError *fetchError;
  NSMutableArray<CNContact *> *contacts = [[NSMutableArray alloc] init];
  [self.contactsStore enumerateContactsWithFetchRequest:fetchRequest error:&fetchError usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
    if (contact.birthday.date != nil &&
        NO == [existingIds containsObject:contact.identifier]) {
      [contacts addObject:contact];
    }
  }];
  return contacts.copy;
}

- (NSArray<DDHBirthday *> *)birthdaysFromContacts:(NSArray<CNContact *> *)contacts {
  NSMutableArray<DDHBirthday *> *birthdays = [NSMutableArray arrayWithCapacity:[contacts count]];
  [contacts enumerateObjectsUsingBlock:^(CNContact * _Nonnull contact, NSUInteger idx, BOOL * _Nonnull stop) {
    DDHBirthday *birthday = [[DDHBirthday alloc] initWithContact:contact];
    [birthdays addObject:birthday];
  }];
  return birthdays;
}

@end
