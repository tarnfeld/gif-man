//
//  GifManKVStore.h
//  GifMan
//
//  Created by Tom Arnfeld on 03/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifManKVStore : NSObject {
    
    NSMutableDictionary *__data;
}

- (void)saveValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)getValueForKey:(NSString *)key;

- (void)save;

@end
