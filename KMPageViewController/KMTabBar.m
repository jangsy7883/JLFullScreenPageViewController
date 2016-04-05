//
//  KMTabBar.m
//  KMPageViewControllerDemo
//
//  Created by Jangsy7883 on 2016. 4. 5..
//  Copyright © 2016년 Dalkomm. All rights reserved.
//

#import "KMTabBar.h"

@interface KMTabBar ()

@property (nonatomic,strong) UIView *contentBackgroundView;
@end

@implementation KMTabBar

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _customHeight = 49;
        
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _customHeight = 49;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _customHeight = 49;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    

    if (self.contentBackgroundView == nil)
    {
        self.contentBackgroundView = [[UIView alloc] init];
        self.contentBackgroundView.backgroundColor = [UIColor redColor];
        [self addSubview:self.contentBackgroundView];
    }
    
    self.contentBackgroundView.frame = self.bounds;
    
    if ([self.subviews.firstObject isEqual:self.contentBackgroundView] == NO)
    {
        [self sendSubviewToBack:self.contentBackgroundView];
    }
}

-(CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.height = _customHeight;
    
    return sizeThatFits;
}

@end
