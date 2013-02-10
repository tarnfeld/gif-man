//
//  GifManGenericChat.m
//  GifMan
//
//  Created by Tom Arnfeld on 08/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import "GifManGenericChat.h"
#import "GifManPlugin.h"

#import "SkypeChatContact.h"

#import <objc/runtime.h>
#import <WebKit/WebKit.h>

@interface GifManGenericChat ()

@end

@implementation GifManGenericChat

- (void)sendMessageCmd:(IMTextInputView *)textView
{
    NSString *message = [textView string];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^#?!hubot.*" options:0 error:nil];
    NSTextCheckingResult *result = [regex firstMatchInString:message options:0 range:NSMakeRange(0, [message length])];
    
    if ([result numberOfRanges] > 0) {
        GifManPlugin *plugin = [GifManPlugin sharedPlugin];
        NSString *chatIdentity = [self identity];
        NSString *chatName = [self displayName];
    
        SkypeChatContact *contact = nil;
        object_getInstanceVariable(self, "_meMemberContact", (void**) &contact);

        NSString *username = [contact identity];
        NSString *nickname = [contact displayName];
        NSString *replyType;
        
        if ([[message substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"#!"]) {
            message = [message substringFromIndex:2];
            replyType = kGifManSocketMessageReplyTypeSpray;
        }
        else {
            message = [message substringFromIndex:1];
            replyType = kGifManSocketMessageReplyTypeMe;
        }
        
        NSDictionary *payload = @{
            @"username": username,
            @"nickname": nickname,
            @"chat": chatIdentity,
            @"chat_name": chatName,
            @"message": message,
            @"reply_type": replyType
        };
        
        GifManSocket *socket = [plugin socket];
        GifManSocketMessage *socketMessage = [[GifManSocketMessage alloc] initWithType:kGifManSocketMessageHubotProxy];
        [socketMessage setPayload:payload];
        [socketMessage setChatDisplay:[self display]];
        [socketMessage setResponseHandler:^(GifManSocketMessage *message, GifManSocketMessage *response) {
           
            NSArray *messages = [[response payload] objectForKey:@"messages"];
            NSString *identifier = [message identifier];
            
            WebScriptObject *window;
            object_getInstanceVariable([message chatDisplay], "_windowScriptObject", (void **)&window);
            
            [[window evaluateWebScript:@"GifMan.API"] callWebScriptMethod:@"addHubotMessage" withArguments:@[identifier, messages]];
        }];
        
        [socket sendMessage:socketMessage];
        
        if (![replyType isEqualToString:kGifManSocketMessageReplyTypeSpray]) {
            [textView setString:@""];
            [self makeInputTextFirstResponder];
            
            return;
        }
    }
    
    [self _sendMessageCmd:textView];
}

- (void)_sendMessageCmd:(IMTextInputView *)textView
{
    // Placeholder method – this body will be replaced with that of the original method
}

- (NSString *)identity
{
    // Placeholder method to keep xcode happy
    
    return nil;
}

- (NSString *)displayName
{
    // Placeholder method to keep xcode happy
    
    return nil;
}

- (SkypeChatDisplay *)display
{
    // Placeholder method to keep xcode happy

    return nil;
}

@end
