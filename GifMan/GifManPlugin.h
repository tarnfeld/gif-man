//
//  GifManPlugin
//  GifMan
//
//  Created by Tom Arnfeld on 19/10/2012.
//  Copyright (c) 2012 Tom Arnfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GifManPlugin : NSObject <SkypeAPIDelegate> {
    
    NSOperationQueue *__skypeOperationQueue;
    NSStatusItem *__statusItem;
    
    IMP __originalResourceMethod;
    IMP __originalPolicyMethod;
}

+ (void)load;
+ (GifManPlugin *)sharedPlugin;

- (void)swizzleRequestMethod;
- (void)setupStatusItem;

@end
