//
//  UITextView+ViewAttachment.h
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import <UIKit/UIKit.h>

@class RTViewAttachmentTextView;

@protocol RTViewAttachmentTextViewDelegate <NSObject>
@optional

- (void)textDidBeginEditing:(RTViewAttachmentTextView *)attachmentTextView;
- (void)textDidEndEditing:(RTViewAttachmentTextView *)attachmentTextView;

- (void)textDidChangeIn:(RTViewAttachmentTextView *)attachmentTextView;

- (BOOL)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView shouldDeleteAttachments:(NSArray<NSTextAttachment *> *)attachments;

- (void)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView willDeleteAttachment:(NSTextAttachment *)attachment;
- (void)attachmentTextView:(RTViewAttachmentTextView *)attachmentTextView didDeleteAttachment:(NSTextAttachment *)attachment;

@end

IB_DESIGNABLE
@interface RTViewAttachmentTextView : UIView
@property (nonatomic, readonly, strong) UITextView *textView;
@property (nonatomic, assign) NSRange selectedRange;
@property (nonatomic, readonly) NSUInteger length;

@property (nonatomic, strong) NSParagraphStyle *paragraphStyle;
@property (nonatomic, strong) IBInspectable UIFont *font;
@property (nonatomic, strong) IBInspectable UIColor *textColor;
@property (nonatomic, assign) IBInspectable UIEdgeInsets textContainerInset;

@property (nonatomic, weak) IBOutlet id<RTViewAttachmentTextViewDelegate> delegate;

- (void)insertViewAttachment:(NSTextAttachment *)attachment;
- (void)removeViewAttachment:(NSTextAttachment *)attachment;

@end
