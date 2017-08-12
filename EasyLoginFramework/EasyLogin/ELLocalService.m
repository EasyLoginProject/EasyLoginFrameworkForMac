//
//  ELLocalService.m
//  EasyLoginFramework
//
//  Created by Yoann Gini on 11/08/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELLocalService.h"

#import "ELCachingDBProxy.h"
#import "ELAbstractService-Private.h"

@implementation ELLocalService

@synthesize alwaysUpdate;

#pragma mark - Public API

- (void)getAllRecordsMatchingPredicates:(NSArray*)predicates withCompletionHandler:(ELRecordsQueryResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getAllRegisteredRecordsMatchingPredicates:predicates
                                                           withCompletionHandler:^(NSArray<NSDictionary *> *results, NSError *error) {
                                                               if (error) {
                                                                   completionHandler(nil, error);
                                                               } else {
                                                                   NSMutableArray *records = [[NSMutableArray alloc] initWithCapacity:[results count]];
                                                                   
                                                                   for (NSDictionary *infos in results) {
                                                                       [records addObject:[self recordWithDictionary:infos]];
                                                                   }
                                                                   
                                                                   completionHandler(records, nil);
                                                               }
                                                           }];
}

- (void)getAllRecordsMatchingPredicate:(NSDictionary *)predicate withCompletionHandler:(ELRecordsQueryResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getAllRegisteredRecordsMatchingPredicate:predicate
                                                          withCompletionHandler:^(NSArray<NSDictionary *> *results, NSError *error) {
                                                              if (error) {
                                                                  completionHandler(nil, error);
                                                              } else {
                                                                  NSMutableArray *records = [[NSMutableArray alloc] initWithCapacity:[results count]];
                                                                  
                                                                  for (NSDictionary *infos in results) {
                                                                      [records addObject:[self recordWithDictionary:infos]];
                                                                  }
                                                                  
                                                                  completionHandler(records, nil);
                                                              }
                                                          }];
}

- (void)getAllRecordsOfType:(NSString*)recordType andCompletionHandler:(ELRecordsQueryResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getAllRegisteredRecordsOfType:recordType
                                              withAttributesToReturn:nil
                                                andCompletionHandler:^(NSArray<NSDictionary *> *results, NSError *error) {
                                                    if (error) {
                                                        completionHandler(nil, error);
                                                    } else {
                                                        NSMutableArray *records = [[NSMutableArray alloc] initWithCapacity:[results count]];
                                                        
                                                        for (NSDictionary *infos in results) {
                                                            [records addObject:[self recordWithDictionary:infos]];
                                                        }
                                                        
                                                        completionHandler(records, nil);
                                                    }
                                                }];
}

- (void)getAllIdentifiersOfType:(NSString*)recordType andCompletionHandler:(ELIdentifierQueryResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getAllRegisteredUUIDsOfType:recordType
                                              andCompletionHandler:completionHandler];
}

- (void)getRecordIdentifiersOfType:(NSString*)recordType matchingAllAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(ELIdentifierQueryResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getRegisteredRecordUUIDsOfType:recordType
                                                matchingAllAttributes:attributesWithValues
                                                 andCompletionHandler:completionHandler];
    
}

- (void)getRecordIdentifiersOfType:(NSString*)recordType matchingAnyAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(ELIdentifierQueryResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getRegisteredRecordUUIDsOfType:recordType
                                                matchingAnyAttributes:attributesWithValues
                                                 andCompletionHandler:completionHandler];

}

- (void)getRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid andCompletionHandler:(ELRecordRequestResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getRegisteredRecordOfType:recordType
                                                        withUUID:uuid
                                            andCompletionHandler:^(NSDictionary *record, NSError *error) {
                                                if (error) {
                                                    completionHandler(nil, error);
                                                } else {
                                                    completionHandler([self recordWithDictionary:record], nil);
                                                }
                                            }];
}

- (void)getUpdatedRecord:(ELRecord*)record withCompletionHandler:(ELRecordRequestResult)completionHandler {
    [[ELCachingDBProxy sharedInstance] getRegisteredRecordOfType:record.recordEntity
                                                        withUUID:record.identifier
                                            andCompletionHandler:^(NSDictionary *infos, NSError *error) {
                                                if (error) {
                                                    completionHandler(nil, error);
                                                } else {
                                                    [record updateWithProperties:[ELRecordProperties recordPropertiesWithDictionary:infos mapping:nil]
                                                                         deletes:YES];
                                                    completionHandler(record, nil);
                                                }
                                            }];
}

#pragma mark - Public API for local storage

- (void)registerRecord:(ELRecord*)record {
    [[ELCachingDBProxy sharedInstance] registerRecord:[record.properties dictionaryRepresentation] ofType:record.recordEntity withUUID:record.identifier];
}

- (void)unregisterRecord:(ELRecord*)record {
    [[ELCachingDBProxy sharedInstance] unregisterRecordOfType:record.recordEntity withUUID:record.identifier];
}

#pragma mark - Internal

@end
