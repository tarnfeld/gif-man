//
//  GifManGenericChat.m
//  GifMan
//
//  Created by Tom Arnfeld on 08/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManGenericChat.h"
#import "GifManPlugin.h"

@interface GifManGenericChat ()

@end

@implementation GifManGenericChat

- (void)sendMessageCmd:(IMTextInputView *)textView
{
    NSString *message = [textView string];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^!hubot.*" options:0 error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:message options:0 range:NSMakeRange(0, [message length])];
    
    if ([result numberOfRanges] > 0) {
        GifManPlugin *plugin = [GifManPlugin sharedPlugin];
        NSString *chatIdentity = [self identity];
        
        NSDictionary *payload = @{
            @"chatId": chatIdentity,
            @"message": [message substringFromIndex:1]
        };
        
        GifManSocket *socket = [plugin socket];
        GifManSocketMessage *message = [[GifManSocketMessage alloc] initWithType:kGIfManSocketMessageHubotProxy];
        [message setPayload:payload];
        [message setResponseHandler:^(GifManSocketMessage *message, GifManSocketMessage *response) {
            NSLog(@"DING DONG HUBOT %@", [response payload]);
        }];
        
        [socket sendMessage:message];
//        [message dealloc];
        
        return;
    }
    
    [self _sendMessageCmd:textView];
}

- (void)_sendMessageCmd:(IMTextInputView *)textView
{
    // Placeholder method – this body will be replaced with that of the original method
}

@end
