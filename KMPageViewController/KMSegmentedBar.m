//
//  KMSegmented.m
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 6..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMSegmentedBar.h"

@interface KMSegmentedBar ()

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *highlightedContentView;
@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, strong) CALayer *maskLayer;

@property (nonatomic, assign) NSInteger currnetIndex;
@property (nonatomic, assign) CGFloat contentOffset;

@end

@implementation KMSegmentedBar

#pragma mark - init

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    _barItmeSizFit = NO;
    _contentOffset = 0;
    _currnetIndex = 0;
    _itemSize = CGSizeZero;
    _separatorHeight = 3;
    _fitMargin = 17;
    
    _font = [UIFont systemFontOfSize:15];
    _titleColor = [UIColor whiteColor];
    _highlightedTitleColor = [UIColor blackColor];
}
- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self commonInit];
    }
    return self;
}

#pragma mark - view lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //SHADOW VIEW
    self.shadowView.frame = CGRectMake(0,
                                       CGRectGetHeight(self.bounds),
                                       CGRectGetWidth(self.bounds),
                                       self.shadowImage.size.height);
    
    NSInteger count = [[self.dataSource titlesInSegmentedBar:self] count];
    CGRect rect = CGRectZero;
    
    for (UIView *view in @[self.contentView,self.highlightedContentView])
    {
        view.frame = self.bounds;
        
        rect.origin.x = _barItmeSizFit ? 1.5 : (CGRectGetWidth(view.frame) - ((CGRectGetWidth(view.bounds) / count) * count))/ 2;
        rect.size = CGSizeMake(CGRectGetWidth(view.bounds) / count,
                               CGRectGetHeight(view.bounds));
        
        for (UIView *subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIButton class]])
            {
                if (_barItmeSizFit)
                    rect.size.width = [self contentSizeForButton:(UIButton*)subview].width + _fitMargin;
                
                subview.frame = rect;
                rect.origin.x = CGRectGetMaxX(rect);
            }
        }
    }
    
    [self layoutSeparatorWithContentOffset:_contentOffset];
}

- (void)layoutSeparatorWithContentOffset:(CGFloat)contentOffset
{
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        return;
    }
    
    int index = contentOffset;
    CGFloat offset = contentOffset - index;
    
    CGRect oldRect = [self rectAtButtonIndex:index];
    CGRect newRect = [self rectAtButtonIndex:(offset > 0) ? index+1 : index];
    
    CGRect rect = CGRectMake(MAX(0, CGRectGetMinX(oldRect) + ((CGRectGetMinX(newRect) - CGRectGetMinX(oldRect)) * offset)),
                             CGRectGetHeight(self.bounds)- _separatorHeight,
                             MAX(0, CGRectGetWidth(oldRect) + ((CGRectGetWidth(newRect) - CGRectGetWidth(oldRect)) * offset)),
                             _separatorHeight);
    
    self.lineView.frame = rect;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.0];
    self.maskLayer.frame = CGRectMake(CGRectGetMinX(rect)-5,
                                      0,
                                      CGRectGetWidth(rect)+10,
                                      CGRectGetHeight(self.bounds)+10);
    [CATransaction commit];
    
    if (offset == 0)
    {
        _currnetIndex = index;
    }
}
#pragma mark - reload

- (void)reloadData
{
    for (UIView *view in @[self.contentView,self.highlightedContentView])
    {
        for (UIView *subview in view.subviews)
        {
            [subview removeFromSuperview];
        }
    }
    
    NSArray *titles = [self.dataSource titlesInSegmentedBar:self];
    
    UIButton *button = nil;
    
    for (int i = 0 ; i < [titles count]; i++)
    {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button.titleLabel setFont:self.font];
        [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];
        [self.contentView addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button.titleLabel setFont:self.font];
        [button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        [button setTitleColor:self.highlightedTitleColor forState:UIControlStateNormal];
        
        [self.highlightedContentView addSubview:button];
    }
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - event

- (IBAction)pressedButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(segmentedBar:didSelectIndex:)])
    {
        [self.delegate segmentedBar:self didSelectIndex:[sender tag]];
    }
}

#pragma mark - frame

- (CGSize)contentSizeForButton:(UIButton*)button
{
    if ([button isKindOfClass:[UIButton class]])
    {
        NSString *title = [button titleForState:UIControlStateNormal];
        
        return [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                attributes:@{
                                             NSFontAttributeName:button.titleLabel.font
                                             }
                                   context:nil].size;
    }
    
    return CGSizeZero;
}

- (CGRect)rectAtButtonIndex:(NSInteger)index
{
    index = MAX(0, MIN([self.contentView.subviews count]-1, index));
    
    UIButton *button = nil;
    for (UIButton *subview in self.contentView.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag == index)
        {
            button = subview;
            break;
        }
    }
    
    if (button)
    {
        CGRect rect = CGRectMake(0,
                                 CGRectGetHeight(self.bounds)- _separatorHeight,
                                 [self contentSizeForButton:button].width,
                                 _separatorHeight);
        
        rect.origin.x = CGRectGetMinX(button.frame) + ((CGRectGetWidth(button.frame) - CGRectGetWidth(rect)) / 2);
        
        return rect;
    }
    else
    {
        return CGRectZero;
    }
}

#pragma mark - scroll

- (void)scrollDidContentOffset:(CGFloat)contentOffset
{
    _contentOffset = contentOffset;
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - SETTERS

- (void)setShadowImage:(UIImage *)shadowImage
{
    _shadowImage = shadowImage;
    
    if (shadowImage)
    {
        self.shadowView = [[UIView alloc] init];
        self.shadowView.backgroundColor = [UIColor colorWithPatternImage:_shadowImage];
        [self addSubview:self.shadowView];
    }
    else if (self.shadowView != nil)
    {
        [self.shadowView removeFromSuperview];
        self.shadowView = nil;
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    self.lineView.backgroundColor = separatorColor;
}

#pragma mark - GETTERS

- (UIView*)contentView
{
    if (!_contentView)
    {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIView*)highlightedContentView
{
    if (!_highlightedContentView)
    {
        _highlightedContentView = [[UIView alloc] init];
        _highlightedContentView.clipsToBounds = YES;
        [self addSubview:_highlightedContentView];
    }
    return _highlightedContentView;
}

- (UIView*)lineView
{
    if (!_lineView)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor clearColor];
        [self addSubview:_lineView];
    }
    return _lineView;
}

- (CALayer*)maskLayer
{
    if (!_maskLayer)
    {
        _maskLayer = [CALayer layer];
        _maskLayer.contents = (id)[self circleImageColor:[UIColor blackColor] size:CGSizeMake(40, 40)].CGImage;
        
        _highlightedContentView.layer.mask = _maskLayer;
    }
    return _maskLayer;
}

- (UIColor*)separatorColor
{
    return self.lineView.backgroundColor;
}

#pragma mark - IMAGE

- (UIImage *)circleImageColor:(UIColor *)color size:(CGSize)size
{
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    {
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPoint pos = CGPointMake(size.width/2, size.height/2);
        CGAffineTransform trans = CGAffineTransformMake(1, 0, 0, 1, pos.x, pos.y);
        CGRect rect=(CGRect){.origin = CGPointMake(-pos.x, -pos.y), .size = size};
        CGPathAddEllipseInRect(path, &trans, rect);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextAddPath(context, path);
        CGContextEOFillPath(context);
        
        CGPathRelease(path);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
