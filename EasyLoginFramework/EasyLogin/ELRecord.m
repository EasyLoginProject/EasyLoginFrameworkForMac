//
//  ELRecord.m
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELRecord.h"
#import <objc/runtime.h>

@interface ELRecord ()

@property(strong, readwrite, nonatomic) ELRecordProperties *properties;
@property(strong, nonatomic, nonnull) NSString *recordEntity;

@end

@implementation ELRecord
{
    NSString * _identifier;
}

+(BOOL)supportsSecureCoding
{
    return YES;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
//        _managedObjectURI = [[aDecoder decodeObjectOfClass:[NSURL class] forKey:@"managedObjectURI"] copy];
        _properties = [aDecoder decodeObjectOfClass:[ELRecordProperties class] forKey:@"properties"];
        _recordEntity = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordEntity"];
        _identifier = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"identifier"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
//    [aCoder encodeObject:_managedObjectURI forKey:@"managedObjectURI"];
    [aCoder encodeObject:_properties forKey:@"properties"];
    [aCoder encodeObject:_recordEntity forKey:@"recordEntity"];
    [aCoder encodeObject:_identifier forKey:@"identifier"];
}


+(nullable instancetype)newRecordWithProperties:(nonnull ELRecordProperties*)properties
{
    return [[self alloc] initWithProperties:properties];
}

-(nullable instancetype)initWithProperties:(ELRecordProperties *)properties
{
    self = [super init];
    if(self) {
        _properties = [properties copy];
        _recordEntity = properties[@"type"]; // type key is too generic. We should use a more specific key in the webservice interals
        _identifier = [_properties objectForKey:[[self class] objectIdentifierKey]];
        if(!_identifier) {
            _identifier = [[NSUUID UUID] UUIDString];
        }
    }
    
    return self;
}

#pragma mark -

+(nonnull NSString*)recordEntity; // default to class name
{
    return NSStringFromClass(self);
}

+(nonnull NSString*)collectionName
{
    return [NSStringFromClass(self) stringByAppendingString:@"s"];
}

+(nonnull NSString*)objectIdentifierKey // "uuid" by default
{
    return @"uuid"; // default identifier key
}

+(nonnull Class<ELRecordProtocol>)recordClass
{
    return [self class];
}

-(NSString *)recordEntity
{
    if([_recordEntity length] > 0) {
        return _recordEntity;
    }
    
    return [[self class] recordEntity];
}

-(NSString*)identifier
{
    return _identifier;
}

-(NSDictionary*)dictionaryRepresentation; // should be NSPropertyListSerialization compatible.
//See how could we embed the entity ?? recordEntity is embedded in the returned dictionary with key: "CDS_recordEntity"
{
    //return @{[[self class] objectIdentifierKey] : self.objectIdentifier};
    //NSMutableDictionary *dictionaryRepresentation = [self.internalDictionaryRepresentation mutableCopy];
    // the dictionary representation should also contain the record entity (key: "CDS_recordEntity")
    
    //study that:  dictionaryRepresentation[@"CDS_recordEntity"] = self.recordEntity;
    
    //return [NSDictionary dictionaryWithDictionary:dictionaryRepresentation];
    
    
    
    return [self.properties dictionaryRepresentation];
}

#if USE_OBJC_PROPERTIES
-(void)__transferFromRecordProperties:(ELRecordProperties*)recordProperties
{
    // see that later. May not be very clean and can smell bad in the future
    
    unsigned int objcPropertiesSize;
    objc_property_t *objcProperties = class_copyPropertyList([self class], &objcPropertiesSize);
    
    for (unsigned int i = 0 ; i < objcPropertiesSize; i++) {
        objc_property_t objcProperty = objcProperties[i];
        NSString *objcPropertyName = [NSString stringWithCString:property_getName(objcProperty) encoding:NSUTF8StringEncoding];
        [self setValue:[recordProperties valueForKey:objcPropertyName] forKey:objcPropertyName];
    }
}
#else 
-(void)updateWithProperties:(nonnull ELRecordProperties*)updatedProperties deletes:(BOOL)deleteWhenAbsent
{
    [self.properties updateWithProperties:updatedProperties deletes:deleteWhenAbsent kvoNotifier:self];
}
#endif

-(id)valueForUndefinedKey:(NSString *)key
{
    if(self.properties != nil) {
#if USE_OBJC_PROPERTIES
        NSLog(@"%s - fallback to properties lookup for undefined keypath:%@",__PRETTY_FUNCTION__,key);
#endif
        return [self.properties valueForKeyPath:key];
    }
    else {
        return [super valueForUndefinedKey:key];
    }
}

-(nullable NSString*)stringForProperty:(nonnull NSString*)key
{
    return [self.properties objectForKey:key];
}

@end
