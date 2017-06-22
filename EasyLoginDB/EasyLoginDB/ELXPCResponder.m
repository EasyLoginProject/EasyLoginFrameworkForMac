//
//  ELXPCResponder.m
//  EasyLoginDB
//
//  Created by Yoann Gini on 16/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELXPCResponder.h"

#import "ELCachingDB.h"

@interface ELXPCResponder ()
@property ELCachingDB *cachingDB;
@end

@implementation ELXPCResponder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cachingDB = [ELCachingDB sharedInstance];
    }
    return self;
}

- (void)registerRecord:(NSDictionary*)record ofType:(NSString*)recordType withUUID:(NSString*)uuid;
{
    [self.cachingDB registerRecord:record ofType:recordType withUUID:uuid];
}

- (void)unregisterRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid;
{
    [self.cachingDB unregisterRecordOfType:recordType withUUID:uuid];
}

-(void)getAllRegisteredRecordsMatchingPredicates:(NSArray *)predicates withCompletionHandler:(EasyLoginDBQueryResult_t)completionHandler {
    [self.cachingDB getAllRegisteredRecordsMatchingPredicates:predicates withCompletionHandler:completionHandler];
}

- (void)getAllRegisteredRecordsMatchingPredicate:(NSDictionary *)predicate withCompletionHandler:(EasyLoginDBQueryResult_t)completionHandler {
    [self.cachingDB getAllRegisteredRecordsMatchingPredicate:predicate withCompletionHandler:completionHandler];
}

- (void)getAllRegisteredRecordsOfType:(NSString*)recordType withAttributesToReturn:(NSArray<NSString*> *)attributes andCompletionHandler:(EasyLoginDBQueryResult_t)completionHandler;
{
    [self.cachingDB getAllRegisteredRecordsOfType:recordType withAttributesToReturn:attributes andCompletionHandler:completionHandler];
}

- (void)getAllRegisteredUUIDsOfType:(NSString*)recordType andCompletionHandler:(EasyLoginDBUUIDsResult_t)completionHandler;
{
    [self.cachingDB getAllRegisteredUUIDsOfType:recordType andCompletionHandler:completionHandler];
}

- (void)getRegisteredRecordUUIDsOfType:(NSString*)recordType matchingAllAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(EasyLoginDBUUIDsResult_t)completionHandler;
{
    [self.cachingDB getRegisteredRecordUUIDsOfType:recordType matchingAllAttributes:attributesWithValues andCompletionHandler:completionHandler];
}

- (void)getRegisteredRecordUUIDsOfType:(NSString*)recordType matchingAnyAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(EasyLoginDBUUIDsResult_t)completionHandler;
{
    [self.cachingDB getRegisteredRecordUUIDsOfType:recordType matchingAnyAttributes:attributesWithValues andCompletionHandler:completionHandler];
}

- (void)getRegisteredRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid andCompletionHandler:(EasyLoginDBRecordInfo_t)completionHandler;
{
    [self.cachingDB getRegisteredRecordOfType:recordType withUUID:uuid andCompletionHandler:completionHandler];
}

- (void)ping;
{
    [self.cachingDB ping];
}
- (void)testXPCConnection:(EasyLoginDBErrorHandler_t)completionHandler
{
    [self.cachingDB testXPCConnection:completionHandler];
}

@end
