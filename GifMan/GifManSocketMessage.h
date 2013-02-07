//
//  GifManSocketMessage.h
//  GifMan
//
//  Created by Tom Arnfeld on 06/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

@class GifManSocketMessage;

typedef void(^GifManSocketMessageResponseHandler)(GifManSocketMessage *message, GifManSocketMessage *responseMessage);

#define kGifManSocketMessageTypePing        @"GifMan::ping"
#define kGifManSocketMessageTypeBowerCheck  @"GifMan::bowerCheck"

@interface GifManSocketMessage : NSObject {
    
    NSString *__identifier;
    NSString *__type;
    id __payload;
    
    GifManSocketMessageResponseHandler __responseHandler;
}

- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)type payload:(id)payload;

- (NSString *)identifier;

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) id payload;

@property (nonatomic, readwrite) GifManSocketMessageResponseHandler responseHandler;

@end
