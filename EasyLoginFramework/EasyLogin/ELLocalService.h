//
//  ELLocalService.h
//  EasyLoginFramework
//
//  Created by Yoann Gini on 11/08/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ELRecordsProvider.h"
#import "ELLocalRecordsProvider.h"
#import "ELAbstractService.h"

@interface ELLocalService : ELAbstractService <ELRecordsProvider, ELLocalRecordsProvider>

@end
