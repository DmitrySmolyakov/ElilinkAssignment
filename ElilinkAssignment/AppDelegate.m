//
//  AppDelegate.m
//  ElilinkAssignment
//
//  Created by Dmitry Smolyakov on 6/30/16.
//  Copyright © 2016 Dmitry Smolyakov. All rights reserved.
//

#import "AppDelegate.h"

//categories
#import "NSDictionary+JsonCategory.h"

//frameworks
#import <MagicalRecord/MagicalRecord.h>
#import <AFNetworkActivityIndicatorManager.h>

//models
#import "DSCity.h"

@interface AppDelegate ()

@end

static NSString * const kFirstLaunch = @"firstLaunch";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    [MagicalRecord setupCoreDataStack];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kFirstLaunch]) {
        [self setupFirstLaunch];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [MagicalRecord cleanUp];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Setup

- (void)setupFirstLaunch {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstLaunch];
    
    NSDictionary* citiesDictionary = [NSDictionary dictionaryWithContentsOfJSONString:@"cities.json"];
    NSArray *citiesArrya = [citiesDictionary objectForKey:@"cities"];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
        for (NSDictionary *dictionary in citiesArrya) {
            [DSCity createWithDictionary:dictionary InContext:localContext];
        }
    }];
}

@end
