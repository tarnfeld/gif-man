//
//  GifManPlugin
//  GifMan
//
//  Created by Tom Arnfeld on 19/10/2012.
//  Copyright (c) 2012 Tom Arnfeld. All rights reserved.
//

#import "GifManPlugin.h"
#import "GifManKVStore.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <WebKit/WebKit.h>

#import "GifManInspection.h"
#import "GifManConsole.h"

#define kGifManClientApplicationName @"GifMan"
#define kGifManSkypeQueueName @"SkypeQueue"

@interface SkypeChatWebView : WebView

@end

@interface GifManPlugin ()

- (void)swizzleWebkitMethods;

- (NSArray *)_webView:(SkypeChatWebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems;
- (void)_webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame;

- (void)hideContent:(id)sender;
- (void)loadContent:(id)sender;

// SkypeChatClient Private Methods
- (NSUInteger)SK_findMessageIDFromDOMNode:(DOMNode *)node;

@end

@implementation GifManPlugin

static GifManKVStore *__KVStore;
static NSUInteger __selectedMessageID;

+ (void)load
{
    GifManPlugin *plugin = [GifManPlugin sharedPlugin];

    // Listen for skype delegate calls
    [SkypeAPI setSkypeDelegate:plugin];

    // Swizzle the web view methods
    [plugin swizzleWebkitMethods];
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

- (void)swizzleWebkitMethods
{
    // webView:resource:willSendRequest:redirectResponse:fromDataSource
    Class display = NSClassFromString(@"SkypeChatDisplay");
    
    SEL selector = @selector(webView:resource:willSendRequest:redirectResponse:fromDataSource:);
    Method originalMethod = class_getInstanceMethod(display, selector);
    Method newMethod = class_getInstanceMethod(self.class, selector);
    IMP implementation = method_getImplementation(newMethod);
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));

    // webView:decidePolicyForNavigationAction:request:frame:decisionListener:
    selector = @selector(webView:decidePolicyForNavigationAction:request:frame:decisionListener:);
    originalMethod = class_getInstanceMethod(display, selector);
    newMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(newMethod);
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    
    // webView:contextMenuItemsForElement:defaultMenuItems:
    selector = @selector(webView:contextMenuItemsForElement:defaultMenuItems:);
    originalMethod = class_getInstanceMethod(display, selector);
    newMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(newMethod);
    
    SEL _selector = @selector(_webView:contextMenuItemsForElement:defaultMenuItems:);
    IMP _implementation = method_getImplementation(originalMethod);
    
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    class_addMethod(display, _selector, _implementation, method_getTypeEncoding(originalMethod));
    
    // webView:didStartProvisionalLoadForFrame:
    selector = @selector(webView:didStartProvisionalLoadForFrame:);
    originalMethod = class_getInstanceMethod(display, selector);
    newMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(newMethod);
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    
    // webView:didFinishLoadForFrame:
    selector = @selector(webView:didFinishLoadForFrame:);
    originalMethod = class_getInstanceMethod(display, selector);
    newMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(newMethod);
    
    _selector = @selector(_webView:didFinishLoadForFrame:);
    _implementation = method_getImplementation(originalMethod);
    
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    class_addMethod(display, _selector, _implementation, method_getTypeEncoding(originalMethod));
    
    // webView:addMessageToConsole:
    selector = @selector(webView:addMessageToConsole:);
    originalMethod = class_getInstanceMethod(display, selector);
    newMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(newMethod);
    class_replaceMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    
    // hideContent:
    selector = @selector(hideContent:);
    originalMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(originalMethod);
    class_addMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    
    // loadContent:
    selector = @selector(loadContent:);
    originalMethod = class_getInstanceMethod(self.class, selector);
    implementation = method_getImplementation(originalMethod);
    class_addMethod(display, selector, implementation, method_getTypeEncoding(originalMethod));
    
    // Add some custom iVars
    class_addIvar(display, "__GM_selectedWebView", sizeof([WebScriptObject class]), log2(sizeof([WebScriptObject class])), "@");
}

#pragma mark -
#pragma mark Swizzled Webkit Methods

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)message
{
    NSLog(@"%@", message);
    return;
    
    NSLog(@"GifMan Console:");
    NSLog(@"  Message: %@", [message objectForKey:@"message"]);
    NSLog(@"     Line: %@", [message objectForKey:@"lineNumber"]);
    NSLog(@"     File: %@", [message objectForKey:@"sourceURL"]);
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self _webView:sender didFinishLoadForFrame:frame];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    if (!__KVStore) {
        __KVStore = [[GifManKVStore alloc] init];
    }
    
    WebScriptObject *script = [sender windowScriptObject];
    [script setValue:__KVStore forKey:@"GifManKVStore"];
}

- (NSURLRequest *)webView:(SkypeChatWebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    return request;
}

- (void)webView:(SkypeChatWebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
    // If it's a file:/// URL we should allow it.
    // I don't know the exact implementation of the skype app's verison of this method...
    // ...so i'm just guessing how it'd work.

    NSURL *url = [request URL];
    NSString *urlString = [NSString stringWithFormat:@"%@", url];

    // Keep an array of allowed checks
    NSArray *checks = @[
        @"file:///", //
        @"youtube.com/embed", // Youtube embed
        @"_gifman_allow=true" // Magical string to allow gifman
    ];

    // Match any of the checks
    __block BOOL matched = NO;
    [checks enumerateObjectsUsingBlock:^(NSString *check, NSUInteger idx, BOOL *stop) {

        NSRange range = [urlString rangeOfString:check];
        if (range.location != NSNotFound) {
            [listener use];

            matched = YES;
            *stop = YES;
        }
    }];


    if (matched) {
        return;
    }

    // Otherwise go ahead and open the URL
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (NSArray *)webView:(SkypeChatWebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    DOMHTMLElement *clickedNode = [element objectForKey:WebElementDOMNodeKey];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self _webView:webView contextMenuItemsForElement:element defaultMenuItems:defaultMenuItems]];
    
    if (![clickedNode isKindOfClass:[DOMHTMLDivElement class]]) {
        return items;
    }
    
    if (!__GM_selectedWebView) {
        __GM_selectedWebView = (WebScriptObject *) [webView retain];
    }
    
    __selectedMessageID = [self SK_findMessageIDFromDOMNode:clickedNode];
    
    if (__selectedMessageID && [__KVStore getValueForKey:@"embed_enabled"]) {
        [items addObject:[NSMenuItem separatorItem]];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Hide Content" action:@selector(hideContent:) keyEquivalent:@""];
        [item setTarget:self];
        
        NSString *hasContent = [__GM_selectedWebView evaluateWebScript:[NSString stringWithFormat:@"GifMan.API.hasVisibleContent(%lu)", (unsigned long) __selectedMessageID]];
        
        if (![hasContent boolValue]) {
            [item setTitle:@"Load Content"];
            [item setAction:@selector(loadContent:)];
        }
        
        [items addObject:item];
    }
    
    return items;
}

- (void)hideContent:(id)sender
{
    [__GM_selectedWebView evaluateWebScript:[NSString stringWithFormat:@"GifMan.API.hideContentInMessage(%lu)", (unsigned long) __selectedMessageID]];
}

- (void)loadContent:(id)sender
{
    [__GM_selectedWebView evaluateWebScript:[NSString stringWithFormat:@"GifMan.API.loadContentInMessage(%lu)", (unsigned long) __selectedMessageID]];
}

- (NSArray *)_webView:(WebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    // This is an unused placeholder for the added method, just to play nice with xcode warnings.
    
    return nil;
}

- (void)_webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // This is an unused placeholder for the added method, just to play nice with xcode warnings.
}

- (NSUInteger)SK_findMessageIDFromDOMNode:(DOMNode *)node
{
    // This is an unused placeholder for the added method, just to play nice with xcode warnings.
    
    return 0;
}

#pragma mark -
#pragma mark SkypeAPIDelegate

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
//        NSLog(@"GIFMAN: Successfully connected to skype");
    }
    else {
//        NSLog(@"GIFMAN: Failed to connect to skype");
    }
}

- (void)skypeBecameAvailable:(NSNotification *)aNotification
{
//    NSLog(@"GIFMAN: Skype became available");

    // @TODO: Do something with this...

    // Connect to skype
    // [SkypeAPI connect];
}

@end
