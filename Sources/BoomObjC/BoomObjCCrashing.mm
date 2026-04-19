//
//  BoomObjCCrashing.mm
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#import "include/BoomObjCCrashing.h"
#import <Foundation/Foundation.h>
#import <stdexcept>
#import <stdlib.h>

// MARK: - ObjC Exception

void boom_crash_objc_exception(void) {
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:@"Uncaught ObjC exception from Boom"
                                 userInfo:@{NSLocalizedDescriptionKey: @"Triggered by Boom"}];
}

// MARK: - C++ Exception

void boom_crash_cxx_exception(void) {
    throw std::runtime_error("Uncaught C++ exception from Boom");
}

// MARK: - ObjC msg send on deallocated object

@interface BoomZombieTarget : NSObject
- (void)doSomething;
@end

@implementation BoomZombieTarget
- (void)doSomething {}
@end

void boom_crash_objc_msg_send(void) {
    __unsafe_unretained id zombie;
    @autoreleasepool {
        zombie = [[BoomZombieTarget alloc] init];
    }
    // zombie is deallocated — sending a message to it causes EXC_BAD_ACCESS
    [zombie doSomething];
}

// MARK: - Released object (corrupt the isa pointer via CF bridge)

void boom_crash_released_object(void) {
    NSObject *obj = [NSObject new];
    // CFBridgingRetain gives us a void* without ARC interference so we can corrupt the isa
    void *rawPtr = (void *)CFBridgingRetain(obj);
    *((uintptr_t *)rawPtr) = 0xDEADBEEF;
    CFRelease(rawPtr);
    [obj description];
}

// MARK: - Corrupt malloc metadata

void boom_crash_corrupt_malloc(void) {
    uint8_t *buf = (uint8_t *)malloc(16);
    // Write before the allocation to corrupt the adjacent chunk's metadata header
    memset(buf - 8, 0xAA, 32);
    free(buf);
}
