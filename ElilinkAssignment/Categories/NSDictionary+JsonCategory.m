//
//  NSDictionary+JsonCategory.m
//  BetaFace
//
//  Created by Kolya on 29.11.15.
//  Copyright © 2015 NoliNik. All rights reserved.
//

#import "NSDictionary+JsonCategory.h"

@implementation NSDictionary (JsonCategory)

+(NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:[fileLocation pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];

    if (error != nil) return nil;
    return result;
}




@end
