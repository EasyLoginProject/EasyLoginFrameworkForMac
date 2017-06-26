//
//  ELUser.h
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELRecord.h"

#define kELUserNumericIDKey @"numericID"
#define kELUserSurnameKey @"surname"
#define kELUserFullNameKey @"fullName"
#define kELUserGivenNameKey @"givenName"
#define kELUserPrincipalNameKey @"principalName"
#define kELUserShortnameKey @"shortname"
#define kELUserEmailKey @"email"

@interface ELUser : ELRecord

#if USE_OBJC_PROPERTIES
// I'm still unsure we should use anything else than ELRecordProperties...
@property (strong, nonatomic, nullable) NSNumber *numericID;

@property (strong, nonatomic, nullable) NSString *surname;
@property (strong, nonatomic, nullable) NSString *fullName;
@property (strong, nonatomic, nullable) NSString *givenName;
@property (strong, nonatomic, nullable) NSString *principalName;
@property (strong, nonatomic, nullable) NSString *shortname;

@property (strong, nonatomic, nullable) NSString *email;

@property (strong, nonatomic, nullable) NSDictionary *authMethods;
#endif

@end
