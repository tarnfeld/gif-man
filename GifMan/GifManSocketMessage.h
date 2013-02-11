//
//  GifManSocketMessage.h
//  GifMan
//
//  Created by Tom Arnfeld on 06/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"

@class GifManSocketMessage, SkypeChatDisplay;

typedef void(^GifManSocketMessageResponseHandler)(GifManSocketMessage *message, GifManSocketMessage *responseMessage);

#define kGifManSocketMessageTypePing            @"GifMan::ping"
#define kGifManSocketMessageHubotProxy          @"GifMan::hubotProxy"
#define kGifManSocketMessageHubotPresenceJoin   @"GifMan::hubotJoin"
#define kGifManSocketMessageHubotPresenceLeave  @"GifMan::hubotLeave"

#define kGifManSocketMessageReplyTypeMe         @"GifManReply::me"
#define kGifManSocketMessageReplyTypeSpray      @"GifManReply::spray"

@interface GifManSocketMessage : NSObject {
    
    NSString *__identifier;
    NSString *__type;
    id __payload;
    
    GifManSocketMessageResponseHandler __responseHandler;
    SkypeChatDisplay *__chatDisplay;
}

- (id)initWithType:(NSString *)type;
- (id)initWithType:(NSString *)type payload:(id)payload;

- (NSString *)identifier;

@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) id payload;

@property (nonatomic, retain) GifManSocketMessageResponseHandler responseHandler;
@property (nonatomic, retain) SkypeChatDisplay *chatDisplay;

@end
