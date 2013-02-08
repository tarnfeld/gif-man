//
//  GifManPlugin
//  GifMan
//
//  Created by Tom Arnfeld on 19/10/2012.
//  Copyright (c) 2012 Tom Arnfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GifManSocket.h"

@class WebScriptObject;
@class SkypeChat;

@interface GifManPlugin : NSObject <SkypeAPIDelegate, GifManSocketDelegate> {
    
    NSOperationQueue *__skypeOperationQueue;
    NSStatusItem *__statusItem;
    GifManSocket *__socket;
}

@property (nonatomic, readonly) GifManSocket *socket;

+ (void)load;
+ (GifManPlugin *)sharedPlugin;

@end
