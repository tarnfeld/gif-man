//
//  GifManPlugin
//  GifMan
//
//  Created by Tom Arnfeld on 19/10/2012.
//  Copyright (c) 2012 Tom Arnfeld. All rights reserved.
//

#import "GifManPlugin.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <WebKit/WebKit.h>

#define kGifManClientApplicationName @"GifMan"
#define kGifManSkypeQueueName @"SkypeQueue"

@implementation GifManPlugin

+ (void)load
{
    NSLog(@"Loading GifMan plugin.");
    
    GifManPlugin *plugin = [GifManPlugin sharedPlugin];

    // Listen for skype delegate calls
    [SkypeAPI setSkypeDelegate:plugin];

    // Swizzle the web view methods
    [plugin swizzleRequestMethod];
    
    // Setup the menu bar item
    [plugin setupStatusItem];
}

+ (GifManPlugin *)sharedPlugin
{
    static GifManPlugin *sharedPlugin = nil;

    if (!sharedPlugin) {
        sharedPlugin = [[GifManPlugin alloc] init];
    }

    return sharedPlugin;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        __skypeOperationQueue = [[NSOperationQueue alloc] init];
        [__skypeOperationQueue setName:kGifManSkypeQueueName];
    }
    
    return self;
}

- (void)swizzleRequestMethod
{
    NSLog(@"GIFMAN: Replacing skype webkit methods to allow requests");

    Class display = NSClassFromString(@"SkypeChatDisplay");
    SEL selector = @selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:);
    Method originalMethod = class_getInstanceMethod(display, selector);
    Method newMethod = class_getInstanceMethod(self.class, selector);
    IMP implementation = method_getImplementation(newMethod);
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    
    selector = @selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:);
    originalMethod = class_getInstanceMethod(display, selector);
    newMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(newMethod);
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
}

- (void)setupStatusItem
{
    NSLog(@"GIFMAN: Setup status item");
    
    __statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [__statusItem setTitle:@"HA"];
}

#pragma mark -
#pragma mark Swizzled Methods

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    NSLog(@"GIFMAN: Replaced webkit method called");
    
    return request;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    NSLog(@"GIFMAN: Replaced webkit decision listener method called");
    
    // If it's a file:/// URL we should allow it.
    // I don't know the exact implementation of the skype app's verison of this method...
    // ...so i'm just guessing how it'd work.
    
    NSURL *url = [request URL];
    NSString *urlString = [NSString stringWithFormat:@"%@", url];
    
    NSRange range = [urlString rangeOfString:@"file:///"];
    if (range.location != NSNotFound) {
        [listener use];
        return;
    }
    
    // Check for youtube
    range = [urlString rangeOfString:@"youtube.com/embed"];
    if (range.location != NSNotFound) {
        [listener use];
        return;
    }

    // Otherwise go ahead and open the URL
    [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark -
#pragma mark ;

- (NSString *)clientApplicationName
{
    return kGifManClientApplicationName;
}

#pragma mark -
#pragma mark SkypeAPIDelegateInformalProtocol

- (void)skypeNotificationReceived:(NSString*)notificationString
{
//    NSLog(@"GIFMAN: Skype notification received: %@", notificationString);
}

- (void)skypeAttachResponse:(unsigned)responseCode
{
    if (responseCode == 1) {
        NSLog(@"GIFMAN: Successfully connected to skype");
    }
    else {
        NSLog(@"GIFMAN: Failed to connect to skype");
    }
}

- (void)skypeBecameAvailable:(NSNotification *)aNotification
{
    NSLog(@"GIFMAN: Skype became available");
    
    // @TODO: Do something with this...
    
    // Connect to skype
    // [SkypeAPI connect];
}

@end