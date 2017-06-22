//
//  ELDevice.h
//  EasyLoginMacLib
//
//  Created by Yoann Gini on 21/06/2017.
//  Copyright © 2017 GroundControl. All rights reserved.
//

#import "ELRecord.h"

#define kELDeviceNameKey @"deviceName"
#define kELDeviceSerialNumberKey @"serialNumber"
#define kELDeviceHardwareUUIDKey @"hardwareUUID"
#define kELDeviceSyncSetModeKey @"cdsSelectionMode"

@interface ELDevice : ELRecord

@end
