//
//  GifManKVStore.m
//  GifMan
//
//  Created by Tom Arnfeld on 03/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManKVStore.h"

#define kGifManKVStoreKey @"GifManKVStore"

@implementation GifManKVStore

+ (NSString *)webScriptNameForSelector:(SEL)sel
{
    if (sel == @selector(saveValue:forKey:)) {
        return @"set";
    }
    
    if (sel == @selector(getValueForKey:)) {
        return @"get";
    }
    
    return nil;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(saveValue:forKey:)) return NO;
    if (aSelector == @selector(getValueForKey:)) return NO;

    return YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        __data = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kGifManKVStoreKey]];
        
        [self setupDefaults];
    }
    
    return self;
}

- (void)setupDefaults
{
    if ([__data objectForKey:@"embed_enabled"] == nil) {
        [__data setObject:[NSNumber numberWithBool:YES] forKey:@"embed_enabled"];
    }
    
    [self save];
}

- (void)saveValue:(NSString *)value forKey:(NSString *)key
{
    [__data setObject:value forKey:key];
    
    [self save];
}

- (NSString *)getValueForKey:(NSString *)key
{
    @try {
        return [__data objectForKey:key];
    }
    @catch (NSException *exception) { }
    
    return nil;
}

- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:__data forKey:kGifManKVStoreKey];
}

@end
