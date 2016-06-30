//
//  NSDictionary+JsonCategory.h
//  BetaFace
//
//  Created by Kolya on 29.11.15.
//  Copyright © 2015 NoliNik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JsonCategory)

+(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation;

@end
