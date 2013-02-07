//
//  GifManSocket.m
//  GifMan
//
//  Created by Tom Arnfeld on 06/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManSocket.h"

@interface GifManSocketMessage (FP_Private)
- (void)callHandlerWithResponseMessage:(GifManSocketMessage *)responseMessage;
@end

@interface SocketIO (FP_Private)
- (void)send:(SocketIOPacket *)packet;
@end

@implementation GifManSocket

@synthesize retryLimit = __retryLimit;
@synthesize retryInterval = __retryInterval;

- (id)initWithDelegate:(id<GifManSocketDelegate>)delegate host:(NSString *)host port:(NSUInteger)port
{
    self = [super init];
    if (self) {
        
        __delegate = delegate;
        
        __retryInterval = 2;
        __retryLimit = 100;
        __retryCount = 0;
        
        __connectionHost = [host retain];
        __connectionPort = port;
        
        __socket = [[SocketIO alloc] initWithDelegate:self];
        __boundMessages = [[NSMutableDictionary alloc] init];
        
        // Make the first attempt to connect
        [__socket connectToHost:__connectionHost onPort:__connectionPort];
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
    
    SocketIOPacket *packet = [[SocketIOPacket alloc] initWithType:@"message"];
    [packet setData:messageString];
    
    [__socket send:packet];
    [packet release];
}

- (void)disconnect
{
    if (__socket && [__socket isConnected]) {
        [__socket disconnect];
    }
}

- (void)reconnect
{
    if (__retryCount >= __retryLimit) {
        return;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, __retryInterval * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Retrying");
        
        [__socket connectToHost:__connectionHost onPort:__connectionPort];
        __retryCount++;
    });
}

- (void)dealloc
{
    [super dealloc];
    
    if (__socket) {
        [__socket release];
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
    [self reconnect];
    
    if ([__delegate respondsToSelector:@selector(socketDisconnected:)]) {
        [__delegate socketDisconnected:self];
    }
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *packetPayload = [packet dataAsJSON];
    
    // Handle bound messages
    if ([[packetPayload objectForKey:@"name"] isEqualToString:@"message"]) {
        
        NSDictionary *response = [[packetPayload objectForKey:@"args"] objectAtIndex:0];
        NSString *identifier = [response objectForKey:@"identifier"];
        
        GifManSocketMessage *message = [__boundMessages objectForKey:identifier];
        GifManSocketMessage *responseMessage = [[GifManSocketMessage alloc] initWithType:[response objectForKey:@"type"]];
        [responseMessage setPayload:[response objectForKey:@"payload"]];
        
        if (message && responseMessage) {
            [message callHandlerWithResponseMessage:responseMessage];
        }
        
        [__boundMessages removeObjectForKey:identifier];
    }
}

- (void)socketIOHandshakeFailed:(SocketIO *)socket
{
    [self reconnect];
    
    if ([__delegate respondsToSelector:@selector(socketFailedToConnect:)]) {
        [__delegate socketFailedToConnect:self];
    }
}

@end
