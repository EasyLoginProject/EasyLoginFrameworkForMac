//
//  ELWebServiceConnector.h
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//
// This class builds ELNetworkOperation concrete subclass instances, that returns desired data in their completionBlock. Note that you should enqueue the returned operation to actually perform the network call. You can add dependencies, change priority or do anything you need before enqueing the operation. You can enqueue the operation in any NSOperationQueue you want to control serialness or you can use the -enqueueOperation: method to use the default connector queue (which is concurrent by default (use operation dependencies instead)).


#import <Foundation/Foundation.h>

#import "ELRecordProtocol.h"

@class ELNetworkOperation;
@class ELUser;
@class ELRecord;

NS_ASSUME_NONNULL_BEGIN

@interface ELWebServiceConnector : NSObject <NSCopying>

@property(strong, readonly) NSURL *baseURL;
@property(strong, nullable) NSDictionary<NSString *,NSString*> *headers; // operation headers > connector headers
@property(strong, nullable) dispatch_queue_t completionBlockQueue; // completionBlocks will be called on this queue if set. Defaults to nil, which means main queue

-(instancetype)initWithBaseURL:(NSURL *)baseURL headers:(nullable NSDictionary<NSString *,NSString*> *)headers;

@property(nonatomic) NSInteger maxConcurrentOperationCount; // forwards to the internal NSOperationQueue. Defaults to 1 to have a serial queue.

#pragma mark - Type agnostic operations

-(__kindof ELNetworkOperation *)getAllRecordsOperationRelatedToEntityClass:(Class<ELRecordProtocol>)entityClass withCompletionBlock:(nullable void (^)(NSArray<ELRecord*> * _Nullable records, __kindof ELNetworkOperation *op))completionBlock;
-(nullable __kindof ELNetworkOperation *)createNewRecordOperationRelatedToEntityClass:(Class<ELRecordProtocol>)entityClass withDictionary:(NSDictionary<NSString*,id> *)recordInfo completionBlock:(nullable void (^)(ELRecord* _Nullable record, __kindof ELNetworkOperation *op))completionBlock;
-(__kindof ELNetworkOperation *)getPropertiesOperationForRecord:(ELRecord *)record completionBlock:(nullable void (^)(NSDictionary<NSString*,id> * _Nullable userProperties, __kindof ELNetworkOperation *op))completionBlock;

#pragma mark - User Operations

-(__kindof ELNetworkOperation *)getAllUsersOperationWithCompletionBlock:(nullable void (^)(NSArray<ELUser*> * _Nullable users, __kindof ELNetworkOperation *op))completionBlock;
-(nullable __kindof ELNetworkOperation *)createNewUserOperationWithDictionary:(NSDictionary<NSString*,id> *)newUserDictionary completionBlock:(nullable void (^)(ELUser* _Nullable user, __kindof ELNetworkOperation *op))completionBlock;
-(__kindof ELNetworkOperation *)getUserPropertiesOperationForUserIdentifier:(NSString *)userIdentifier completionBlock:(nullable void (^)(NSDictionary<NSString*,id> * _Nullable userProperties, __kindof ELNetworkOperation *op))completionBlock;
//-(__kindof ELNetworkOperation *)updatePropertiesOperation:(NSDictionary<NSString*,id> *)userPropertiesDictionary forUserUniqueId:(NSString *)userUniqueId completionBlock:(nullable void (^)(ELUser* _Nullable updatedUser, __kindof ELNetworkOperation *op))completionBlock; // or updatedPropertiesOperationWithProperties:forUserIdentifier? <- clunky
//-(__kindof ELNetworkOperation *)deleteUserOperationForUserIdentifier:(NSString *)userIdentifier completionBlock:(nullable void (^)(BOOL deleted, __kindof ELNetworkOperation *op))completionBlock;

#pragma mark UserGroups Operations

#pragma mark Roles Operations


#pragma mark - enqueing

-(void)enqueueOperation:(__kindof ELNetworkOperation *)networkOperation;
-(void)enqueueOperations:(NSArray <__kindof ELNetworkOperation*> *)networkOperations; // dependencies should be set between operations if desired.

@end

NS_ASSUME_NONNULL_END
