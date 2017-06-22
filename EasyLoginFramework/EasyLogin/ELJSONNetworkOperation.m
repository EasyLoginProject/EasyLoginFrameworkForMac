//
//  ELJSONNetworkOperation.m
//  EasyLogin
//
//  Created by Aurélien Hugelé on 20/04/16.
//  Copyright © 2016 EasyLogin. All rights reserved.
//

#import "ELJSONNetworkOperation.h"
#import "ELNetworkOperation_private.h"

@implementation ELJSONNetworkOperation

-(BOOL)processIncomingDataWithError:(NSError * _Nullable __autoreleasing *)error
{
    // do not call super as it is abstract class
    
    if([self.incomingData length] == 0 && self.allowEmptyResponse == YES) {
        
        return YES;
    }
    
    NSError *jsonError;
    self.responseObject = [NSJSONSerialization JSONObjectWithData:self.incomingData options:NSJSONReadingAllowFragments error:&jsonError];
    if(!self.responseObject)
    {
        if(error) *error = jsonError;
        NSLog(@"%s - NSJSONSerialization error:%@ when parsing:\n%@ for WebService request:(%@)%@",__PRETTY_FUNCTION__,jsonError,[[NSString alloc] initWithData:self.incomingData encoding:NSUTF8StringEncoding],self.request.HTTPMethod,[self.request.URL absoluteString]);
    }
    
    return (self.responseObject != nil);
}

-(BOOL)validateResponse:(NSHTTPURLResponse *)response withError:(NSError * _Nullable __autoreleasing *)error
{
    if(![super validateResponse:response withError:error]) {
        return NO;
    }
    
    // check server Content-Type is JSON
    if(![response.MIMEType isEqualToString:@"application/json"] && ![response.MIMEType isEqualToString:@"text/json"])
    {
        if(error) {
            *error = [NSError errorWithDomain:@"com.EasyLogin.ELJSONNetworkOperation" code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"expected MIME type:json but got:'%@'",response.MIMEType], NSURLErrorFailingURLErrorKey : self.request.URL}];
            
            NSLog(@"%s - Content-Type mismatch for WebService request:(%@)%@ - error:%@",__PRETTY_FUNCTION__,self.request.HTTPMethod,[self.request.URL absoluteString],error?*error:@"<nil error>");
        }
        
        return NO;
    }
    
    return YES;
}

// mainly for debugging
-(NSData *)rawResponseObject
{
    return [NSData dataWithData:self.incomingData];
}

@end
