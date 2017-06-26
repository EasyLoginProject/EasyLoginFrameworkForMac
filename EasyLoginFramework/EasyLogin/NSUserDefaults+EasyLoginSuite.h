//
//  NSUserDefaults+EasyLoginSuite.h
//  EasyLoginFramework
//
//  Created by Yoann Gini on 26/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kELDomainSuiteForPreferences @"io.easylogin.settings"
#define kELPreferencesBaseURL @"baseURL"

@interface NSUserDefaults (EasyLoginSuite)

+ (instancetype)easyLoginDomain;

@end
