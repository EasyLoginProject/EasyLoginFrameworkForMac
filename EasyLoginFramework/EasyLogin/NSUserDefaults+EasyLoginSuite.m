//
//  NSUserDefaults+EasyLoginSuite.m
//  EasyLoginFramework
//
//  Created by Yoann Gini on 26/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "NSUserDefaults+EasyLoginSuite.h"

@implementation NSUserDefaults (EasyLoginSuite)

+ (instancetype)easyLoginDomain {
    static NSUserDefaults *easyLoginDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        easyLoginDefaults = [[NSUserDefaults alloc] initWithSuiteName:kELDomainSuiteForPreferences];
    });
    return easyLoginDefaults;
}

@end
