//
//  ELRecord.h
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ELRecordProperties.h"
#import "ELRecordProtocol.h"

#define USE_OBJC_PROPERTIES 0 // 1 to automagically bridge between objc properties and ELRecordProperties

@interface ELRecord : NSObject <NSSecureCoding, ELRecordProtocol>

#if USE_OBJC_PROPERTIES
-(void)__transferFromRecordProperties:(nonnull ELRecordProperties*)recordProperties; // see that later. May not be very clean and can smell bad in the future
#else
-(void)updateWithProperties:(nonnull ELRecordProperties*)updatedProperties deletes:(BOOL)deleteWhenAbsent;
#endif

@end
