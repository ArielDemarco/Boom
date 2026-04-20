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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
        zombie = [[BoomZombieTarget alloc] init];
#pragma clang diagnostic pop
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

// MARK: - Stack overflow

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winfinite-recursion"
__attribute__((noinline))
static void boom_do_stack_overflow(void) {
    boom_do_stack_overflow();
}
#pragma clang diagnostic pop

void boom_crash_stack_overflow(void) {
    boom_do_stack_overflow();
}

// MARK: - Unrecognized selector

void boom_crash_unrecognized_selector(void) {
    NSObject *obj = [[NSObject alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [obj performSelector:NSSelectorFromString(@"boomNonExistentMethod")];
#pragma clang diagnostic pop
}

// MARK: - KVO: remove unregistered observer

void boom_crash_kvo(void) {
    NSObject *observed = [[NSObject alloc] init];
    NSObject *observer = [[NSObject alloc] init];
    // Removing an observer that was never registered triggers NSInternalInconsistencyException
    [observed removeObserver:observer forKeyPath:@"boomKeyPath"];
}

// MARK: - Stack smash

__attribute__((noinline))
void boom_crash_stack_smash(void) {
    volatile char buf[8];
    // Write well past the buffer to corrupt the stack canary, triggering __stack_chk_fail on return
    for (int i = 0; i < 256; i++) {
        ((volatile char *)buf)[i] = (char)0xAA;
    }
}
