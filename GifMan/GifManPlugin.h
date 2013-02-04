//
//  GifManPlugin
//  GifMan
//
//  Created by Tom Arnfeld on 19/10/2012.
//  Copyright (c) 2012 Tom Arnfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WebView;

@interface GifManPlugin : NSObject <SkypeAPIDelegate> {
    
    NSOperationQueue *__skypeOperationQueue;
    NSStatusItem *__statusItem;
    
    // Fake iVars
    NSUInteger *___selectedMessageId;
    WebView *___selectedWebView;
}

+ (void)load;
+ (GifManPlugin *)sharedPlugin;

@end
