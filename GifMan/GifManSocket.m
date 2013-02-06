//
//  GifManSocket.m
//  GifMan
//
//  Created by Tom Arnfeld on 06/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManSocket.h"

@interface GifManSocketMessage ()

- (void)callHandlerWithResponseMessage:(GifManSocketMessage *)responseMessage;

@end

@implementation GifManSocket

@synthesize retryLimit = __retryLimit;
@synthesize retryInterval = __retryInterval;

- (id)initWithDelegate:(id<GifManSocketDelegate>)delegate host:(NSString *)host port:(NSUInteger)port
{
    self = [super init];
    if (self) {
        
        __delegate = delegate;
        
        __socket = [[SocketIO alloc] initWithDelegate:self];
        [__socket connectToHost:host onPort:port];
        
        __boundMessages = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)sendMessage:(GifManSocketMessage *)message
{
    if (!__socket || ![__socket isConnected]) {
        NSLog(@"Socket not connected");
        return;
    }
    
    if ([message responseHandler]) {
        NSString *identifier = [message identifier];
        
        [__boundMessages setObject:message forKey:identifier];
    }
    
    NSString *messageString = [message JSONRepresentation];
    [__socket sendMessage:messageString];
}

- (void)disconnect
{
    if (__socket && [__socket isConnected]) {
        [__socket disconnect];
    }
}

- (void)dealloc
{
    [super dealloc];
    
    if (__socket) {
        [__socket dealloc];
    }
    
    if (__boundMessages) {
        [__boundMessages release];
    }
    
    __socket = nil;
    __delegate = nil;
    __boundMessages = nil;
}

#pragma mark -
#pragma mark SocketIODelegate

- (void)socketIODidConnect:(SocketIO *)socket
{
    if ([__delegate respondsToSelector:@selector(socketConnected:)]) {
        [__delegate socketConnected:self];
    }
}

- (void)socketIODidDisconnect:(SocketIO *)socket
{
    if ([__delegate respondsToSelector:@selector(socketDisconnected:)]) {
        [__delegate socketDisconnected:self];
    }
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *packetPayload = [packet dataAsJSON];
    if ([[packetPayload objectForKey:@"name"] isEqualToString:@"message"]) {
        
        NSDictionary *response = [[packetPayload objectForKey:@"args"] objectAtIndex:0];
        NSString *identifier = [response objectForKey:@"identifier"];
        
        GifManSocketMessage *message = [__boundMessages objectForKey:identifier];
        GifManSocketMessage *responseMessage = [[GifManSocketMessage alloc] initWithType:[response objectForKey:@"type"]];
        [responseMessage setPayload:[response objectForKey:@"payload"]];
        
        if (message && responseMessage) {
            [message callHandlerWithResponseMessage:responseMessage];
        }
    }
}

- (void)socketIOHandshakeFailed:(SocketIO *)socket
{
    if ([__delegate respondsToSelector:@selector(socketFailedToConnect:)]) {
        [__delegate socketFailedToConnect:self];
    }
}

@end
