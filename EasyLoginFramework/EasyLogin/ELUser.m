//
//  ELUser.m
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELUser.h"

@implementation ELUser

+(nonnull NSString*)recordEntity; // default to class name
{
    return @"user";
}

+(nonnull NSString*)collectionName {
    return @"users";
}

-(instancetype)initWithProperties:(ELRecordProperties *)properties
{
    self = [super initWithProperties:properties];
    if(self) {
#if USE_OBJC_PROPERTIES
        [self __transferFromRecordProperties:self.properties];
#endif
    }
    
    return self;
}


@end
