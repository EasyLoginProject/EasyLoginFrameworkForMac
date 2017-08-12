//
//  ELCloudService.m
//  EasyLoginFramework
//
//  Created by Yoann Gini on 11/08/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELCloudService.h"
#import "ELServer.h"
#import "ELAbstractService-Private.h"
#import "ELAsyncBlockToManageAsOperation.h"

@implementation ELCloudService

@synthesize alwaysUpdate;

#pragma mark - Public API

- (void)getAllRecordsMatchingPredicates:(NSArray*)predicates withCompletionHandler:(ELRecordsQueryResult)completionHandler {
    NSAssert(YES, @"Not yet implemented");
    // TODO: Implement
}

- (void)getAllRecordsMatchingPredicate:(NSDictionary *)predicate withCompletionHandler:(ELRecordsQueryResult)completionHandler;
{
    NSAssert(YES, @"Not yet implemented");
    // TODO: Implement
}

- (void)getAllRecordsOfType:(NSString*)recordType andCompletionHandler:(ELRecordsQueryResult)completionHandler {
    Class<ELRecordProtocol> selectedEntityClass = NULL;
    if ([recordType isEqualToString:@"user"]) {
        selectedEntityClass = [ELUser recordClass];
    } else {
        NSLog(@"Unsupported record type: %@", recordType);
    }
    
    if (selectedEntityClass == NULL) {
        completionHandler(nil, [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:42 userInfo:@{NSLocalizedDescriptionKey: @"Unsupported record type"}]);
    } else {
        [[ELServer sharedInstance] getAllRecordsWithEntityClass:selectedEntityClass
                                                completionBlock:^(NSArray<__kindof ELRecord *> * _Nullable records, NSError * _Nullable error) {
                                                    if (self.alwaysUpdate) {
                                                        __block NSError *operationError = nil;
                                                        __block NSMutableArray<__kindof ELRecord *> *updatedRecords = [[NSMutableArray alloc] initWithCapacity:[records count]];
                                                        [[ELAsyncBlockToManageAsOperation operationWithAsyncTask:^(ELAsyncBlockToManageAsOperation *currentOperation) {
                                                            for (ELRecord *record in records) {
                                                                [[ELServer sharedInstance] getUpdatedRecord:record
                                                                                            completionBlock:^(__kindof ELRecord * _Nullable updatedRecord, NSError * _Nullable error) {
                                                                                                if (error) {
                                                                                                    operationError = error;
                                                                                                } else {
                                                                                                    [updatedRecords addObject:updatedRecord];
                                                                                                }
                                                                                            }];
                                                            }
                                                        }
                                                                                         withCancelationHandler:^(ELAsyncBlockToManageAsOperation *currentOperation) {
                                                                                             operationError = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:42 userInfo:@{NSLocalizedDescriptionKey: @"Operation canceled"}];
                                                                                         }
                                                                                                     andUserInfo:nil] waitUntilFinished];
                                                        
                                                        if (operationError) {
                                                            completionHandler(nil, operationError);
                                                        } else {
                                                            completionHandler(updatedRecords, nil);
                                                        }
                                                    } else {
                                                        completionHandler(records, error);
                                                    }
                                                }];
    }
}

- (void)getAllIdentifiersOfType:(NSString*)recordType andCompletionHandler:(ELIdentifierQueryResult)completionHandler {
    [[ELServer sharedInstance] getAllRecordsWithEntityClass:[self recordClassForType:recordType]
                                            completionBlock:^(NSArray<__kindof ELRecord *> * _Nullable records, NSError * _Nullable error) {
                                                if (error) {
                                                    completionHandler(nil, error);
                                                } else {
                                                    NSMutableArray *identifiers = [[NSMutableArray alloc] initWithCapacity:[records count]];
                                                    
                                                    for (ELRecord *record in records) {
                                                        [identifiers addObject:record.identifier];
                                                    }
                                                    
                                                    completionHandler(identifiers, nil);
                                                }
                                            }];
}

- (void)getRecordIdentifiersOfType:(NSString*)recordType matchingAllAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(ELIdentifierQueryResult)completionHandler {
    NSAssert(YES, @"Not yet implemented");
    // TODO: Implement
}

- (void)getRecordIdentifiersOfType:(NSString*)recordType matchingAnyAttributes:(NSDictionary<NSString*,NSString*>*)attributesWithValues andCompletionHandler:(ELIdentifierQueryResult)completionHandler {
    NSAssert(YES, @"Not yet implemented");
    // TODO: Implement
}

- (void)getRecordOfType:(NSString*)recordType withUUID:(NSString*)uuid andCompletionHandler:(ELRecordRequestResult)completionHandler {
    [[ELServer sharedInstance] getRecordWithEntityClass:[self recordClassForType:recordType]
                                    andUniqueIdentifier:uuid
                                        completionBlock:completionHandler];
}

- (void)getUpdatedRecord:(ELRecord*)record withCompletionHandler:(ELRecordRequestResult)completionHandler {
    [[ELServer sharedInstance] getUpdatedRecord:record
                                completionBlock:completionHandler];
}

#pragma mark - Private API

@end
