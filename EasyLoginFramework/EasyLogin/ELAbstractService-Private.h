//
//  ELAbstractService-Private.h
//  EasyLoginFramework
//
//  Created by Yoann Gini on 11/08/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#ifndef ELAbstractService_Private_h
#define ELAbstractService_Private_h

#import "ELRecordProtocol.h"
#import "ELRecord.h"

@interface ELAbstractService (Private)

-(Class<ELRecordProtocol>)recordClassForType:(NSString *)recordType;
- (ELRecord*)recordWithDictionary:(NSDictionary*)infos;

@end

#endif /* ELAbstractService_Private_h */
