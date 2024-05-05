//  Created by Dominik Hauser on 05.05.24.
//  
//


#import "DDHDateHelper.h"

@implementation DDHDateHelper
+ (NSCalendar *)calendar {
  return NSCalendar.currentCalendar;
}

+ (NSInteger)daysLeftForDateComponents:(NSDateComponents *)components {
  NSDate *dateOfStartOfToday = [self.calendar startOfDayForDate:[NSDate now]];
  components.year = NSDateComponentUndefined;

  NSDate *nextBirthday = [self.calendar nextDateAfterDate:dateOfStartOfToday matchingComponents:components options:NSCalendarMatchNextTimePreservingSmallerUnits];
  NSInteger daysLeft = [self.calendar components:NSCalendarUnitDay fromDate:dateOfStartOfToday toDate:nextBirthday options:0].day;

  unsigned unitFlags = NSCalendarUnitCalendar | NSCalendarUnitMonth |  NSCalendarUnitDay;

  NSDateComponents *todayComponents = [self.calendar components:unitFlags fromDate:dateOfStartOfToday];
  NSDateComponents *nextBirthdayComponents = [self.calendar components:unitFlags fromDate:nextBirthday];

  if ([todayComponents isEqual:nextBirthdayComponents]) {
    return 0;
  }

  return daysLeft;
}
@end
