//
//  GifManConsole.m
//  GifMan
//
//  Created by Tom Arnfeld on 05/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManConsole.h"

@implementation GifManConsole

+ (NSString *)webScriptNameForSelector:(SEL)sel
{
    if (sel == @selector(log:)) {
        return @"log";
    }
    
    if (sel == @selector(debug:)) {
        return @"debug";
    }
    
    if (sel == @selector(info:)) {
        return @"info";
    }
    
    if (sel == @selector(warn:)) {
        return @"warn";
    }
    
    if (sel == @selector(error:)) {
        return @"error";
    }
    
    if (sel == @selector(exception:)) {
        return @"exception";
    }
    
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(log:)) return NO;
    if (aSelector == @selector(debug:)) return NO;
    if (aSelector == @selector(info:)) return NO;
    if (aSelector == @selector(warn:)) return NO;
    if (aSelector == @selector(error:)) return NO;
    if (aSelector == @selector(exception:)) return NO;
    
    return YES;
}

- (void)log:(id)message, ...
{
    NSLog(@"GifMan Console:   [LOG] %@", message);
}

- (void)debug:(id)message, ...
{
    NSLog(@"GifMan Console: [DEBUG] %@", message);
}

- (void)info:(id)message, ...
{
    NSLog(@"GifMan Console:  [INFO] %@", message);
}

- (void)warn:(id)message, ...
{
    NSLog(@"GifMan Console:  [WARN]%@", message);
}

- (void)error:(id)message, ...
{
    NSLog(@"GifMan Console: [ERROR] %@", message);
}

- (void)exception:(id)exception, ...
{
    NSLog(@"GifMan Console Exception: %@", exception);
}

@end
