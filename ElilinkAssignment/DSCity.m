//
//  DSCity.m
//  ElilinkAssignment
//
//  Created by Dmitry Smolyakov on 6/30/16.
//  Copyright © 2016 Dmitry Smolyakov. All rights reserved.
//

#import "DSCity.h"

//frameworks
#import <MagicalRecord/MagicalRecord.h>

@implementation DSCity

- (void)createWithDictionary:(NSDictionary *)dictionary InContext:(NSManagedObjectContext *)localContext {
    
    DSCity *city = [DSCity MR_createEntityInContext:localContext];
    city.name = dictionary[@"name"];
    city.code = dictionary[@"code"];
    city.cityDescription = dictionary[@"description"];
}

- (void)updateWeatherWithDictionary:(NSDictionary *)dictionary {
    
    NSDictionary *mainDictionary = [dictionary objectForKey:@"main"] ? dictionary[@"main"] : nil;
    NSNumber *weather = [mainDictionary objectForKey:@"temp"] ? [mainDictionary objectForKey:@"temp"] : nil;
    if (weather) {
        self.weather = weather;
        self.lastUpdatedWeatherDate = [NSDate date];
    }
}

// Insert code here to add functionality to your managed object subclass

@end
