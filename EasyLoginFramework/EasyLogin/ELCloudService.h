//
//  ELCloudService.h
//  EasyLoginFramework
//
//  Created by Yoann Gini on 11/08/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ELRecordsProvider.h"
#import "ELRemoteRecordsProvider.h"
#import "ELAbstractService.h"

@interface ELCloudService : ELAbstractService <ELRecordsProvider, ELRemoteRecordsProvider>

@end
