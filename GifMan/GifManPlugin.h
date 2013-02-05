//
//  GifManPlugin
//  GifMan
//
//  Created by Tom Arnfeld on 19/10/2012.
//  Copyright (c) 2012 Tom Arnfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebScriptObject;

@interface GifManPlugin : NSObject <SkypeAPIDelegate> {
    
    NSOperationQueue *__skypeOperationQueue;
    NSStatusItem *__statusItem;
    
    // Fake iVars
    WebScriptObject *__GM_selectedWebView;
}

+ (void)load;
+ (GifManPlugin *)sharedPlugin;

@end
