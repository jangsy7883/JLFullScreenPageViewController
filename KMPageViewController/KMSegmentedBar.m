//
//  KMSegmented.m
//  KMSegmentedPager
//
//  Created by Jangsy7883 on 2015. 9. 6..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "KMSegmentedBar.h"

@interface KMSegmentedBar ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *highlightedContentView;
@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic, strong) CALayer *maskLayer;

@property (nonatomic, assign) CGFloat contentOffset;

@end

@implementation KMSegmentedBar

#pragma mark - init

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    _barStyle = KMSegmentedBarStyleEqualMargin;
    _contentOffset = 0;
    _separatorHeight = 3;
    
    _itemMergin = 0;
    _contentInsets = UIEdgeInsetsMake(3, 12, 0, 12);
    
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

- (CGFloat)equalMarginWithAllButtonSize:(CGSize)size withButtonCount:(NSInteger)count
{
    return ((CGRectGetWidth(self.bounds) - (MAX(0, self.contentInsets.left - (_itemMergin/2)) + MAX(0, self.contentInsets.right - (_itemMergin/2)))) - (([self contentSizeForAllButtons].width) + (_itemMergin*count))) / (count-1);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //SHADOW VIEW
    self.shadowView.frame = CGRectMake(0,
                                       CGRectGetHeight(self.bounds),
                                       CGRectGetWidth(self.bounds),
                                       self.shadowImage.size.height);
    
    CGFloat margin = 0;
    NSInteger count = [[self.dataSource titlesInSegmentedBar:self] count];
    CGRect rect = CGRectZero;
    
    for (UIView *view in @[self.contentView,self.highlightedContentView])
    {
        view.frame = self.bounds;
        
        //FIRST X, SIZE
        rect.size.height = CGRectGetHeight(view.bounds) - (self.contentInsets.top+self.contentInsets.bottom);
        
        switch (_barStyle)
        {
            case KMSegmentedBarStyleRightFit:
                rect.origin = CGPointMake(MAX(0, self.contentInsets.left - (_itemMergin/2)), self.contentInsets.top);
                break;
            case KMSegmentedBarStyleEqualSegment:
                rect.origin = CGPointMake(self.contentInsets.left, self.contentInsets.top);
                rect.size.width = (CGRectGetWidth(view.bounds) - (self.contentInsets.left + self.contentInsets.right)) / count;
                break;
            case KMSegmentedBarStyleEqualMargin:
                rect.origin = CGPointMake(MAX(0, self.contentInsets.left - (_itemMergin/2)), self.contentInsets.top);
                margin = [self equalMarginWithAllButtonSize:[self contentSizeForAllButtons] withButtonCount:count];
                break;
            default:
                break;
        }
        
        for (UIView *subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIButton class]])
            {
                //WIDTH
                switch (_barStyle) {
                    case KMSegmentedBarStyleRightFit:
                        rect.size.width = [self contentSizeForButton:(UIButton*)subview].width + _itemMergin;
                        break;
                    case KMSegmentedBarStyleEqualMargin:
                        rect.size.width = [self contentSizeForButton:(UIButton*)subview].width + _itemMergin;
                        break;
                    default:
                        break;
                }
                
                //SET FRAME
                subview.frame = rect;
                
                //NEXT X
                switch (_barStyle) {
                    case KMSegmentedBarStyleEqualMargin:
                        rect.origin.x = CGRectGetMaxX(rect) + margin;
                        break;
                    default:
                        rect.origin.x = CGRectGetMaxX(rect);
                        break;
                }
            }
        }
    }
    [self layoutSeparatorWithContentOffset:_contentOffset animated:NO];
}

- (void)layoutSeparatorWithContentOffset:(CGFloat)contentOffset animated:(BOOL)animated
{
    if (CGRectEqualToRect(self.bounds, CGRectZero))
    {
        return;
    }
    
    int index = contentOffset;
    CGFloat offset = contentOffset - index;
    CGFloat mergin = 20;
    
    CGRect oldRect = [self rectAtButtonIndex:index];
    CGRect newRect = [self rectAtButtonIndex:(offset > 0) ? index+1 : index];
    
    
    CGRect rect = CGRectMake(MAX(0, (CGRectGetMinX(oldRect)-(mergin/2)) + (((CGRectGetMinX(newRect)-(mergin/2)) - (CGRectGetMinX(oldRect)-(mergin/2))) * offset)),
                             CGRectGetHeight(self.bounds) - _separatorHeight - _contentInsets.bottom,
                             MAX(0, (CGRectGetWidth(oldRect)+mergin) + (((CGRectGetWidth(newRect)+mergin) - (CGRectGetWidth(oldRect)+mergin)) * offset)),
                             _separatorHeight);
    
    if (animated)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.lineView.frame = rect;
        }];
    }
    else
    {
        self.lineView.frame = rect;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:animated ? 0.25 : 0.0];
    self.maskLayer.frame = CGRectMake(CGRectGetMinX(rect)-5,
                                      0,
                                      CGRectGetWidth(rect)+10,
                                      CGRectGetHeight(self.bounds)+10);
    [CATransaction commit];
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

- (CGSize)contentSizeForAllButtons
{
    CGFloat width = 0;
    
    for (UIView *subview in self.contentView.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            width += [self contentSizeForButton:(UIButton*)subview].width;
        }
    }
    
    return CGSizeMake(width, CGRectGetHeight(self.bounds) - (self.contentInsets.top+self.contentInsets.bottom));
}

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
    
    [self layoutSeparatorWithContentOffset:_contentOffset animated:NO];
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

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated
{
    if (animated)
    {
        if (_contentOffset != selectedIndex)
        {
            _contentOffset = selectedIndex;
            [self layoutSeparatorWithContentOffset:_contentOffset animated:YES];
        }
        
    }
    else
    {
        [self scrollDidContentOffset:selectedIndex];
    }
}
#pragma mark - GETTERS

- (NSInteger)selectedIndex
{
    return ceilf(_contentOffset);
}

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
