//
//  main.m
//  elctl
//
//  Created by Yoann Gini on 17/06/2017.
//  Copyright © 2017 EasyLogin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ControlCommand.h"

int main(int argc, const char * argv[]) {
    int exitCode = EXIT_FAILURE;

    @autoreleasepool {
        ControlCommand *ctrcmd = [ControlCommand new];
        exitCode = [ctrcmd run];
    }
    
    return exitCode;
}
