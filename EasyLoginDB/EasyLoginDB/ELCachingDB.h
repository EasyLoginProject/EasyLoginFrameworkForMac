//
//  ELCachingDB.h
//  EasyLoginDB
//
//  Created by Yoann Gini on 07/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ELCachingDBProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface ELCachingDB : NSObject <ELCachingDBProtocol>

+ (instancetype)sharedInstance;

@end
