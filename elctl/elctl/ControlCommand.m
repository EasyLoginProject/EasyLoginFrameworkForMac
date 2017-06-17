//
//  ControlCommand.m
//  elctl
//
//  Created by Yoann Gini on 17/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import "ControlCommand.h"
#import <EasyLogin/EasyLogin.h>

#define kSupportedActions @[@"list", @"read", @"forget"]

@interface ControlCommand ()

@property NSString *action;
@property NSString *recordType;
@property NSString *recordUUID;

@end

@implementation ControlCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.action = [[NSUserDefaults standardUserDefaults] stringForKey:@"action"];
        self.recordType = [[NSUserDefaults standardUserDefaults] stringForKey:@"recordType"];
        self.recordUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"recordUUID"];
        
    }
    return self;
}

- (int)run {
    int returnedStatus = [self checkCommonRequierements];
    
    if (EXIT_SUCCESS != returnedStatus) {
        return returnedStatus;
    }
    
    if ([@"list" isEqualToString:self.action]) {
        return [self runListAction];
        
    } else if ([@"read" isEqualToString:self.action]) {
        return [self runReadAction];
        
    } else if ([@"forget" isEqualToString:self.action]) {
        return [self runForgetAction];
        
    }
    
    [self showHelpAsError:NO];
    
    return EXIT_FAILURE;
}

- (int)checkCommonRequierements {
    
    if (![kSupportedActions containsObject:self.action]) {
        fprintf(stderr, "You must specify an action to run this tool\n");
        
        [self showHelpAsError:YES];
        
        return EXIT_FAILURE;
    }
    
    if ([@[@"read", @"forget"] containsObject:self.action]) {
        if ([self.recordType length] == 0) {
            fprintf(stderr, "You must specify a record type to run this action\n");
            
            [self showHelpAsError:YES];
            
            return EXIT_FAILURE;
        }
    
        if ([self.recordUUID length] == 0) {
            fprintf(stderr, "You must specify a record UUID to run this action\n");
            
            [self showHelpAsError:YES];
            
            return EXIT_FAILURE;
        }
    }
    
    return EXIT_SUCCESS;
}

- (int)runListAction {
    
    NSArray *recordTypes = nil;
    
    if (self.recordType) {
        recordTypes = @[self.recordType];
    } else {
        recordTypes = @[@"user", @"group"];
    }
    
    for (NSString *recordType in recordTypes) {
        fprintf(stdout, "Record of type: %s\n", [recordType UTF8String]);
        [[ELAsyncBlockToManageAsOperation runOnSharedQueueOperationWithAsyncTask:^(ELAsyncBlockToManageAsOperation *currentOperation) {
            [[ELCachingDBProxy sharedInstance] getAllRegisteredRecordsOfType:recordType
                                                      withAttributesToReturn:@[
                                                                               @"shortname",
                                                                               @"uuid",
                                                                               ]
                                                        andCompletionHandler:^(NSArray<NSDictionary *> *results, NSError *error) {
                                                            for (NSDictionary *record in results) {
                                                                fprintf(stdout, "%s\n", [[NSString stringWithFormat:@"- %@ (%@)", [record objectForKey:@"shortname"], [record objectForKey:@"uuid"]] UTF8String]);
                                                            }
                                                            [currentOperation considerThisOperationAsDone];
                                                        }];
        }
                                                          withCancelationHandler:^(ELAsyncBlockToManageAsOperation *currentOperation) {
                                                              
                                                          }
                                                                     andUserInfo:nil] waitUntilFinished];
        
    }
    
    return EXIT_SUCCESS;
}

- (int)runReadAction{
    return 0;
}

- (int)runForgetAction{
    return 0;
}

- (void)showHelpAsError:(BOOL)helpAsError {
    FILE * __restrict output = helpAsError ? stderr : stdout;
    const char *command = getprogname();
    
    fprintf(stderr, "usage: %s -action < list | read | forget > ...\n", command);
    fprintf(output, "\n");
    
    fprintf(stderr, "%s -action list\n", command);
    fprintf(stderr, "\tList records available locally\n");
    fprintf(output, "\n");
    
    fprintf(stderr, "%s -action list -recordType user\n", command);
    fprintf(stderr, "\tList users available locally\n");
    fprintf(stderr, "\t(supported type are user and group)\n");
    fprintf(output, "\n");
    
    fprintf(stderr, "%s -action read -recordType user -recordUUID uuid\n", command);
    fprintf(stderr, "\tRead all record info\n");
    fprintf(stderr, "\t(supported type are user and group)\n");
    fprintf(output, "\n");
    
    fprintf(stderr, "%s -action forget\n", command);
    fprintf(stderr, "\tWipe all records from local system\n");
    fprintf(stderr, "\t(Will come back on next sync if still assigned to device identity)\n");
    fprintf(output, "\n");
    
    fprintf(stderr, "%s -action forget -recordType user\n", command);
    fprintf(stderr, "\tWipe all records of specified type from local system\n");
    fprintf(stderr, "\t(Will come back on next sync if still assigned to device identity)\n");
    fprintf(output, "\n");
    
    fprintf(stderr, "%s -action forget -recordType user -recordUUID uuid\n", command);
    fprintf(stderr, "\tWipe specific record from local system\n");
    fprintf(stderr, "\t(Will come back on next sync if still assigned to device identity)\n");
    fprintf(output, "\n");
}

@end
