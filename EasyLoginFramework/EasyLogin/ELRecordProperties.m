//
//  ELRecordProperties.m
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 06/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELRecordProperties.h"

@interface ELRecordProperties ()

@property(strong, nonatomic) NSMutableDictionary *internalDictionary;
@property(nullable, strong, nonatomic, readwrite) ELRecordPropertiesMapping *mapping;
@property(assign, nonatomic, readwrite) BOOL mapped;
@property(copy, nonatomic, readwrite) NSString *mappingName;

@end

@implementation ELRecordProperties

+(BOOL)supportsSecureCoding
{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        _internalDictionary = [aDecoder decodeObjectOfClass:[NSMutableDictionary class] forKey:@"internalDictionary"];
        _mapped = [aDecoder decodeBoolForKey:@"mapped"];
        _mappingName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"mappingName"];
        // at this time it is not possible to store the mapping itself because of blocks, mapping name should help recreate the ELRecordMapping object
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_internalDictionary forKey:@"internalDictionary"];
    [aCoder encodeBool:_mapped forKey:@"mapped"];
    [aCoder encodeObject:_mappingName forKey:@"mappingName"];
    // at this time it is not possible to store the mapping itself because of blocks, mapping name should help recreate the ELRecordMapping object
}

-(id)copyWithZone:(NSZone *)zone
{
    ELRecordProperties *copy = [[[self class] alloc] initWithDictionary:_internalDictionary mapping:nil];
    copy.mapped = self.mapped;
    copy.mappingName = self.mappingName;
    copy.mapping = self.mapping; // should be copied?
    
    return copy;
}


+(nullable instancetype)recordPropertiesWithDictionary:(nonnull NSDictionary*)dictionary mapping:(nullable ELRecordPropertiesMapping*)mapping
{
    return [[self alloc] initWithDictionary:dictionary mapping:mapping];
}

-(nullable instancetype)initWithDictionary:(nonnull NSDictionary*)dictionary mapping:(nullable ELRecordPropertiesMapping*)mapping;
{
    self = [super init];
    if(self) {
        if(!mapping) {
            _internalDictionary = [dictionary mutableCopy];
            _mapped = NO;
            _mappingName = nil;
        }
        else {
            _internalDictionary = [[mapping doForwardMappingWithRawDictionary:dictionary] mutableCopy];
            _mapped = YES;
            _mappingName = [[mapping name] copy];
            _mapping = mapping;
        }
    }
    
    return self;
}

-(void)updateWithProperties:(nonnull ELRecordProperties*)updatedProperties deletes:(BOOL)deleteWhenAbsent kvoNotifier:(nullable id)kvoNotifier
{
    if(deleteWhenAbsent) {
        NSMutableArray *propertiesToRemove = [NSMutableArray array];
        [_internalDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if([updatedProperties objectForKey:key] == nil) {
                [propertiesToRemove addObject:key];
            }
        }];
        
        [propertiesToRemove enumerateObjectsUsingBlock:^(id  _Nonnull keyToRemove, NSUInteger idx, BOOL * _Nonnull stop) {
            [kvoNotifier willChangeValueForKey:keyToRemove];
            [_internalDictionary removeObjectForKey:keyToRemove];
            [kvoNotifier didChangeValueForKey:keyToRemove];
        }];
    }
    
    [[updatedProperties dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [kvoNotifier willChangeValueForKey:key];
        [_internalDictionary setObject:obj forKey:key];
        [kvoNotifier didChangeValueForKey:key];
    }];
}

-(NSDictionary *)dictionaryRepresentation
{
    return [NSDictionary dictionaryWithDictionary:_internalDictionary];
}

- (nullable id)objectForKey:(nonnull id)aKey
{
    return [_internalDictionary objectForKey:aKey];
}

- (nullable id)objectForKeyedSubscript:(nonnull id)aKey
{
    return [_internalDictionary objectForKey:aKey];
}

-(id)valueForKey:(NSString *)key
{
    return [_internalDictionary valueForKey:key];
}

-(id)valueForKeyPath:(NSString *)keyPath
{
    return [_internalDictionary valueForKeyPath:keyPath];
}

-(void)setValue:(id)value forKey:(NSString *)key
{
    [_internalDictionary setValue:value forKey:key];
}

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath
{
    [_internalDictionary setValue:value forKeyPath:keyPath];
}

@end

#pragma mark -

@implementation ELRecordPropertiesMapping
{
    ELRecordPropertiesMappingBlock_t _forwardBlock;
    ELRecordPropertiesMappingBlock_t _reverseBlock;
}

// when mapping raw webservice objects to  custom objects, remember they probably should support NSSecureCoding? // currently not enforced.

+(nullable instancetype)mappingWithForwardBlock:(nonnull ELRecordPropertiesMappingBlock_t)forwardBlock reverseBlock:(nonnull ELRecordPropertiesMappingBlock_t)reverseBlock;
{
    return [[self alloc] initWithForwardBlock:forwardBlock reverseBlock:reverseBlock];
}

-(nullable instancetype)initWithForwardBlock:(nonnull ELRecordPropertiesMappingBlock_t)forwardBlock reverseBlock:(nonnull ELRecordPropertiesMappingBlock_t)reverseBlock
{
    self = [super  init];
    if(self) {
        _forwardBlock = [forwardBlock copy];
        _reverseBlock = [reverseBlock copy];
    }
    
    return self;
}

-(nullable NSDictionary*)doForwardMappingWithRawDictionary:(nonnull NSDictionary*)rawDictionary
{
    if(!_forwardBlock) return nil;
    
    return _forwardBlock(rawDictionary);
}

-(nullable NSDictionary*)doReverseMappingWithCustomDictionary:(nonnull NSDictionary*)customDictionary
{
    if(!_reverseBlock) return nil;
    
    return _reverseBlock(customDictionary);
}


@end
