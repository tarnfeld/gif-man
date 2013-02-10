//
//  GifManSocketMessage.m
//  GifMan
//
//  Created by Tom Arnfeld on 06/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManSocketMessage.h"

@implementation GifManSocketMessage

@synthesize type = __type;
@synthesize payload = __payload;
@synthesize responseHandler = __responseHandler;
@synthesize chatDisplay = __chatDisplay;

- (id)initWithType:(NSString *)type
{
    return [self initWithType:type payload:nil];
}

- (id)initWithType:(NSString *)type payload:(id)payload
{
    self = [super init];
    if (self) {
        
        __type = [type retain];
        __payload = [payload retain];
    }
    
    return self;
}

- (NSString *)identifier
{
    if (!__identifier) {
        __identifier = [(NSString *) CFUUIDCreateString(NULL, CFUUIDCreate(NULL)) retain];
    }
    
    return __identifier;
}

- (NSString *)JSONRepresentation
{
    NSDictionary *message;
    if (__payload) {
        message = @{ @"type": __type, @"payload": __payload, @"identifier": [self identifier] };
    }
    else {
        message = @{ @"type": __type, @"identifier": [self identifier] };
    }
    
    return [message JSONRepresentation];
}

- (void)callHandlerWithResponseMessage:(GifManSocketMessage *)responseMessage
{
    if (__responseHandler) {
        __responseHandler(self, responseMessage);
    }
}

- (void)dealloc
{
    [super dealloc];
    
    if (__type) {
        [__type dealloc];
    }
    
    if (__payload) {
        [__payload dealloc];
    }
    
    if (__identifier) {
        [__identifier dealloc];
    }
    
    __type = nil;
    __payload = nil;
    __identifier = nil;
    __responseHandler = nil;
}

@end
