//
//  ELToolbox.m
//  EasyLoginFramework
//
//  Created by Yoann Gini on 21/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ELToolbox.h"

@implementation ELToolbox

+ (NSString *)hardwareUUID
{
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef cfString = NULL;
    
    if (platformExpert) {
        cfString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformUUIDKey), kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }
    
    NSString *string = nil;
    if (cfString) {
        string = [NSString stringWithString:(__bridge NSString *)cfString];
        CFRelease(cfString);
    }
    
    return string;
}

+ (NSString *)serialNumber
{
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef cfString = NULL;
    
    if (platformExpert) {
        cfString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }
    
    NSString *string = nil;
    if (cfString) {
        string = [NSString stringWithString:(__bridge NSString *)cfString];
        CFRelease(cfString);
    }
    
    return string;
}

@end
