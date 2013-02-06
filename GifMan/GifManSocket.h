//
//  GifManSocket.h
//  GifMan
//
//  Created by Tom Arnfeld on 06/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SocketIO.h"
#import "GifManSocketMessage.h"

@class GifManSocket;

@protocol GifManSocketDelegate <NSObject>

@optional
- (void)socketConnected:(GifManSocket *)socket;
- (void)socketDisconnected:(GifManSocket *)socket;
- (void)socketFailedToConnect:(GifManSocket *)socket;
- (void)socketReceivedUnboundMessage:(GifManSocket *)socket message:(GifManSocketMessage *)message;

@end

@interface GifManSocket : NSObject <SocketIODelegate> {
    
    SocketIO *__socket;
    
    NSUInteger __retryLimit;
    NSTimeInterval __retryInterval;
    
    id __delegate;
    
    NSMutableDictionary *__boundMessages;
}

@property (nonatomic, readwrite) NSUInteger retryLimit;
@property (nonatomic, readwrite) NSTimeInterval retryInterval;

- (id)initWithDelegate:(id <GifManSocketDelegate>)delegate host:(NSString *)host port:(NSUInteger)port;
- (void)disconnect;

- (void)sendMessage:(GifManSocketMessage *)message;

@end
