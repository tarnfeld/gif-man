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

#define kGifManClientApplicationName @"GifMan"
#define kGifManSkypeQueueName @"SkypeQueue"

@interface GifManPlugin ()

- (void)swizzleWebkitMethods;
- (NSArray *)_webView:(WebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems;

- (void)hideContent:(id)sender;
- (void)loadContent:(id)sender;

// SkypeChatClient Private Methods
- (NSUInteger)SK_findMessageIDFromDOMNode:(DOMNode *)node;

@end

@implementation GifManPlugin

static GifManKVStore *__KVStore;

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
    NSUInteger size, alignment;
    NSGetSizeAndAlignment(@encode(NSUInteger), &size, &alignment);
    class_addIvar(display, "___selectedMessageId", size, alignment, @encode(NSUInteger));
    
    class_addIvar(display, "___selectedWebView", sizeof(id), log2(sizeof(id)), "@");

    //
    //  List the methods of the class instance "myClass"
//    int methodCount = 0;
//    Method * methods = class_copyMethodList(display, &methodCount);
//    for (int i=0; i<methodCount; i++)
//    {
//        char buffer[256];
//        SEL name = method_getName(methods[i]);
//        NSLog(@"Method: %@", NSStringFromSelector(name));
//        char *returnType = method_copyReturnType(methods[i]);
//        NSLog(@"The return type is %s", returnType);
//        free(returnType);
//        // self, _cmd + any others
//        unsigned int numberOfArguments = method_getNumberOfArguments(methods[i]);
//        for(int j=0; j<numberOfArguments; j++)
//        {
//            method_getArgumentType(methods[i], j, buffer, 256);
//            NSLog(@"The type of argument %d is %s", j, buffer);
//        }
//    }
//    free(methods);
    
//    int i=0;
//    unsigned int mc = 0;
//    Method * mlist = class_copyMethodList(display, &mc);
//    NSLog(@"%d methods", mc);
//    for(i=0;i<mc;i++)
//        NSLog(@"Method no #%d: %s", i, sel_getName(method_getName(mlist[i])));
}

#pragma mark -
#pragma mark Swizzled Webkit Methods

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    if (!__KVStore) {
        __KVStore = [[GifManKVStore alloc] init];
    }
    
    WebScriptObject *script = [sender windowScriptObject];
    [script setValue:__KVStore forKey:@"GifManKVStore"];
    
    return request;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
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

- (NSArray *)webView:(WebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    DOMHTMLElement *clickedNode = [element objectForKey:WebElementDOMNodeKey];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self _webView:webView contextMenuItemsForElement:element defaultMenuItems:defaultMenuItems]];
    
    if (![clickedNode isKindOfClass:[DOMHTMLElement class]]) {
        return items;
    }
    
    ___selectedMessageId = (NSUInteger *) [self SK_findMessageIDFromDOMNode:clickedNode];
    ___selectedWebView = webView;
    
    if (___selectedMessageId) {
        [items addObject:[NSMenuItem separatorItem]];
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Hide Content" action:@selector(hideContent:) keyEquivalent:@""];
        [item setTarget:self];
        
        WebScriptObject *window = [webView windowScriptObject];
        NSString *hasContent = [window evaluateWebScript:[NSString stringWithFormat:@"GifMan.API.hasVisibleContent(%lu)", (unsigned long) ___selectedMessageId]];
        
        NSLog(@"%@", hasContent);
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
    WebScriptObject *window = [___selectedWebView windowScriptObject];
    [window evaluateWebScript:[NSString stringWithFormat:@"GifMan.API.hideContentInMessage(%lu)", (unsigned long) ___selectedMessageId]];
}

- (void)loadContent:(id)sender
{
    WebScriptObject *window = [___selectedWebView windowScriptObject];
    [window evaluateWebScript:[NSString stringWithFormat:@"GifMan.API.loadContentInMessage(%lu)", (unsigned long) ___selectedMessageId]];
}

- (NSArray *)_webView:(WebView *)webView contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
    // This is an unused placeholder for the added method, just to play nice with xcode warnings.
    
    return nil;
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
