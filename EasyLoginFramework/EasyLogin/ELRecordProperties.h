//
//  ELRecordProperties.h
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 06/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ELRecordPropertiesMapping;

@interface ELRecordProperties : NSObject <NSCopying, NSSecureCoding>

+(nullable instancetype)recordPropertiesWithDictionary:(nonnull NSDictionary*)dictionary mapping:(nullable ELRecordPropertiesMapping*)mapping; // null mapping is allowed to skip any processing on the dictionary
-(nullable instancetype)initWithDictionary:(nonnull NSDictionary*)dictionary mapping:(nullable ELRecordPropertiesMapping*)mapping; // null mapping is allowed to skip any processing on the dictionary

@property(nullable, strong, nonatomic, readonly) ELRecordPropertiesMapping *mapping;
@property(assign, nonatomic, readonly) BOOL mapped;
-(nonnull NSDictionary *)dictionaryRepresentation; // if a mapping was applied on init, then you may want to use -[ELRecordPropertiesMapping doReverseMappingWithCustomDictionary:] on the returned object if you need the original dictionary you passed.

- (nullable id)objectForKey:(nonnull id)aKey;
- (nullable id)objectForKeyedSubscript:(nonnull id)aKey;

-(void)updateWithProperties:(nonnull ELRecordProperties*)updatedProperties deletes:(BOOL)deleteWhenAbsent kvoNotifier:(nullable id)kvoNotifier;

@end


typedef NSDictionary* _Nullable (^ELRecordPropertiesMappingBlock_t)(NSDictionary * _Nullable); /* mapping block could :
                                                                                                           - return nil to mean no processing is needed (keys and values will be used unchanged)
                                                                                                           - return an smaller dictionary to filter out some entries
                                                                                                           - return a custom dictionary (possible different key naming and/or custom values)
                                                                                                           */

@interface ELRecordPropertiesMapping : NSObject

// when mapping raw webservice objects to custom objects, remember they probably should support NSSecureCoding? // currently not enforced.

@property(nullable, copy, nonatomic) NSString *name;

// mapping machinery takes a raw webservice dictionary and transforms it. Typically used to map a ISO8601 date as string in JSON to NSDate. Can also rename the key on the fly or even return multiple key/value entries for one entry.
+(nullable instancetype)mappingWithForwardBlock:(nonnull ELRecordPropertiesMappingBlock_t)forwardBlock reverseBlock:(nonnull ELRecordPropertiesMappingBlock_t)reverseBlock;
-(nullable instancetype)initWithForwardBlock:(nonnull ELRecordPropertiesMappingBlock_t)forwardBlock reverseBlock:(nonnull ELRecordPropertiesMappingBlock_t)reverseBlock;
-(nullable NSDictionary*)doForwardMappingWithRawDictionary:(nonnull NSDictionary*)rawDictionary;
-(nullable NSDictionary*)doReverseMappingWithCustomDictionary:(nonnull NSDictionary*)customDictionary;

@end
