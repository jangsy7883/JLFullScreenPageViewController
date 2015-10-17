//
//  KMSegmented.m
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 6..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMSegmentedBar.h"

@interface KMSegmentedBar ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *highlightedContentView;
@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, strong) CALayer *maskLayer;

@property (nonatomic, assign) NSInteger currnetIndex;
@property (nonatomic, assign) CGPoint contentOffset;
@end

@implementation KMSegmentedBar

#pragma mark - init

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        _contentOffset = CGPointZero;
        _currnetIndex = 0;
        _itemSize = CGSizeMake(0, 50);
        _lineHeight = 3;
        
        _font = [UIFont systemFontOfSize:15];
        _titleColor = [UIColor whiteColor];
        _highlightedTitleColor = [UIColor blackColor];
        
    }
    return self;
}

#pragma mark - view lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.shadowView.frame = CGRectMake(0,
                                       CGRectGetHeight(self.bounds),
                                       CGRectGetWidth(self.bounds),
                                       self.shadowImage.size.height);
    
    NSInteger count = [[self.dataSource titlesInSegmentedBar:self] count];
    
    if (self.itemSize.width == 0)
    {
        self.itemSize = CGSizeMake(CGRectGetWidth(self.bounds) / count, self.itemSize.height);
    }
    
    for (UIView *view in @[self.contentView,self.highlightedContentView])
    {
        view.frame = self.bounds;
        
        CGRect rect = CGRectMake((CGRectGetWidth(view.frame) - (self.itemSize.width * count))/ 2,
                                 0,
                                 self.itemSize.width,
                                 CGRectGetHeight(view.frame));
        
        for (UIView *subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIButton class]])
            {
                subview.frame = rect;
                rect.origin.x = CGRectGetMaxX(rect);
            }
        }
    }
    
    [self layoutSegmentedBarWithContentOffset:_contentOffset];
}

- (void)layoutSegmentedBarWithContentOffset:(CGPoint)contentOffset
{
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        return;
    }
    
    int index = contentOffset.x/CGRectGetWidth(self.bounds);
    CGFloat offset = contentOffset.x/CGRectGetWidth(self.bounds) - index;
    
    CGRect oldRect = [self rectAtButtonIndex:index];
    CGRect newRect = [self rectAtButtonIndex:(offset > 0) ? index+1 : index];
 
    CGRect rect = CGRectMake(MAX(0, CGRectGetMinX(oldRect) + ((CGRectGetMinX(newRect) - CGRectGetMinX(oldRect)) * offset)),
                             CGRectGetHeight(self.bounds)- _lineHeight,
                             MAX(0, CGRectGetWidth(oldRect) + ((CGRectGetWidth(newRect) - CGRectGetWidth(oldRect)) * offset)),
                             _lineHeight);
    
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
        NSString *title = [button titleForState:UIControlStateNormal];
        CGRect rect = CGRectMake(0,
                                 CGRectGetHeight(self.bounds)- _lineHeight,
                                 0,
                                 _lineHeight);
        
        rect.size.width = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           attributes:@{
                                                        NSFontAttributeName:button.titleLabel.font
                                                        }
                                              context:nil].size.width;

        rect.origin.x = CGRectGetMinX(button.frame) + ((CGRectGetWidth(button.frame) - CGRectGetWidth(rect)) / 2);

        return rect;
    }
    else
    {
        return CGRectZero;
    }
}

#pragma mark - scroll

- (void)scrollDidContentOffset:(CGPoint)contentOffset
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

- (void)setLineColor:(UIColor *)lineColor
{
    self.lineView.backgroundColor = lineColor;
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
        _maskLayer.contents = (id)[self circleImageColor:[UIColor blackColor] size:self.itemSize].CGImage;
        
        _highlightedContentView.layer.mask = _maskLayer;
    }
    return _maskLayer;
}

- (UIColor*)lineColor
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

