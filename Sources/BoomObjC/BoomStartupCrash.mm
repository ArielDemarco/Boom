//
//  BoomStartupCrash.mm
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#import "include/BoomObjCCrashing.h"
#import <Foundation/Foundation.h>
#import <signal.h>
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <unistd.h>

// MARK: - Crash dispatch

static void boom_startup_dispatch(const char *identifier) {
  // ObjC / C++
  if (strcmp(identifier, "ObjCExceptionCrash") == 0) {
    boom_crash_objc_exception();
  } else if (strcmp(identifier, "CXXExceptionCrash") == 0) {
    boom_crash_cxx_exception();
  } else if (strcmp(identifier, "ObjCMsgSendCrash") == 0) {
    boom_crash_objc_msg_send();
  } else if (strcmp(identifier, "ReleasedObjectCrash") == 0) {
    boom_crash_released_object();
  } else if (strcmp(identifier, "CorruptMallocCrash") == 0) {
    boom_crash_corrupt_malloc();
  } else if (strcmp(identifier, "UnrecognizedSelectorCrash") == 0) {
    boom_crash_unrecognized_selector();
  } else if (strcmp(identifier, "KVOCrash") == 0) {
    boom_crash_kvo();
  } else if (strcmp(identifier, "StackOverflowCrash") == 0) {
    boom_crash_stack_overflow();
  } else if (strcmp(identifier, "StackSmashCrash") == 0) {
    boom_crash_stack_smash();
  }
  // Signals
  else if (strcmp(identifier, "AbortCrash") == 0) {
    abort();
  } else if (strcmp(identifier, "SIGSEGVCrash") == 0) {
    raise(SIGSEGV);
  } else if (strcmp(identifier, "SIGBUSCrash") == 0) {
    raise(SIGBUS);
  } else if (strcmp(identifier, "SIGILLCrash") == 0) {
    raise(SIGILL);
  } else if (strcmp(identifier, "SIGFPECrash") == 0) {
    raise(SIGFPE);
  }
  // Swift runtime + thread crashes + unknown → EXC_BAD_INSTRUCTION (same as
  // real Swift traps) OOMKillCrash falls here too: jetsam-only, not triggerable
  // pre-main
  else {
    __builtin_trap();
  }
}

// MARK: - Constructor trigger (fires before main(), during ObjC initialization)

__attribute__((constructor)) static void boom_startup_crash_trigger(void) {
  NSArray<NSString *> *dirs = NSSearchPathForDirectoriesInDomains(
      NSApplicationSupportDirectory, NSUserDomainMask, YES);
  if (dirs.count == 0) {
    return;
  }

  NSString *path =
      [dirs[0] stringByAppendingPathComponent:@"boom_startup_crash"];
  const char *cPath = path.UTF8String;

  FILE *f = fopen(cPath, "r");
  if (!f) {
    return;
  }

  char identifier[256] = {0};
  size_t n = fread(identifier, 1, sizeof(identifier) - 1, f);
  fclose(f);

  if (n == 0) {
    return;
  }

  // Clear before crashing to prevent an infinite crash loop on subsequent
  // launches
  unlink(cPath);
  boom_startup_dispatch(identifier);
}
