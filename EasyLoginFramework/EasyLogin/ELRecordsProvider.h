//
//  ELRecordsProvider.h
//  EasyLoginFramework
//
//  Created by Yoann Gini on 26/07/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELRecord.h"
#import "ELRecordProperties.h"
#import "ELUser.h"
#import "ELDevice.h"

typedef void (^ELRecordsQueryResult)(NSArray<ELRecord*> *results, NSError *error);
typedef void (^ELIdentifierQueryResult)(NSArray<NSString*> *results, NSError *error);
typedef void (^ELRecordRequestResult)(ELRecord* record, NSError *error);
typedef void (^ELErrorHandler)(NSError *error);

@protocol ELRecordsProvider

@required

@property BOOL alwaysUpdate;

+ (instancetype)sharedInstance;

- (void)getAllRecordsMatchingPredicates:(NSArray*)predicates withCompletionHandler:(ELRecordsQueryResult)completionHandler;
- (void)getAllRecordsMatchingPredicate:(NSDictionary *)predicate withCompletionHandler:(ELRecordsQueryResult)completionHandler;

- (void)getAllRecordsOfType:(NSString*)recordType andCompletionHandler:(ELRecordsQueryResult)completionHandler;
- (void)getAllIdentifiersOfType:(NSString*)recordType andCompletionHandler:(ELIdentifierQueryResult)completionHandler;

- (void)getRecordIdentifiersOfType:(NSString*)recordType matchingAllAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(ELIdentifierQueryResult)completionHandler;
- (void)getRecordIdentifiersOfType:(NSString*)recordType matchingAnyAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(ELIdentifierQueryResult)completionHandler;
- (void)getRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid andCompletionHandler:(ELRecordRequestResult)completionHandler;

- (void)getUpdatedRecord:(ELRecord*)record withCompletionHandler:(ELRecordRequestResult)completionHandler;

@end
