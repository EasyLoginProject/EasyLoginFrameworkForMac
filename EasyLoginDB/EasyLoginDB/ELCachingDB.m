//
//  ELCachingDB.m
//  EasyLoginDB
//
//  Created by Yoann Gini on 07/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELCachingDB.h"

#import "Constants.h"

@interface ELCachingDB ()

@property NSMutableDictionary *recordsPerTypeAndUUID;
@property NSMutableDictionary *indexesForRecordsPerTypeAttributeAndValue;
@property NSLock *recordsLock;
@end

@implementation ELCachingDB

#pragma mark - Object Lifecycle

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.recordsPerTypeAndUUID = [NSMutableDictionary new];
        self.indexesForRecordsPerTypeAttributeAndValue = [NSMutableDictionary new];
        self.recordsLock = [NSLock new];
        [self reloadFromDisk];
    }
    return self;
}

#pragma mark - SPI

- (void)reloadFromDisk {
    NSLog(@"Loading DB from disk");
    NSMutableDictionary *loadedInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[self flatFilePath]];
    if ([loadedInfo count] > 0) {
        self.recordsPerTypeAndUUID = loadedInfo;
    }
    
    for (NSString *recordType in self.recordsPerTypeAndUUID) {
        NSMutableDictionary *recordsForSpecificType = [self.recordsPerTypeAndUUID objectForKey:recordType];
        for (NSString *uuid in recordsForSpecificType) {
            [self addToIndexRecord:[recordsForSpecificType objectForKey:uuid] ofType:recordType withUUID:uuid];
        }
    }
}

- (void)saveToDisk {
    NSLog(@"Saving DB to disk");
    [self.recordsPerTypeAndUUID writeToFile:[self flatFilePath] atomically:YES];
}

- (NSString*)flatFilePath {
    return [NSString stringWithFormat:@"%@/flatfile.plist", [self dbPath]];
}

- (NSString*)dbPath {
    return kEasyLoginDBBasePath;
}

- (NSString*)dbPathForRecordsOfType:(NSString*)recordType {
    return [NSString stringWithFormat:@"%@/%@", [self dbPath], recordType];
}

- (void)addToIndexRecord:(NSDictionary *)record ofType:(NSString*)recordType withUUID:(NSString *)uuid {
    NSLog(@"Indexing record with UUID %@", uuid);
    
    NSMutableDictionary *indexesForRecordsPerAttributeAndValue = [self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType];
    
    if (!indexesForRecordsPerAttributeAndValue) {
        [self.indexesForRecordsPerTypeAttributeAndValue setObject:[NSMutableDictionary new] forKey:recordType];
        indexesForRecordsPerAttributeAndValue = [self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType];
    }
    
    NSArray *recordAttributes = [record allKeys];
    for (NSString *recordAttribute in recordAttributes) {
        NSString *indexedValue = [record objectForKey:recordAttribute];
        NSMutableDictionary * indexPerValue = [indexesForRecordsPerAttributeAndValue objectForKey:recordAttribute];
        
        if (!indexPerValue) {
            [indexesForRecordsPerAttributeAndValue setObject:[NSMutableDictionary new] forKey:recordAttribute];
            indexPerValue = [indexesForRecordsPerAttributeAndValue objectForKey:recordAttribute];
        }
        
        NSMutableArray *requestedIndex = [indexPerValue objectForKey:indexedValue];
        
        if (!requestedIndex) {
            [indexPerValue setObject:[NSMutableArray new] forKey:indexedValue];
            requestedIndex = [indexPerValue objectForKey:indexedValue];
        }
        
        [requestedIndex addObject:uuid];
    }
}

- (void)removeFromIndexRecordOfType:(NSString*)recordType withUUID:(NSString *)uuid {
    NSLog(@"Unindexing record with UUID %@", uuid);
    
    NSDictionary *record = [self getRegisteredRecordOfType:recordType withUUID:uuid];
    
    NSMutableDictionary *indexesForRecordsPerAttributeAndValue = [self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType];
    
    if (indexesForRecordsPerAttributeAndValue && record) {
        
        NSArray *recordAttributes = [record allKeys];
        for (NSString *recordAttribute in recordAttributes) {
            NSString *indexedValue = [record objectForKey:recordAttribute];
            NSMutableDictionary * indexPerValue = [indexesForRecordsPerAttributeAndValue objectForKey:recordAttribute];
            
            if (indexPerValue) {
                NSMutableArray *requestedIndex = [indexPerValue objectForKey:indexedValue];
                
                if (requestedIndex) {
                    [requestedIndex removeObject:uuid];
                }
            }
        }
    }
}

- (NSArray*)indexedUUIDsForRecordOfType:(NSString*)recordType withAttribute:(NSString *)attribute setTo:(NSString*)value {
    return [[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:value];
}

- (NSDictionary*)getRegisteredRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid {
    return [[self.recordsPerTypeAndUUID objectForKey:recordType] objectForKey:uuid];
}

- (void)setRecord:(NSDictionary*)record ofType:(NSString*)recordType withUUID:(NSString*)uuid {
    NSLog(@"Set record with UUID %@", uuid);
    
    NSMutableDictionary *recordsForRequestedTypePerUUID = [self.recordsPerTypeAndUUID objectForKey:recordType];
    
    if (!recordsForRequestedTypePerUUID) {
        [self.recordsPerTypeAndUUID setObject:[NSMutableDictionary new] forKey:recordType];
        recordsForRequestedTypePerUUID = [self.recordsPerTypeAndUUID objectForKey:recordType];
    }
    
    [recordsForRequestedTypePerUUID setObject:record forKey:uuid];
}

- (void)unsetRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid {
    NSLog(@"Unset record with UUID %@", uuid);
    
    NSMutableDictionary *recordsForRequestedTypePerUUID = [self.recordsPerTypeAndUUID objectForKey:recordType];
    
    if (recordsForRequestedTypePerUUID) {
        [recordsForRequestedTypePerUUID removeObjectForKey:uuid];
    }
}

#pragma mark - API

- (void)registerRecord:(NSDictionary*)record ofType:(NSString*)recordType withUUID:(NSString*)uuid {
    [self.recordsLock lock];
    NSLog(@"Register record with UUID %@", uuid);
    NSDictionary *existingRecordWithSameUUID = [self getRegisteredRecordOfType:recordType withUUID:uuid];
    
    if (existingRecordWithSameUUID) {
        [self removeFromIndexRecordOfType:recordType withUUID:uuid];
    }
    
    [self setRecord:record ofType:recordType withUUID:uuid];
    
    [self addToIndexRecord:record ofType:recordType withUUID:uuid];
    
    [self saveToDisk];
    [self.recordsLock unlock];
}

- (void)unregisterRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid {
    [self.recordsLock lock];
    NSLog(@"Unregister record with UUID %@", uuid);
    [self removeFromIndexRecordOfType:recordType withUUID:uuid];
    [self unsetRecordOfType:recordType withUUID:uuid];
    [self saveToDisk];
    [self.recordsLock unlock];
}

- (void)getAllRegisteredRecordsMatchingPredicates:(NSArray *)predicates withCompletionHandler:(EasyLoginDBQueryResult_t)completionHandler {
    NSLog(@"Getting all registered records matching list of predicates: %@", predicates);
    
    NSMutableArray *matchingRecords = [NSMutableArray new];
    
    for (NSDictionary *predicate in predicates) {
        [self getAllRegisteredRecordsMatchingPredicate:predicate withCompletionHandler:^(NSArray<NSDictionary *> *results, NSError *error) {
            [matchingRecords addObjectsFromArray:results];
        }];
    }
    
    completionHandler(matchingRecords, nil);
    
}

- (void)getAllRegisteredRecordsMatchingPredicate:(NSDictionary *)predicate withCompletionHandler:(EasyLoginDBQueryResult_t)completionHandler {
    NSLog(@"Getting all registered records matching specific predicate: %@", predicate);
    
    /*
     -- Multiple
     predicateList
     operator
     @"OR"
     @"AND"
     @"NOT"
     
     -- Single
     recordType
     attribute
     valueList
     
     matchType
     @"any"
     @"equalTo"
     @"beginsWith"
     @"endsWith"
     @"contains"
     @"greaterThan"
     @"lessThan"
     
     equalityRule
     @"none"
     @"caseIgnore"
     @"caseExact"
     @"number"
     @"certificate"
     @"time"
     @"telephoneNumber"
     @"octetMatch"
     */
    
    NSMutableArray *matchingRecords = [NSMutableArray new];
    NSArray *subPredicates = [predicate objectForKey:@"predicateList"];
    NSString *operator = [predicate objectForKey:@"operator"];
    __block NSError *processError = nil;
    
    if (subPredicates) {
        __block BOOL initialLoadDone = NO;
        NSString *recordType = [predicate objectForKey:@"recordType"];
        for (NSDictionary *subPredicate in subPredicates) {
            NSDictionary *completeSubPredicate = subPredicate;
            if (![subPredicate objectForKey:@"recordType"]) {
                NSMutableDictionary *mutableSubPredicate = [subPredicate mutableCopy];
                
                [mutableSubPredicate setObject:recordType forKey:@"recordType"];
                
                completeSubPredicate = mutableSubPredicate;
            }
            
            
            [self getAllRegisteredRecordsMatchingPredicate:completeSubPredicate withCompletionHandler:^(NSArray<NSDictionary *> *results, NSError *error) {
                if (error) {
                    NSLog(@"Nested predicate error: %@", error);
                    processError = error;
                } else {
                    if (!initialLoadDone) {
                        initialLoadDone = YES;
                        [matchingRecords addObjectsFromArray:results];
                    } else {
                        if ([@"AND" isEqualToString:operator]) {
                            NSMutableIndexSet *indexesToKeep = [NSMutableIndexSet new];
                            for (NSDictionary *record in results) {
                                NSString *uuidInSecondArray = [record objectForKey:@"uuid"];
                                [matchingRecords enumerateObjectsUsingBlock:^(NSDictionary *potentialRecord, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([[potentialRecord objectForKey:@"uuid"] isEqualToString:uuidInSecondArray]) {
                                        [indexesToKeep addIndex:idx];
                                    }
                                }];
                            }
                            NSArray *recordsToKeep = [matchingRecords objectsAtIndexes:indexesToKeep];
                            [matchingRecords removeAllObjects];
                            [matchingRecords addObjectsFromArray:recordsToKeep];
                        } else if ([@"NOT" isEqualToString:operator]) {
                            NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet new];
                            for (NSDictionary *record in results) {
                                NSString *uuidInSecondArray = [record objectForKey:@"uuid"];
                                [matchingRecords enumerateObjectsUsingBlock:^(NSDictionary *potentialRecord, NSUInteger idx, BOOL * _Nonnull stop) {
                                    if ([[potentialRecord objectForKey:@"uuid"] isEqualToString:uuidInSecondArray]) {
                                        [indexesToRemove addIndex:idx];
                                    }
                                }];
                            }
                            [matchingRecords removeObjectsAtIndexes:indexesToRemove];
                            
                        } else {
                            [matchingRecords addObjectsFromArray:results];
                        }
                    }
                }
            }];
            
            if (processError) {
                break;
            }
        }
    } else {
        NSString *matchType = [predicate objectForKey:@"matchType"];
        NSString *recordType = [predicate objectForKey:@"recordType"];
        
        if ([@"any" isEqualToString:matchType]) {
            for (NSDictionary *record in [[self.recordsPerTypeAndUUID objectForKey:recordType] allObjects]) {
                NSMutableDictionary *updateRecord = [record mutableCopy];
                [updateRecord setObject:recordType forKey:@"recordType"];
                [matchingRecords addObject:updateRecord];
            }
            
        } else {
            NSString *attribute = [predicate objectForKey:@"attribute"];
            NSString *equalityRule = [predicate objectForKey:@"equalityRule"];
            NSArray *valueList = [predicate objectForKey:@"valueList"];
            
            
            void (^addMatchingUUIDsWithType)(NSArray*, NSString*) = ^(NSArray *matchingUUIDs, NSString *recordType) {
                for (NSString *recordUUID in matchingUUIDs) {
                    NSMutableDictionary *record = [[[self.recordsPerTypeAndUUID objectForKey:recordType] objectForKey:recordUUID] mutableCopy];
                    [record setObject:recordType forKey:@"recordType"];
                    [matchingRecords addObject:record];
                }
            };
            
            id (^valueConverterForComparaison)(NSString*) = nil;
            
            if ([@"number" isEqualToString:equalityRule]) {
                NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
                
                valueConverterForComparaison = ^id(id originalValue) {
                    if ([originalValue isKindOfClass:[NSNumber class]]) {
                        return originalValue;
                    }
                    return [numberFormatter numberFromString:originalValue];
                };
            } else if ([@"time" isEqualToString:equalityRule]) {
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:nil];
                
                valueConverterForComparaison = ^id(NSString*originalValue) {
                    __block NSDate *date;
                    [detector enumerateMatchesInString:originalValue options:0 range:NSMakeRange(0, [originalValue length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                        date = result.date;
                    }];
                    
                    return date;
                };
            } else if ([@"caseIgnore" isEqualToString:equalityRule]) {
                valueConverterForComparaison = ^id(NSString*originalValue) {
                    return [originalValue lowercaseString];
                };
            } else if ([@"octetMatch" isEqualToString:equalityRule]) {
                valueConverterForComparaison = ^id(NSString*originalValue) {
                    return [originalValue dataUsingEncoding:NSUTF8StringEncoding];
                };
            } else {
                valueConverterForComparaison = ^id(NSString*originalValue) {
                    return originalValue;
                };
            }
            
            NSMutableArray *convertedValueList = [NSMutableArray new];
            
            for (NSString *originalValue in valueList) {
                [convertedValueList addObject:valueConverterForComparaison(originalValue)];
            }
            
            for (id valueToLookFor in convertedValueList) {
                for (id indexedValue in [[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute]) {
                    if ([@"equalTo" isEqualToString:matchType]) {
                        if ([valueConverterForComparaison(indexedValue) isEqualTo:valueToLookFor]) {
                            addMatchingUUIDsWithType([[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:indexedValue], recordType);
                        }
                    } else if ([@"beginsWith" isEqualToString:matchType]) {
                        NSString *valueToLookForAsString = valueToLookFor;
                        NSString *indexedValueAsString = indexedValue;
                        
                        if ([[indexedValueAsString substringToIndex:[valueToLookForAsString length]] isEqualToString:valueToLookForAsString]) {
                            addMatchingUUIDsWithType([[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:indexedValue], recordType);
                        }
                    } else if ([@"endsWith" isEqualToString:matchType]) {
                        NSString *valueToLookForAsString = valueToLookFor;
                        NSString *indexedValueAsString = indexedValue;

                        if ([[indexedValueAsString substringWithRange:NSMakeRange([indexedValueAsString length] - [valueToLookForAsString length], [valueToLookForAsString length])] isEqualToString:valueToLookForAsString]) {
                            addMatchingUUIDsWithType([[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:indexedValue], recordType);
                        }
                    } else if ([@"contains" isEqualToString:matchType]) {
                        NSString *valueToLookForAsString = valueToLookFor;
                        NSString *indexedValueAsString = indexedValue;
                        
                        if ([indexedValueAsString containsString:valueToLookForAsString]) {
                            addMatchingUUIDsWithType([[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:indexedValue], recordType);
                        }
                    } else if ([@"greaterThan" isEqualToString:matchType]) {
                        if ([indexedValue compare:valueToLookFor] == NSOrderedDescending) {
                            addMatchingUUIDsWithType([[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:indexedValue], recordType);
                        }
                    } else if ([@"lessThan" isEqualToString:matchType]) {
                        if ([indexedValue compare:valueToLookFor] == NSOrderedAscending) {
                            addMatchingUUIDsWithType([[[self.indexesForRecordsPerTypeAttributeAndValue objectForKey:recordType] objectForKey:attribute] objectForKey:indexedValue], recordType);
                        }
                    }
                }
            }
        }
    }
    
    if (processError) {
        NSLog(@"Getting all registered records matching specific predicate done with error: %@", processError);
        completionHandler(nil, processError);
    } else {
        NSLog(@"Getting all registered records matching specific predicate done with succes: %lu records returned", (unsigned long)[matchingRecords count]);
        completionHandler(matchingRecords, nil);
    }
    
}

- (void)getAllRegisteredRecordsOfType:(NSString*)recordType withAttributesToReturn:(NSArray<NSString*> *)attributes andCompletionHandler:(EasyLoginDBQueryResult_t)completionHandler {
    NSLog(@"Get all registered records");
    
    NSArray *recordsForRequestedType = [[self.recordsPerTypeAndUUID objectForKey:recordType] allObjects];
    NSMutableArray *requestedRecords = [NSMutableArray new];
    
    for (NSDictionary *record in recordsForRequestedType) {
        NSMutableDictionary *requestedRecord = nil;
        if (attributes) {
            requestedRecord = [NSMutableDictionary new];
            for (NSString* key in attributes) {
                id requestedAttribute = [record objectForKey:key];
                if (requestedAttribute) {
                    [requestedRecord setObject:requestedAttribute forKey:key];
                }
            }
        } else {
            requestedRecord = [NSMutableDictionary dictionaryWithDictionary:record];
        }
        [requestedRecord setObject:recordType forKey:@"recordType"];
        [requestedRecords addObject:requestedRecord];
    }
    
    completionHandler(requestedRecords, nil);
}

- (void)getAllRegisteredUUIDsOfType:(NSString*)recordType andCompletionHandler:(EasyLoginDBUUIDsResult_t)completionHandler {
    NSLog(@"Get all registered UUIDs");
    
    NSArray *uuidsForRequestedType = [[self.recordsPerTypeAndUUID objectForKey:recordType] allKeys];
    
    completionHandler(uuidsForRequestedType, nil);
}

- (void)getRegisteredRecordUUIDsOfType:(NSString*)recordType matchingAllAttributes:(NSDictionary*)attributesWithValues andCompletionHandler:(EasyLoginDBUUIDsResult_t)completionHandler {
    NSLog(@"Get regsiterred records matching all attributes %@", attributesWithValues);
    
    NSMutableArray *validUUIDs = [NSMutableArray new];
    BOOL roundOne = YES;
    
    for (NSString *attribute in [attributesWithValues allKeys]) {
        NSString *value = [attributesWithValues objectForKey:attribute];
        NSArray *matchingUUIDs = [self indexedUUIDsForRecordOfType:recordType withAttribute:attribute setTo:value];
        
        if (roundOne) {
            [validUUIDs addObjectsFromArray:matchingUUIDs];
            roundOne = NO;
        } else {
            NSMutableSet *currentUUIDs = [NSMutableSet setWithArray:validUUIDs];
            NSSet *fetchedUUIDs = [NSSet setWithArray:matchingUUIDs];
            
            [currentUUIDs intersectSet:fetchedUUIDs];
            
            validUUIDs = [[currentUUIDs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"stringValue" ascending:YES]]] mutableCopy];
            
            if ([validUUIDs count] == 0) {
                break;
            }
        }
    }
    completionHandler(validUUIDs, nil);
}

- (void)getRegisteredRecordUUIDsOfType:(NSString*)recordType matchingAnyAttributes:(NSDictionary*)attributesWithValues andCompletionHandler:(EasyLoginDBUUIDsResult_t)completionHandler {
    NSLog(@"Get regsiterred records matching any attributes %@", attributesWithValues);
    
    NSMutableArray *validUUIDs = [NSMutableArray new];
    
    for (NSString *attribute in [attributesWithValues allKeys]) {
        NSString *value = [attributesWithValues objectForKey:attribute];
        NSArray *matchingUUIDs = [self indexedUUIDsForRecordOfType:recordType withAttribute:attribute setTo:value];
        
        [validUUIDs addObjectsFromArray:matchingUUIDs];
    }
    
    completionHandler(validUUIDs, nil);
}

- (void)getRegisteredRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid andCompletionHandler:(EasyLoginDBRecordInfo_t)completionHandler {
    NSLog(@"Get regsiterred record of type %@ with UUID %@", recordType, uuid);
    
    NSDictionary *requestedRecord = [self getRegisteredRecordOfType:recordType withUUID:uuid];
    completionHandler(requestedRecord, nil);
}

- (void)ping {
    NSLog(@"pong");
}

- (void)testXPCConnection:(EasyLoginDBErrorHandler_t)completionHandler {
    NSLog(@"EasyLogin DB recieve test with success");
    completionHandler(nil);
}

@end
