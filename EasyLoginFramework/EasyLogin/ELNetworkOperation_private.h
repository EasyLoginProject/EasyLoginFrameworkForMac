//
//  ELNetworkOperation_private.h
//  EasyLogin
//
//  Created by Aurélien Hugelé on 20/04/16.
//  Copyright © 20016 EasyLogin. All rights reserved.
//

#import "ELNetworkOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface ELNetworkOperation ()

@property(strong, readwrite) NSMutableData *incomingData;
@property(strong, nonatomic) NSURLSessionTask *sessionTask;
@property(strong, nonatomic) NSURLSession *localURLSession;
@property(readwrite, copy) NSString *method; // POST, GET, DELETE...
@property(readwrite, copy) NSString *urlString; // http://www.mywebservice.com/api/v2
@property(strong, readwrite, nullable) NSDictionary<NSString *, NSString *> *requestParameters; // ?key1=value1&key2=value2...

@property(strong, readwrite) NSURLRequest *request;
@property(strong, readwrite) NSHTTPURLResponse *response;
@property(strong, readwrite, nullable) id responseObject;
//@property(readwrite) NSError *error;

@property(readwrite, getter=isFinished) BOOL finished; // render the finished property readwrite but maintain KVO on "isFinished"

#pragma mark - Protected, meant to be overriden

-(BOOL)validateResponse:(NSHTTPURLResponse *)response withError:(NSError **)error __attribute__((objc_requires_super));
-(BOOL)processIncomingDataWithError:(NSError **)error;


@end

NS_ASSUME_NONNULL_END
