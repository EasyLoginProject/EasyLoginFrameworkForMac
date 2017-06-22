//
//  ELNetworkOperation.h
//  EasyLogin
//
//  Created by Aurélien Hugelé on 20/04/16.
//  Copyright © 2016 EasyLogin. All rights reserved.
//
// TODO: handle operation retrying (such as 3x per default with delay?). Should be configurable

#import <Foundation/Foundation.h>

@class ELNetworkOperation;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ELNetworkOperationResponseBlock_t)(ELNetworkOperation *operation, id responseObject, NSError *error);
typedef NSData * _Nullable (^ELNetworkOperationBodyBuilderBlock_t)(void);

@interface ELNetworkOperation : NSOperation <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSProgressReporting>

@property(strong, readonly) NSMutableData *incomingData;
@property(strong, nonatomic) NSURLSessionConfiguration *localConfig; // default to NSURLSessionConfiguration.defaultSessionConfiguration()
@property(readonly, copy) NSString *method; // POST, GET, DELETE...
@property(readonly, copy) NSString *urlString; // http://www.mywebservice.com/api/v2
@property(strong, readonly, nullable) NSDictionary<NSString *, NSString*> *requestParameters; // ?key1=value1&key2=value2...
@property(copy, nullable) NSData *body; // should be set before the operation is enqueued or use bodyBuilderBlock to build body asynchronously, on demand on a the NSOperation's queue
@property(copy, nullable) ELNetworkOperationBodyBuilderBlock_t bodyBuilderBlock; // should be set before the operation is enqueued. Called asynchronously, on demand on the NSOperation's queue to build the body. Auto nullified after use to avoid possible retain cycles
@property(assign) BOOL gzipBody; // Defaults to NO. should be set before the operation is enqueued. Called asynchronously, on the NSOperation's queue, after the bodyBuilderBlock or after the body has been set. It gzip compresses the body and adds "Content-Encoding: gzip" to request headers if body length > 1024 bytes. It compresses the *request body*, it does not handles the responses decompression which is automagically handled by NSURLSession/NSURLConnection!
@property(strong, nullable) NSDictionary *additionalHeaders;  // custom HTTP header fields, should be set before the operation is enqueued. Currently also testing the use of localConfig.HTTPAdditionalHeaders instead?? what difference??
@property(assign) BOOL allowEmptyResponse; // Allows server to only return an HTTP response, but with no body. Defaults to NO. Can be useful when the server responds status 200 OK but with no body instead of something like "true" or "1".

@property(strong) NSProgress *progress;

@property(strong, readonly) NSURLRequest *request;
@property(strong, readonly) NSHTTPURLResponse *response;
@property(strong, readonly, nullable) id responseObject;
@property(strong, nullable) NSError *error; // set readwrite as higher level objects may override error

@property(copy, nullable) ELNetworkOperationResponseBlock_t responseBlock; // note that the response block is called asynchronously, *AFTER* the operation is considered finished! Auto nullified after use to avoid possible retain cycles
@property(strong, nonatomic) dispatch_queue_t responseQueue; // or NSOperationQueue? defaults to nil. nil is main queue

- (instancetype)initWithMethod:(NSString *)method urlString:(NSString *)urlString parameters:(nullable NSDictionary<NSString *, NSString *> *)requestParameters;

NS_ASSUME_NONNULL_END

@end
