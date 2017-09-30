//
//  AutoScrollTextView.m
//  AutoScrollTextView
//
//  Created by Migu on 2017/9/4.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "AutoScrollTextView.h"

@interface AutoScrollTextView() {
    NSTimer *timer;
    NSInteger index;
}
@property (nonatomic, strong) NSMutableArray<UILabel *> *reusableLabels;
@property (nonatomic, assign) BOOL animating;
@end

@implementation AutoScrollTextView

static CGFloat const labelHeight = 24.0;
static CGFloat const maxShowingLabels = 4.0;
static NSTimeInterval const animationDuration = 4.0;

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)beginAnimation {
    if (self.animating) {
        return;
    }
    self.animating = YES;
    
    CGFloat speed = animationDuration / (CGRectGetHeight(self.frame) - labelHeight);
    CGFloat gap = (CGRectGetHeight(self.frame) - labelHeight * maxShowingLabels) / (maxShowingLabels -1);
    index = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:speed*(labelHeight+gap) target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes]; // ScrollView滑动的时候，默认Timer会停止，加到滑动RunLoop就不会了
}

- (void)endAnimation {
    [timer invalidate];
    timer = nil;
    self.animating = NO;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
            [self.reusableLabels addObject:(UILabel *)subview];
        }
    }
}

- (void)tick:(NSTimer *)sender {
    UILabel *label = [self dequeueResuableCell];
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, labelHeight)];
    }
    
    label.text = self.texts[index];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    label.clipsToBounds = YES;
    label.layer.cornerRadius = labelHeight/2;
    label.alpha = 0;
    [self addSubview:label];
    [label sizeToFit];
    CGFloat labelWidth = CGRectGetWidth(label.frame);
    labelWidth += 8; // 前后留白
    if (labelWidth < labelHeight) {
        labelWidth = labelHeight; // 防止出现()这种情况
    }
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[label(labelWidth)]" options:0 metrics:@{@"labelWidth": @(labelWidth)} views:NSDictionaryOfVariableBindings(label)]];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:bottomConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:labelHeight]];
    [self layoutIfNeeded];
    
    // 滚动
    bottomConstraint.constant = CGRectGetHeight(self.frame) - labelHeight;
    // UIViewKeyframeAnimationOptionCalculationModeLinear没有效果，用UIViewAnimationOptionCurveLinear再包一层
    [UIView animateWithDuration:animationDuration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [UIView animateKeyframesWithDuration:0 /*inderited*/ delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0/maxShowingLabels animations:^{
                label.alpha = 1;
            }];
            [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                [self layoutIfNeeded];
            }];
            [UIView addKeyframeWithRelativeStartTime:(maxShowingLabels-1.0)/maxShowingLabels relativeDuration:1.0/maxShowingLabels animations:^{
                label.alpha = 0;
            }];
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
            [self.reusableLabels addObject:label];
        }];
    } completion:^(BOOL finished) { }];
    
    index += 1;
    if (index > self.texts.count - 1) {
        index = 0;
    }
}

- (UILabel *)dequeueResuableCell {
    if (self.reusableLabels.count) {
        UILabel *label = self.reusableLabels.firstObject;
        [self.reusableLabels removeObject:label];
        return label;
    }
    return nil;
}

@end
