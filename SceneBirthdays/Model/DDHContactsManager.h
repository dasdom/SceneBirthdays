//  Created by Dominik Hauser on 05.05.24.
//  
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CNContact;
@class DDHBirthday;

@interface DDHContactsManager : NSObject
- (BOOL)isAuthorised;
- (void)requestContactsAccess:(void(^)(BOOL granted))completionHandler;
- (NSArray<CNContact *> *)fetchImportableContactsIgnoringExitingIds:(NSArray<NSString *> *)existingIds;
- (NSArray<DDHBirthday *> *)birthdaysFromContacts:(NSArray<CNContact *> *)contacts;
@end

NS_ASSUME_NONNULL_END
