//
//  ELLocalRecordsProvider.h
//  EasyLoginFramework
//
//  Created by Yoann Gini on 26/07/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#ifndef ELLocalRecordsProvider_h
#define ELLocalRecordsProvider_h

@protocol ELLocalRecordsProvider <NSObject>

- (void)registerRecord:(ELRecord*)record;
- (void)unregisterRecord:(ELRecord*)record;

@end

#endif /* ELLocalRecordsProvider_h */
