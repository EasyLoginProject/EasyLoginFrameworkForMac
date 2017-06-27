//
//  ELServer.h
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 19/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ELRecordProtocol.h"

@class ELWebServiceConnector;
@class ELRecord;
@class ELRecordProperties;

#define kELServerUpdateNotification @"ELServerUpdateNotification"

NS_ASSUME_NONNULL_BEGIN

@interface ELServer : NSObject

@property(strong, readonly) NSURL *baseURL;
@property(strong, readonly) ELWebServiceConnector *connector;

+ (instancetype)sharedInstance;
-(instancetype)initWithBaseURL:(NSURL *)baseURL; // creates a default ELWebServiceConnector that you can tweak.

-(void)createNewRecordWithEntityClass:(Class<ELRecordProtocol>)entityClass properties:(ELRecordProperties*)properties/*or do we want a basic NSDictionary?*/ completionBlock:(nullable void (^)(__kindof ELRecord* _Nullable newRecord, NSError * _Nullable error))completionBlock;

-(void)getAllRecordsWithEntityClass:(Class<ELRecordProtocol>)entityClass completionBlock:(nullable void (^)(NSArray<__kindof ELRecord*> * _Nullable records, NSError * _Nullable error))completionBlock;
-(void)getUpdatedRecord:(__kindof ELRecord*)record completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable updatedRecord, NSError * _Nullable error))completionBlock; // updatedRecord may be nil if the record was deleted on the server?

-(void)getRecordWithEntityClass:(Class<ELRecordProtocol>)entityClass andUniqueIdentifier:(NSString*)uniqueID completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, NSError * _Nullable error))completionBlock; // updatedRecord may be nil if the record was deleted on the server?

-(void)updateRecord:(ELRecord*)record withUpdatedProperties:(ELRecordProperties*)updatedProperties completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, BOOL success, NSError * _Nullable error))completionBlock; // success may be NO if the record was deleted on the server?

-(void)updateRecord:(__kindof ELRecord*)record withNewPassword:(NSString*)requestedPassword usingOldPassword:(NSString*)oldPassword completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, BOOL success, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
