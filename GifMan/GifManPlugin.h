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
}

+ (void)load;
+ (GifManPlugin *)sharedPlugin;

@end
