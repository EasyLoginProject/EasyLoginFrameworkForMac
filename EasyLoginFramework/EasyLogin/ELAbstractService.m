//
//  ELAbstractService.m
//  EasyLoginFramework
//
//  Created by Yoann Gini on 11/08/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELAbstractService.h"

#import "ELAbstractService-Private.h"
#import "ELRecord.h"
#import "ELRecordProperties.h"
#import "ELUser.h"
#import "ELDevice.h"

@implementation ELAbstractService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

#pragma mark - Private

-(Class<ELRecordProtocol>)recordClassForType:(NSString *)recordType {
    if ([recordType isEqualToString:@"user"]) {
        return [ELUser recordClass];
    } else {
        NSLog(@"Predicate returned something who isn't a supported type at this time… It was `%@`", recordType);
    }
    return nil;
}

- (ELRecord*)recordWithDictionary:(NSDictionary*)infos {
    NSString *recordType = [infos objectForKey:@"recordType"];
    Class<ELRecordProtocol> recordClass = [self recordClassForType:recordType];
    
    ELRecord *record = [recordClass newRecordWithProperties:[ELRecordProperties recordPropertiesWithDictionary:infos mapping:nil]];
    
    if (record) {
        return record;
    } else {
        NSLog(@"Unable to create record with infos:%@", infos);
    }
    
    return nil;
}

@end
