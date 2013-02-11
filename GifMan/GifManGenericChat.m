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
#import "IMTextInputView.h"

#import <objc/runtime.h>
#import <WebKit/WebKit.h>

@interface GifManGenericChat ()

@end

@implementation GifManGenericChat

- (void)sendMessageCmd:(IMTextInputView *)textView
{
    NSString *message = [textView string];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^!.*" options:0 error:nil];
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
        
        NSRegularExpression *routeRegex = [NSRegularExpression regularExpressionWithPattern:@"> *skype$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *routeResult = [routeRegex firstMatchInString:message options:0 range:NSMakeRange(0, [message length])];
        
        if (routeResult != nil && [routeResult numberOfRanges] > 0) {
            message = [[message substringWithRange:NSMakeRange(0, [routeResult rangeAtIndex:0].location)] substringFromIndex:1];
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
            @"message": [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
            @"reply_type": replyType
        };
        
        GifManSocket *socket = [plugin socket];
        GifManSocketMessage *socketMessage = [[GifManSocketMessage alloc] initWithType:kGifManSocketMessageHubotProxy];
        [socketMessage setPayload:payload];
        [socketMessage setChatDisplay:[self display]];
        [socketMessage setResponseHandler:^(GifManSocketMessage *message, GifManSocketMessage *response) {

            NSArray *messages = [[response payload] objectForKey:@"messages"];
            NSString *identifier = [message identifier];
            NSString *rReplyType = [[message payload] objectForKey:@"reply_type"];
                        
            if ([rReplyType isEqualToString:kGifManSocketMessageReplyTypeMe]) {
                WebScriptObject *window;
                object_getInstanceVariable([message chatDisplay], "_windowScriptObject", (void **)&window);
                
                [[window evaluateWebScript:@"GifMan.API"] callWebScriptMethod:@"addHubotMessage" withArguments:@[identifier, messages]];
            }
            else if ([rReplyType isEqualToString:kGifManSocketMessageReplyTypeSpray]) {
                
                GenericChat *chat;
                object_getInstanceVariable([message chatDisplay], "_chat", (void **)&chat);
                
//                    IMTextInputView *input = [class_createInstance(NSClassFromString(@"IMTextInputView"), sizeof("@")) init];
//                    [input setString:[messages componentsJoinedByString:@"\n"]];
//                    [input setValue:[NSNumber numberWithBool:YES] forKey:@"_sendingEnabled"];
//                    
//                    [input release];
                
                [[chat inputText] setString:[messages componentsJoinedByString:@"\n"]];
            }
        }];
        
        [socket sendMessage:socketMessage];
        
        [textView setString:@""];
        [self makeInputTextFirstResponder];
                
        return;
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
