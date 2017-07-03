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
-(void)getUpdatedRecord:(__kindof ELRecord*)record completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable updatedRecord, NSError * _Nullable error))completionBlock; // if record has been deleted on the server, record will be nil and error will have a special error code (currently 500, but should be changed in the future)

-(void)getRecordWithEntityClass:(Class<ELRecordProtocol>)entityClass andUniqueIdentifier:(NSString*)uniqueID completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, NSError * _Nullable error))completionBlock; // if record has been deleted on the server, record will be nil and error will have a special error code (currently 500, but should be changed in the future)

-(void)updateRecord:(ELRecord*)record withUpdatedProperties:(ELRecordProperties*)updatedProperties completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, NSError * _Nullable error))completionBlock; // if record has been deleted on the server, record will be nil and error will have a special error code (currently 500, but should be changed in the future)

-(void)deleteRecord:(__kindof ELRecord*)record completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, NSError * _Nullable error))completionBlock; // if record has ALREADY been deleted on the server, record will be nil and error will have a special error code (currently 500, but should be changed in the future)

-(void)updateRecord:(__kindof ELRecord*)record withNewPassword:(NSString*)requestedPassword usingOldPassword:(NSString*)oldPassword completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable record, NSError * _Nullable error))completionBlock; // if record has been deleted on the server, record will be nil and error will have a special error code (currently 500, but should be changed in the future)

@end

NS_ASSUME_NONNULL_END
