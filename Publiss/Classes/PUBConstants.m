//
//  PUBConstants.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBConstants.h"

id PUBSafeCast(id object, Class targetClass) {
    NSCParameterAssert(targetClass);
    return [object isKindOfClass:targetClass] ? object : nil;
}

void PUBAssertIfNotMainThread(void) {
    PUBAssert(NSThread.isMainThread, @"\nERROR: All calls to UIKit need to happen on the main thread. You have a bug in your code. Use dispatch_async(dispatch_get_main_queue(), ^{ ... }); if you're unsure what thread you're in.\n\nBreak on PSPDFAssertIfNotMainThread to find out where.\n\nStacktrace: %@", NSThread.callStackSymbols);
}

NSString *PUBVersionString(void) {
    return [NSString stringWithFormat:@"Publiss %@", @"2.1.0 (322)"];
}
