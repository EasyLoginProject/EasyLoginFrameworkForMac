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
#import <SocketRocket/SocketRocket.h>

@interface ELServer () <SRWebSocketDelegate>

@property(strong, readwrite) NSURL *baseURL;
@property(strong, readwrite) ELWebServiceConnector *connector;
@property(strong, readwrite) SRWebSocket *webSocket;

@end

@implementation ELServer

-(instancetype)initWithBaseURL:(NSURL *)baseURL // creates a default ELWebServiceConnector that you can tweak.
{
    self = [super init];
    if(self) {
        _baseURL = baseURL;
        _connector = [[ELWebServiceConnector alloc] initWithBaseURL:baseURL headers:nil];
        
        [self openWebsocket];

        if(_connector == nil) {
            return nil;
        }
    }
    
    return self;
}

#pragma mark - WebSocket

- (void)openWebsocket {
    if (self.webSocket) {
        return;
    }
    
    NSURL *wsURL = [NSURL URLWithString:[NSString stringWithFormat:@"/notifications"]
                          relativeToURL:self.baseURL];
    self.webSocket = [[SRWebSocket alloc] initWithURL:wsURL];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"EasyLogin connected with success to server update stream");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"EasyLogin connected with error to server update stream: %@", error);
    self.webSocket = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openWebsocket];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(nonnull NSString *)string {
    NSLog(@"EasyLogin recieved and update notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:kELServerUpdateNotification object:self];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"EasyLogin update stream closed: %@", reason);
    self.webSocket = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self openWebsocket];
    });
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"EasyLogin update stream played ping-pong");
}


#pragma mark -

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
