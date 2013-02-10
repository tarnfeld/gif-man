/* Generated by RuntimeBrowser.
   Image: /Applications/Skype.app/Contents/MacOS/Skype
 */

@class WebSecurityContext;

@interface GenericWebView : WebView  {
    WebSecurityContext *_securityContext;
    BOOL _blockNotifications;
    BOOL _allowsMagnification;
}

@property(readonly) WebSecurityContext * securityContext;
@property BOOL blockNotifications;
@property BOOL allowsMagnification;


- (void)setAllowsMagnification:(BOOL)arg1;
- (BOOL)allowsMagnification;
- (void)setBlockNotifications:(BOOL)arg1;
- (BOOL)blockNotifications;
- (id)securityContext;
- (BOOL)validateMenuItem:(id)arg1;
- (void)viewDidMoveToWindow;
- (void)viewDidMoveToSuperview;
- (void)setSecurityContextType:(int)arg1;
- (void)setSecurityContext:(id)arg1;
- (void)setPreferencesIdentifier:(id)arg1;
- (void)dealloc;

@end