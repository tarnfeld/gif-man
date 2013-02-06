//
//  GifManConsole.h
//  GifMan
//
//  Created by Tom Arnfeld on 05/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GifManConsole : NSObject {
    
}

- (void)log:(id)message, ...;
- (void)debug:(id)message, ...;
- (void)info:(id)message, ...;
- (void)warn:(id)message, ...;
- (void)error:(id)message, ...;

@end
