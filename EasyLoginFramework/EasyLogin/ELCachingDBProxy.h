//
//  ELCachingDBProxy.h
//  EasyLogin
//
//  Created by Yoann Gini on 08/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <EasyLogin/ELCachingDBProtocol.h>

@interface ELCachingDBProxy : NSObject <ELCachingDBProtocol>

+ (instancetype)sharedInstance;

@end
