//
//  RTViewAttachment.h
//  Pods
//
//  Created by Ricky on 16/6/17.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTViewAttachment : NSTextAttachment

/**
 *  The view you want to attach to the text editor, please set its size before attaching to a text editor
 */
@property (nonatomic, strong) __kindof UIView *attachedView;

/**
 *  This is the text that will be outputed when use copy from text editor
 */
@property (nonatomic, copy, nullable) NSString *placeholderText;

/**
 *  If this property is set to `YES`, the attachedView.bounds.size.width will be the text editor's edit area width
 */
@property (nonatomic, assign, getter=isFullWidth) BOOL fullWidth;

@property (nonatomic, strong, nullable) id userInfo;
@property (nonatomic, assign) NSInteger tag;


- (instancetype)initWithView:(UIView *_Nullable)view;
- (instancetype)initWithView:(UIView *_Nullable)view
             placeholderText:(NSString * _Nullable)text;
- (instancetype)initWithView:(UIView *_Nullable)view
             placeholderText:(NSString * _Nullable)text
                   fullWidth:(BOOL)fullWidth NS_DESIGNATED_INITIALIZER;

- (void)performInteration:(UITextItemInteraction)interation;

@end

NS_ASSUME_NONNULL_END
