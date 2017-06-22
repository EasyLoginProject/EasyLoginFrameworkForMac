//
//  ELServer.m
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 19/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELServer.h"

#import "ELWebServiceConnector.h"
#import "ELRecord.h"
#import "ELUser.h"
#import "ELDevice.h"
#import "ELRecordProperties.h"

#import "ELNetworkOperation.h"

@interface ELServer ()

@property(strong, readwrite) NSURL *baseURL;
@property(strong, readwrite) ELWebServiceConnector *connector;

@end

@implementation ELServer

-(instancetype)initWithBaseURL:(NSURL *)baseURL // creates a default ELWebServiceConnector that you can tweak.
{
    self = [super init];
    if(self) {
        _baseURL = baseURL;
        _connector = [[ELWebServiceConnector alloc] initWithBaseURL:baseURL headers:nil];
        
        if(_connector == nil) {
            return nil;
        }
    }
    
    return self;
}

-(void)createNewRecordWithEntity:(NSString *)entity properties:(ELRecordProperties*)properties/*or do we want a basic NSDictionary?*/ completionBlock:(nullable void (^)(__kindof ELRecord* _Nullable newRecord, NSError * _Nullable error))completionBlock
{
    if(entity == nil || [entity isEqualToString:[ELRecord recordEntity]]) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid entity"];
    }
    
    // TODO: switch to another branching system when we'll have many entities...
    
    if([entity isEqualToString:[ELUser recordEntity]]) {
        if(properties.mapped == YES) {
            [NSException raise:NSInvalidArgumentException format:@"ELRecordProperties reverse mapping can't be applied automagically. You should create another ELRecordProperties unmapped object, that can be inited with the reverse mapped dictionary..."]; // to be clear, ELRecordProperties can't embed the mapping object since it's block based and very hard to encode with NSCoding...
        }
        ELNetworkOperation *op = [_connector createNewUserOperationWithDictionary:[properties dictionaryRepresentation] completionBlock:^(ELUser * _Nullable user, __kindof ELNetworkOperation * _Nonnull op) {
            if(completionBlock) completionBlock(user, op.error);
        }];
        [_connector enqueueOperation:op];
    }
    //    else if([entity isEqualToString:[ELDevice recordEntity]) {
    //
    //    }
    //    ...
    
}

-(void)createNewRecordWithEntityClass:(Class<ELRecordProtocol>)entityClass properties:(ELRecordProperties*)properties/*or do we want a basic NSDictionary?*/ completionBlock:(nullable void (^)(__kindof ELRecord* _Nullable newRecord, NSError * _Nullable error))completionBlock
{
    // TODO: switch to another branching system when we'll have many entities...
    
    if(properties.mapped == YES) {
        [NSException raise:NSInvalidArgumentException format:@"ELRecordProperties reverse mapping can't be applied automagically. You should create another ELRecordProperties unmapped object, that can be inited with the reverse mapped dictionary..."]; // to be clear, ELRecordProperties can't embed the mapping object since it's block based and very hard to encode with NSCoding...
    }
    
    ELNetworkOperation *op = [_connector createNewRecordOperationRelatedToEntityClass:entityClass withDictionary:[properties dictionaryRepresentation] completionBlock:^(ELRecord * _Nullable record, __kindof ELNetworkOperation * _Nonnull op) {
        if(completionBlock) completionBlock(record, op.error);
    }];
    [_connector enqueueOperation:op];
}

-(void)getAllRecordsWithEntity:(NSString *)entity completionBlock:(nullable void (^)(NSArray<__kindof ELRecord*> * _Nullable records, NSError * _Nullable error))completionBlock
{
    if(entity == nil || [entity isEqualToString:[ELRecord recordEntity]]) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid entity"];
    }
    
    // TODO: switch to another branching system when we'll have many entities...
    
    if([entity isEqualToString:[ELUser recordEntity]]) {
        ELNetworkOperation *op = [_connector getAllUsersOperationWithCompletionBlock:^(NSArray<ELUser *> * _Nullable users, __kindof ELNetworkOperation * _Nonnull op) {
            if(completionBlock) completionBlock(users, op.error);
        }];
        [_connector enqueueOperation:op];
    }
    //    else if([entity isEqualToString:[ELDevice recordEntity]) {
    //
    //    }
    //    ...
}

-(void)getAllRecordsWithEntityClass:(Class<ELRecordProtocol>)entityClass completionBlock:(nullable void (^)(NSArray<__kindof ELRecord*> * _Nullable records, NSError * _Nullable error))completionBlock
{
    ELNetworkOperation *op = [_connector getAllRecordsOperationRelatedToEntityClass:entityClass withCompletionBlock:^(NSArray<ELUser *> * _Nullable users, __kindof ELNetworkOperation * _Nonnull op) {
        if(completionBlock) completionBlock(users, op.error);
    }];
    [_connector enqueueOperation:op];
}

-(void)getUpdatedRecord:(ELRecord*)record completionBlock:(nullable void (^)(__kindof ELRecord * _Nullable updatedRecord, NSError * _Nullable error))completionBlock // updatedRecord may be nil if the record was deleted on the server?
{
    if([record.recordEntity isEqualToString:[ELRecord recordEntity]]) {
        [NSException raise:NSInvalidArgumentException format:@"Invalid entity"];
    }
    
    // TODO: switch to another branching system when we'll have many entities...
    
    if([record.recordEntity isEqualToString:[ELUser recordEntity]]) {
        ELNetworkOperation *op = [_connector getUserPropertiesOperationForUserIdentifier:record.identifier completionBlock:^(NSDictionary<NSString *,id> * _Nullable userProperties, __kindof ELNetworkOperation * _Nonnull op) {
            if(userProperties == nil) {
                if(completionBlock) completionBlock(nil, op.error); // the record may have been deleted? treat this as a special case? maybe not an error?
                
                return;
            }
            
            ELRecordProperties *updatedRecordProperties = [ELRecordProperties recordPropertiesWithDictionary:userProperties mapping:nil];
            // By default, we're on main thread, which may not be ideal for all scenarios, but good for KVO/Bindings.
#if USE_OBJC_PROPERTIES
            [record __transferFromRecordProperties:updatedRecordProperties];
#else
            [record updateWithProperties:updatedRecordProperties deletes:YES];
#endif
            
            if(completionBlock) completionBlock(record, nil);
        }];
        [_connector enqueueOperation:op];
    } else {
        ELNetworkOperation *op = [_connector getPropertiesOperationForRecord:record completionBlock:^(NSDictionary<NSString *,id> * _Nullable userProperties, __kindof ELNetworkOperation * _Nonnull op) {
            if(userProperties == nil) {
                if(completionBlock) completionBlock(nil, op.error); // the record may have been deleted? treat this as a special case? maybe not an error?
                
                return;
            }
            
            ELRecordProperties *updatedRecordProperties = [ELRecordProperties recordPropertiesWithDictionary:userProperties mapping:nil];
            // By default, we're on main thread, which may not be ideal for all scenarios, but good for KVO/Bindings.
#if USE_OBJC_PROPERTIES
            [record __transferFromRecordProperties:updatedRecordProperties];
#else
            [record updateWithProperties:updatedRecordProperties deletes:YES];
#endif
            
            if(completionBlock) completionBlock(record, nil);
        }];
        [_connector enqueueOperation:op];

    }
    //    else if([entity isEqualToString:[ELDevice recordEntity]) {
    //
    //    }
    //    ...
    
}

@end
