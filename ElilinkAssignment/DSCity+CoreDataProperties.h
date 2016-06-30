//
//  DSCity+CoreDataProperties.h
//  ElilinkAssignment
//
//  Created by Dmitry Smolyakov on 6/30/16.
//  Copyright © 2016 Dmitry Smolyakov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DSCity.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSCity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cityDescription;
@property (nullable, nonatomic, retain) NSString *code;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSDate *lastUpdatedWeatherDate;
@property (nullable, nonatomic, retain) NSString *weather;

@end

NS_ASSUME_NONNULL_END
