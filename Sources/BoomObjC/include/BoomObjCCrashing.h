//
//  BoomObjCCrashing.h
//  Boom
//
//  Copyright © 2026 Ariel Demarco. All rights reserved.
//  Licensed under the MIT License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void boom_crash_objc_exception(void);
FOUNDATION_EXPORT void boom_crash_cxx_exception(void);
FOUNDATION_EXPORT void boom_crash_objc_msg_send(void);
FOUNDATION_EXPORT void boom_crash_released_object(void);
FOUNDATION_EXPORT void boom_crash_corrupt_malloc(void);

NS_ASSUME_NONNULL_END
