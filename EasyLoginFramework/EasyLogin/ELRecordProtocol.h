//
//  ELRecordProtocol.h
//  EasyLoginMacLib
//
//  Created by Yoann Gini on 21/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

#ifndef ELRecordProtocol_h
#define ELRecordProtocol_h

@class ELRecordProperties;

@protocol ELRecordProtocol <NSObject>

+(nonnull NSString*)recordEntity; // default to class name. Maybe hardcoded to match the managedObject entity?
+(nonnull NSString*)objectIdentifierKey; // "uuid" by default
+(nonnull NSString*)collectionName; // related collection name under /db on the server
+(nonnull Class<ELRecordProtocol>)recordClass;

+(nullable instancetype)newRecordWithProperties:(nonnull ELRecordProperties*)properties;
-(nullable instancetype)initWithProperties:(nonnull ELRecordProperties*)properties;

-(nonnull NSString*)recordEntity; // default to value of key 'type' in dictionary. Fallback to class name, should match the managedObjectEntity. nonatomic
-(nonnull NSString*)identifier; // fetch value of key returned by class method 'objectIdentifierKey'
@property(strong, readonly, nonatomic, nonnull) ELRecordProperties *properties;

-(nonnull NSDictionary*)dictionaryRepresentation; // should be NSPropertyListSerialization compatible.
                                                  //See how could we embed the entity ?? recordEntity is embedded in the returned dictionary with key: "CDS_recordEntity"

-(nullable NSString*)stringForProperty:(nonnull NSString*)key;

@end

#endif /* ELRecordProtocol_h */
