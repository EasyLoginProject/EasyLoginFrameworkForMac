//
//  ELUser.h
//  EasyLoginMacLib
//
//  Created by Aurélien Hugelé on 03/05/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELRecord.h"

// For explanation about those keys, see https://github.com/EasyLoginProject/EasyLoginSpecs/blob/master/Abstract/UserRecords.md
#define kELUserGivenNameKey @"givenName" // "Brigitte"
#define kELUserSurnameKey @"surname" // "Macron"
#define kELUserPhotoKey @"photo" // NSURL*
#define kELUserFullNameKey @"fullName" // "Mme Macron Brigitte, Marie-Claude, Née Trogneux"
#define kELUserDisplayNameKey @"displayName" // "Brigitte Macron"
#define kELUserCommonNameKey @"commonName" // really depends on the country usage. Typically "Mme MACRON Brigitte" in France.
#define kELUserShortnameKey @"shortname" // aka triname "bma"
#define kELUserPrincipalNameKey @"principalName" // typically a email like identifier used for login. "bma@elysee.fr"
#define kELUserNumericIDKey @"numericID" // integer

#define kELUserEmailKey @"email"
#define kELUserEmailAliasesKey @"emailAliases" // NSArray<NSString*>*

#define kELUserOrganizationAddressKey @"organizationAddress"
#define kELUserOrganizationPostalCodeKey @"organizationPostalCode"
#define kELUserOrganizationCityKey @"organizationCityCode"
#define kELUserOrganizationCountryKey @"organizationCountryCode"

#define kELUserOrganizationPhoneKey @"organizationPhone"
#define kELUserOrganizationMobilePhoneKey @"organizationMobilePhone"
#define kELUserOrganizationInternalPhoneKey @"organizationInternalPhone"

#define kELUserPersonalAddressKey @"personalAddress"
#define kELUserPersonalPostalCodeKey @"personalPostalCode"
#define kELUserPersonalCityKey @"personalCity"
#define kELUserPersonalCountryKey @"personalCountry"
#define kELUserSocialSecurityNumberKey @"ssn"
#define kELUserBirthDateKey @"birthDate"

#define kELUserPersonalMainPhoneKey @"personalMainPhone"
#define kELUserPersonalSecondaryPhoneKey @"personalSecondaryPhone"

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
