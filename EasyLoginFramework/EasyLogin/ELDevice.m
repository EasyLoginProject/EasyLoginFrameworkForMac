//
//  ELDevice.m
//  EasyLoginMacLib
//
//  Created by Yoann Gini on 21/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

#import "ELDevice.h"

@implementation ELDevice

+(nonnull NSString*)recordEntity; // default to class name
{
    return @"device";
}

+(nonnull NSString*)collectionName {
    return @"devices";
}

-(instancetype)initWithProperties:(ELRecordProperties *)properties
{
    self = [super initWithProperties:properties];
    if(self) {

    }
    return self;
}

@end
