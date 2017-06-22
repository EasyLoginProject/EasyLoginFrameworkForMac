//
//  ELJSONNetworkOperation.h
//  EasyLogin
//
//  Created by Aurélien Hugelé on 20/04/16.
//  Copyright © 2016 EasyLogin. All rights reserved.
//

#import "ELNetworkOperation.h"

@interface ELJSONNetworkOperation : ELNetworkOperation

@property(strong, readonly, nullable) NSData* rawResponseObject; // mainly for debugging, returns incomingData (as immutable NSData*).

@end
