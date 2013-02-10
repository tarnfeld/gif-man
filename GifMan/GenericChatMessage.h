/* Generated by RuntimeBrowser.
   Image: /Applications/Skype.app/Contents/MacOS/Skype
 */

@class NSDate, NSString;

@interface GenericChatMessage : NSObject <ChatMessage> {
    BOOL _isTimeOnlyTimestamp;
}

@property(readonly) long timestamp;
@property(readonly) long editTimestamp;
@property(readonly) NSDate * date;
@property(readonly) NSString * body;
@property(readonly) NSString * bodyXML;
@property(readonly) NSString * statusText;
@property(readonly) NSString * author;
@property(readonly) NSString * authorDisplayName;
@property(readonly) NSString * authorDisplayNameXMLEscaped;
@property(readonly) NSString * chatName;
@property(readonly) NSString * skypeObjectIDAsString;
@property(readonly) int uiType;
@property(readonly) BOOL isOutgoing;
@property(readonly) BOOL isContext;
@property(readonly) BOOL isPending;
@property(readonly) BOOL isRead;
@property(readonly) BOOL isSMS;
@property(readonly) BOOL isEditable;
@property(readonly) BOOL isDeletable;
@property(getter=isTimeOnlyTimestamp) BOOL timeOnlyTimestamp;
@property(readonly) unsigned int skypeObjectID;
@property(readonly) unsigned int convoID;
@property(readonly) NSString * messageStatus;
@property(readonly) NSString * itemId;
@property(readonly) NSString * tooltipDelete;
@property(readonly) NSString * tooltipEdit;
@property(readonly) NSString * tooltipQuicklook;
@property(readonly) NSString * tooltipCancel;
@property(readonly) NSString * tooltipReveal;
@property(readonly) NSString * tooltipActions;
@property(readonly) NSString * senderLinkURL;
@property(readonly) NSString * userIconPath;
@property(readonly) NSString * sender;
@property(readonly) NSString * displayTime;


- (void)setTimeOnlyTimestamp:(BOOL)arg1;
- (BOOL)isTimeOnlyTimestamp;
- (id)valueForUndefinedKey:(id)arg1;
- (id)displayTime;
- (id)sender;
- (id)userIconPath;
- (id)senderLinkURL;
- (id)tooltipActions;
- (id)tooltipReveal;
- (id)tooltipCancel;
- (id)tooltipQuicklook;
- (id)tooltipEdit;
- (id)tooltipDelete;
- (id)itemId;
- (id)messageStatus;
- (id)skypeObjectIDAsString;
- (unsigned int)convoID;
- (BOOL)isPending;
- (long)editTimestamp;
- (BOOL)isDeletable;
- (BOOL)isEditable;
- (BOOL)edit:(id)arg1;
- (BOOL)isRead;
- (unsigned int)skypeObjectID;
- (BOOL)isSimilarToMessage:(id)arg1;
- (BOOL)isHistory;
- (BOOL)isContext;
- (int)uiType;
- (BOOL)isOutgoing;
- (id)authorDisplayNameXMLEscaped;
- (id)authorDisplayName;
- (id)author;
- (id)statusText;
- (id)chatName;
- (id)bodyXML;
- (id)body;
- (id)date;
- (long)timestamp;
- (BOOL)isSMS;
- (void)setDelegate:(id)arg1;

@end