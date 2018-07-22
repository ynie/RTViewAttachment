//
//  UITextView+ViewAttachment.m
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import "RTViewAttachmentTextView.h"
#import "RTViewAttachment.h"


@interface RTTextViewInternal : UITextView
@end

@implementation RTTextViewInternal

- (void)copy:(id)sender
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[self.textStorage attributedSubstringFromRange:self.selectedRange]];
    [attrString enumerateAttribute:NSAttachmentAttributeName
                           inRange:NSMakeRange(0, attrString.length)
                           options:NSAttributedStringEnumerationReverse
                        usingBlock:^(id value, NSRange range, BOOL * stop) {
                            if ([value isKindOfClass:[RTViewAttachment class]]) {
                                RTViewAttachment *attach = (RTViewAttachment *)value;
                                [attrString replaceCharactersInRange:range
                                                          withString:attach.placeholderText ?: @""];
                            }
                        }];
    [UIPasteboard generalPasteboard].string = attrString.string;
}

- (NSString *)text
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.textStorage];
    [attrString enumerateAttribute:NSAttachmentAttributeName
                           inRange:NSMakeRange(0, attrString.length)
                           options:NSAttributedStringEnumerationReverse
                        usingBlock:^(id value, NSRange range, BOOL * stop) {
                            if ([value isKindOfClass:[RTViewAttachment class]]) {
                                RTViewAttachment *attach = (RTViewAttachment *)value;
                                [attrString replaceCharactersInRange:range
                                                          withString:attach.placeholderText ?: @""];
                            }
                        }];
    return attrString.string;
}

@end

@interface RTViewAttachmentLayoutManagerInternal : NSLayoutManager
@end

@implementation RTViewAttachmentLayoutManagerInternal

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawGlyphsForGlyphRange:glyphsToShow
                           atPoint:origin];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:glyphsToShow
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                                  if ([value isKindOfClass:[RTViewAttachment class]]) {
                                      RTViewAttachment *attach = (RTViewAttachment *)value;
                                      CGRect rect = [self boundingRectForGlyphRange:range
                                                                    inTextContainer:[self textContainerForGlyphAtIndex:range.location
                                                                                                        effectiveRange:NULL]];
                                      rect.origin.x += origin.x;
                                      rect.origin.y += origin.y + (rect.size.height - attach.bounds.size.height);
                                      rect.size.height = attach.bounds.size.height;
                                      attach.attachedView.frame = rect;
                                      attach.attachedView.hidden = NO;
                                  }
                              }];
}

@end


@interface RTViewAttachmentTextView () <UITextViewDelegate>
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *manager;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation RTViewAttachmentTextView
@synthesize font = _font;
@synthesize textColor = _textColor;
@synthesize paragraphStyle = _paragraphStyle;

- (void)dealloc {
}

- (void)_commonInit {
    NSTextContainer *container = [[NSTextContainer alloc] init];
    container.widthTracksTextView = YES;

    self.textStorage = [[NSTextStorage alloc] init];
    self.manager = [[RTViewAttachmentLayoutManagerInternal alloc] init];

    [self.textStorage addLayoutManager:self.manager];
    [self.manager addTextContainer:container];
    
    self.textView = [[RTTextViewInternal alloc] initWithFrame:self.bounds
                                                textContainer:container];
    self.textView.delegate = self;
    [self addSubview:self.textView];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.textView sizeThatFits:size];
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

- (void)setFont:(UIFont *)font{
    if (_font != font) {
        _font = font;

        [self _updateStyle];
    }
}

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont systemFontOfSize:17.f];
    }
    return _font;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    [self _updateStyle];
}

- (UIColor *)textColor {
    if (_textColor == nil) {
        _textColor = [UIColor blackColor];
    }
    
    return _textColor;
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle {
    _paragraphStyle = paragraphStyle;
    
    [self _updateStyle];
}

- (NSParagraphStyle *)paragraphStyle {
    if (!_paragraphStyle) {
        _paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
    }
    return _paragraphStyle;
}

- (NSRange)selectedRange {
    return self.textView.selectedRange;
}

- (void)setSelectedRange:(NSRange)selectedRange {
    self.textView.selectedRange = selectedRange;
}

- (UIEdgeInsets)textContainerInset {
    return self.textView.textContainerInset;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    self.textView.textContainerInset = textContainerInset;
}

- (NSUInteger)length {
    return self.textStorage.length;
}

- (void)insertViewAttachment:(RTViewAttachment *)attachment {
    attachment.attachedView.hidden = YES;
    [self.textView addSubview:attachment.attachedView];

    [self.textStorage beginEditing];
    
    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [attachmentString addAttributes:[self _textAttributes] range:NSMakeRange(0, attachmentString.length)];
    [self.textStorage replaceCharactersInRange:self.selectedRange
                          withAttributedString:attachmentString];
    NSRange range = NSMakeRange(MIN(self.textStorage.editedRange.location + self.textStorage.editedRange.length,
                                    self.textStorage.length), 0);
    [self.textStorage endEditing];
    self.selectedRange = range;
    
    [self.delegate textDidChangeIn:self];
}

- (void)removeViewAttachment:(RTViewAttachment *)attachment {
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:NSMakeRange(0, self.textStorage.length)
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired | NSAttributedStringEnumerationReverse
                              usingBlock:^(id value, NSRange range, BOOL * stop) {
                                  if (value == attachment) {
                                      [self.textStorage removeAttribute:NSAttachmentAttributeName
                                                                  range:range];
                                      [self.textStorage replaceCharactersInRange:range
                                                                      withString:@""];
                                      [attachment.attachedView removeFromSuperview];
                                      *stop = YES;
                                  }
                              }];
    
    [self.delegate textDidChangeIn:self];
}

#pragma mark - Helper Methods

- (NSDictionary *)_textAttributes {
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: self.textColor,
        NSFontAttributeName: self.font,
        NSParagraphStyleAttributeName: self.paragraphStyle,
        NSBaselineOffsetAttributeName: @(fabs(self.font.descender / 2.0)),
    };
    return attributes;
}

- (void)_updateStyle {
    self.textView.font = self.font;
    self.textView.textColor = self.textColor;
    
    NSDictionary *textAttributes = [self _textAttributes];
    self.textView.typingAttributes = textAttributes;
    [self.textStorage setAttributes:textAttributes
                              range:NSMakeRange(0, self.textStorage.length)];
}

#pragma mark - UITextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textDidBeginEditing:)]) {
        [self.delegate textDidBeginEditing:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textDidEndEditing:)]) {
        [self.delegate textDidEndEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textDidChangeIn:)]) {
        [self.delegate textDidChangeIn:self];
    }
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    __block BOOL shouldChange = YES;
    NSMutableArray <RTViewAttachment *> *arr = [NSMutableArray array];
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                 inRange:range
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(id value, NSRange range, BOOL * stop) {
                                  if ([value isKindOfClass:[RTViewAttachment class]]) {
                                      RTViewAttachment *attachment = (RTViewAttachment *)value;
                                      [arr addObject:attachment];
                                  }
                              }];
    if (arr.count) {
        shouldChange = (![self.delegate respondsToSelector:@selector(attachmentTextView:shouldDeleteAttachments:)] ||
                        [self.delegate attachmentTextView:self
                                  shouldDeleteAttachments:[NSArray arrayWithArray:arr]]);
    }
    if (shouldChange) {
        arr = nil;
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:range
                                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                  usingBlock:^(id value, NSRange range, BOOL * stop) {
                                      if ([value isKindOfClass:[RTViewAttachment class]]) {
                                          RTViewAttachment *attachment = (RTViewAttachment *)value;
                                          if ([self.delegate respondsToSelector:@selector(attachmentTextView:willDeleteAttachment:)]) {
                                              [self.delegate attachmentTextView:self
                                                           willDeleteAttachment:attachment];
                                          }

                                          [self.textStorage removeAttribute:NSAttachmentAttributeName range:range];
                                          [attachment.attachedView removeFromSuperview];

                                          if ([self.delegate respondsToSelector:@selector(attachmentTextView:didDeleteAttachment:)]) {
                                              [self.delegate attachmentTextView:self
                                                            didDeleteAttachment:attachment];
                                          }
                                      }
                                  }];
    }
    return shouldChange;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    if ([textAttachment isKindOfClass:[RTViewAttachment class]]) {
        RTViewAttachment *attachment = (RTViewAttachment *)textAttachment;
        [attachment performInteration:interaction];
        return true;
    }
    
    return false;
}

@end
