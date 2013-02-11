//
//  GifManGenericChat.h
//  GifMan
//
//  Created by Tom Arnfeld on 08/02/2013.
//  Copyright (c) 2013 Tom Arnfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GenericChat.h"
#import "IMTextInputView.h"
#import "DragDestinationTextView.h"

@interface GifManGenericChat : NSObject {

}

- (NSString *)displayName;
- (NSString *)identity;
- (SkypeChatDisplay *)display;
- (void)makeInputTextFirstResponder;

@end
