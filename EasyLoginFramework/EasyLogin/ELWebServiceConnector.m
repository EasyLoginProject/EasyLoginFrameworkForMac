//
//  ELWebServiceConnector.m
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELWebServiceConnector.h"

#import "ELJSONNetworkOperation.h"

#import "ELRecordProperties.h"
#import "ELRecordProtocol.h"

#import "ELUser.h"

@interface ELWebServiceConnector ()

@property NSOperationQueue *networkOperationQueue;

@end

@implementation ELWebServiceConnector

-(instancetype)initWithBaseURL:(NSURL *)baseURL headers:(nullable NSDictionary<NSString *,NSString*> *)headers;
{
    if(self = [super init]) {
        _baseURL = baseURL;
        _headers = headers;
        _completionBlockQueue = dispatch_get_main_queue();
        
        _networkOperationQueue = [[NSOperationQueue alloc] init];
        // make network queue not serial by default!
        _networkOperationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    ELWebServiceConnector *clone = [[[self class] alloc] initWithBaseURL:self.baseURL headers:self.headers];
    clone.maxConcurrentOperationCount = self.maxConcurrentOperationCount;
    
    return clone;
    
}

#pragma mark - Type agnostic operations

-(__kindof ELNetworkOperation *)getAllRecordsOperationRelatedToEntityClass:(Class<ELRecordProtocol>)entityClass withCompletionBlock:(nullable void (^)(NSArray<ELRecord*> * _Nullable records, __kindof ELNetworkOperation *op))completionBlock
{
    ELJSONNetworkOperation *op = [[ELJSONNetworkOperation alloc] initWithMethod:@"GET" urlString:[self absoluteURLStringWithPath:[@"db" stringByAppendingPathComponent:[entityClass collectionName]]] parameters:nil];
    
    // set any custom operation header fields, then call setAdditionalHeadersFromWebServiceConnector:toOperation: to complete (and avoid overriding of headers)
    //op.additionalHeaders = @{"mycustomfield" : @"mycustomvalue"};
    [[self class] setAdditionalHeadersFromWebServiceConnector:self toOperation:op];
    
    op.responseBlock = ^(ELNetworkOperation *operation, id responseObject, NSError *error) {
        if(!responseObject) {
            if(completionBlock)
                dispatch_async(self.completionQueue,^{
                    completionBlock(nil, operation);
                });
            
            return;
        }
        
        NSMutableArray<ELRecord*> *allRecords = [NSMutableArray array];
        [responseObject[[entityClass collectionName]] enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull recordInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            ELRecord *record = [entityClass newRecordWithProperties:[ELRecordProperties recordPropertiesWithDictionary:recordInfo mapping:nil]];
            if(record) {
                [allRecords addObject:record];
            }
        }];
        
        if(completionBlock) {
            dispatch_async(self.completionQueue,^{
                completionBlock(allRecords, operation);
            });
        }
    };
    
    return op;
}

-(nullable __kindof ELNetworkOperation *)createNewRecordOperationRelatedToEntityClass:(Class<ELRecordProtocol>)entityClass withDictionary:(NSDictionary<NSString*,id> *)recordInfo completionBlock:(nullable void (^)(ELRecord* _Nullable record, __kindof ELNetworkOperation *op))completionBlock
{
    NSParameterAssert(recordInfo[@"uuid"] == nil);
    
    ELJSONNetworkOperation *op = [[ELJSONNetworkOperation alloc] initWithMethod:@"POST" urlString:[self absoluteURLStringWithPath:[@"db" stringByAppendingPathComponent:[entityClass collectionName]]] parameters:nil];
    
    NSError *jsonError;
    op.body = [NSJSONSerialization dataWithJSONObject:recordInfo options:0 error:&jsonError];
    if(op.body == nil && completionBlock) {
        op.error = jsonError;
        dispatch_async(self.completionQueue,^{
            completionBlock(nil, op);
        });
        
        return nil;
    }
    // set any custom operation header fields, then call setAdditionalHeadersFromWebServiceConnector:toOperation: to complete (and avoid overriding of headers)
    //op.additionalHeaders = @{"mycustomfield" : @"mycustomvalue"};
    op.additionalHeaders = @{@"Content-Type" : @"application/json"};
    [[self class] setAdditionalHeadersFromWebServiceConnector:self toOperation:op];
    
    op.responseBlock = ^(ELNetworkOperation *operation, id responseObject, NSError *error) {
        if(!responseObject) {
            if(completionBlock)
                dispatch_async(self.completionQueue,^{
                    completionBlock(nil, operation);
                });
            
            return;
        }
        
        //NSAssert([responseObject[@"type"] isEqualToString:@"user"], @"Invalid 'type' value returned by WebService. Should have been 'user'");
        
        // TODO: remove 'type' entry ? any root object?
        ELRecord *record = [entityClass newRecordWithProperties:[ELRecordProperties recordPropertiesWithDictionary:responseObject mapping:nil]];
        
        if(completionBlock) {
            dispatch_async(self.completionQueue,^{
                completionBlock(record, operation);
            });
        }
    };
    
    return op;

}

-(__kindof ELNetworkOperation *)getPropertiesOperationForRecord:(ELRecord *)record completionBlock:(nullable void (^)(NSDictionary<NSString*,id> * _Nullable userProperties, __kindof ELNetworkOperation *op))completionBlock
{
    NSParameterAssert(record.identifier != nil);
    
    ELJSONNetworkOperation *op = [[ELJSONNetworkOperation alloc] initWithMethod:@"GET" urlString:[self absoluteURLStringWithPath:[[@"db" stringByAppendingPathComponent:[[record class] collectionName]] stringByAppendingPathComponent:record.identifier]] parameters:nil];
    
    // set any custom operation header fields, then call setAdditionalHeadersFromWebServiceConnector:toOperation: to complete (and avoid overriding of headers)
    //op.additionalHeaders = @{"mycustomfield" : @"mycustomvalue"};
    [[self class] setAdditionalHeadersFromWebServiceConnector:self toOperation:op];
    
    op.responseBlock = ^(ELNetworkOperation *operation, id responseObject, NSError *error) {
        if(!responseObject) {
            if(completionBlock)
                dispatch_async(self.completionQueue,^{
                    completionBlock(nil, operation);
                });
            
            return;
        }
        
        // TODO: remove 'type' entry ? any root object ?
        if(completionBlock) {
            dispatch_async(self.completionQueue,^{
                completionBlock(responseObject, operation);
            });
        }
    };
    
    return op;
}

#pragma mark - User Operations

-(__kindof ELNetworkOperation *)getAllUsersOperationWithCompletionBlock:(nullable void (^)(NSArray<ELUser*> * _Nullable users, __kindof ELNetworkOperation *op))completionBlock
{
    ELJSONNetworkOperation *op = [[ELJSONNetworkOperation alloc] initWithMethod:@"GET" urlString:[self absoluteURLStringWithPath:@"db/users"] parameters:nil];
    
    // set any custom operation header fields, then call setAdditionalHeadersFromWebServiceConnector:toOperation: to complete (and avoid overriding of headers)
    //op.additionalHeaders = @{"mycustomfield" : @"mycustomvalue"};
    [[self class] setAdditionalHeadersFromWebServiceConnector:self toOperation:op];
    
    op.responseBlock = ^(ELNetworkOperation *operation, id responseObject, NSError *error) {
        if(!responseObject) {
            if(completionBlock)
                dispatch_async(self.completionQueue,^{
                    completionBlock(nil, operation);
                });
            
            return;
        }
        
        NSMutableArray<ELUser*> *allUsers = [NSMutableArray array];
        [responseObject[@"users"] enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull userDictionary, NSUInteger idx, BOOL * _Nonnull stop) {
            ELUser *user = [[ELUser alloc] initWithProperties:[ELRecordProperties recordPropertiesWithDictionary:userDictionary mapping:nil]];
            if(user) {
                [allUsers addObject:user];
            }
        }];
        
        if(completionBlock) {
            dispatch_async(self.completionQueue,^{
                completionBlock(allUsers, operation);
            });
        }
    };
    
    return op;
}

-(nullable __kindof ELNetworkOperation *)createNewUserOperationWithDictionary:(NSDictionary<NSString*,id> *)newUserDictionary completionBlock:(nullable void (^)(ELUser* _Nullable user, __kindof ELNetworkOperation *op))completionBlock
{
    NSParameterAssert(newUserDictionary[@"uuid"] == nil);
                      
    ELJSONNetworkOperation *op = [[ELJSONNetworkOperation alloc] initWithMethod:@"POST" urlString:[self absoluteURLStringWithPath:@"db/users"] parameters:nil];
    
    NSError *jsonError;
    op.body = [NSJSONSerialization dataWithJSONObject:newUserDictionary options:0 error:&jsonError];
    if(op.body == nil && completionBlock) {
        op.error = jsonError;
        dispatch_async(self.completionQueue,^{
            completionBlock(nil, op);
        });
        
        return nil;
    }
    // set any custom operation header fields, then call setAdditionalHeadersFromWebServiceConnector:toOperation: to complete (and avoid overriding of headers)
    //op.additionalHeaders = @{"mycustomfield" : @"mycustomvalue"};
    op.additionalHeaders = @{@"Content-Type" : @"application/json"};
    [[self class] setAdditionalHeadersFromWebServiceConnector:self toOperation:op];
    
    op.responseBlock = ^(ELNetworkOperation *operation, id responseObject, NSError *error) {
        if(!responseObject) {
            if(completionBlock)
                dispatch_async(self.completionQueue,^{
                    completionBlock(nil, operation);
                });
            
            return;
        }
        
        //NSAssert([responseObject[@"type"] isEqualToString:@"user"], @"Invalid 'type' value returned by WebService. Should have been 'user'");
        
        // TODO: remove 'type' entry ? any root object?
        ELUser *user = [[ELUser alloc] initWithProperties:[ELRecordProperties recordPropertiesWithDictionary:responseObject mapping:nil]];
        
        if(completionBlock) {
            dispatch_async(self.completionQueue,^{
                completionBlock(user, operation);
            });
        }
    };
    
    return op;
}

-(__kindof ELNetworkOperation *)getUserPropertiesOperationForUserIdentifier:(NSString *)userIdentifier completionBlock:(nullable void (^)(NSDictionary<NSString*,id> * _Nullable userProperties, __kindof ELNetworkOperation *op))completionBlock
{
    NSParameterAssert(userIdentifier != nil);
    
    ELJSONNetworkOperation *op = [[ELJSONNetworkOperation alloc] initWithMethod:@"GET" urlString:[self absoluteURLStringWithPath:[@"db/users" stringByAppendingPathComponent:userIdentifier]] parameters:nil];
    
    // set any custom operation header fields, then call setAdditionalHeadersFromWebServiceConnector:toOperation: to complete (and avoid overriding of headers)
    //op.additionalHeaders = @{"mycustomfield" : @"mycustomvalue"};
    [[self class] setAdditionalHeadersFromWebServiceConnector:self toOperation:op];
    
    op.responseBlock = ^(ELNetworkOperation *operation, id responseObject, NSError *error) {
        if(!responseObject) {
            if(completionBlock)
                dispatch_async(self.completionQueue,^{
                    completionBlock(nil, operation);
                });
            
            return;
        }
        
        // TODO: remove 'type' entry ? any root object ?
        if(completionBlock) {
            dispatch_async(self.completionQueue,^{
                completionBlock(responseObject, operation);
            });
        }
    };
    
    return op;
}


#pragma mark - Queue - Enqueue

-(void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    _networkOperationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

-(NSInteger)maxConcurrentOperationCount
{
    return _networkOperationQueue.maxConcurrentOperationCount;
}

-(dispatch_queue_t)completionQueue
{
    dispatch_queue_t completionQueue;
    @synchronized (self) {
        completionQueue = _completionBlockQueue;
    }
    return completionQueue;
}

-(void)setCompletionQueue:(dispatch_queue_t)completionQueue
{
    @synchronized (self) {
        if(completionQueue == nil)
            _completionBlockQueue = dispatch_get_main_queue();
        else
            _completionBlockQueue = completionQueue;
    }
}

-(void)enqueueOperation:(__kindof ELNetworkOperation *)networkOperation
{
    [_networkOperationQueue addOperation:networkOperation];
}

-(void)enqueueOperations:(NSArray <__kindof ELNetworkOperation*> *)networkOperations; // dependencies should be set between operations if desired.
{
    [_networkOperationQueue addOperations:networkOperations waitUntilFinished:NO];
}


#pragma mark - Private

-(NSString*)absoluteURLStringWithPath:(NSString *)path
{
    return [[NSURL URLWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]] relativeToURL:self.baseURL] absoluteString];
}

// Adds basic headers and the connector headers to the operation headers if not already existing
+(void)setAdditionalHeadersFromWebServiceConnector:(nullable ELWebServiceConnector *)connector toOperation:(ELNetworkOperation*)operation
{
    // only set the operation additional header fields/values if not already set (ie does not override any existing value)
    NSMutableDictionary *additionalHeaders = [[operation additionalHeaders] mutableCopy];
    if(!additionalHeaders) {
        additionalHeaders = [NSMutableDictionary dictionary];
    }
    
    NSDictionary *connectorHeaders = connector.headers;
    for (NSString *connectorHeaderKey in connectorHeaders) {
        if(additionalHeaders[connectorHeaderKey] == nil) {
            additionalHeaders[connectorHeaderKey] = connectorHeaders[connectorHeaderKey];
        }
    }
    
    // NOTE: Totally unused/fake headers, but demonstrate how to cumulate (per) operation headers, (per) connector headers and global headers (operation > connector > global)
    NSDictionary *globalHeaders = @{@"apiVersion" : @"1",
                                    @"libVersion" : /*[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey]*/@"0", // how to get lib version at compile time?
                                    @"clientType" : @"macos"
                                    };
    for (NSString *globalHeaderKey in globalHeaders) {
        if(additionalHeaders[globalHeaderKey] == nil) {
            additionalHeaders[globalHeaderKey] = globalHeaders[globalHeaderKey];
        }
    }
    
    operation.additionalHeaders = [additionalHeaders copy];
}


@end
