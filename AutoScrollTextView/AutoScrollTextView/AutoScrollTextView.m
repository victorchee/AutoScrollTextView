//
//  AutoScrollTextView.m
//  AutoScrollTextView
//
//  Created by Migu on 2017/9/4.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "AutoScrollTextView.h"

@interface AutoScrollTextView()
@property (nonatomic, strong) NSMutableArray<UILabel *> *reusableLabels;
@property (nonatomic, assign) BOOL animating;
@end

@implementation AutoScrollTextView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)beginAnimation {
    CGFloat labelHeight = 30.0;
    CGFloat maxShowingLabels = 4.0;
    NSTimeInterval animationDuration = 4.0;
    self.animating = YES;
    
    __block NSInteger index = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        while (self.animating) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UILabel *label = [self dequeueResuableCell];
                if (!label) {
                    label = [[UILabel alloc] init];
                }
                
                label.text = [[@"  " stringByAppendingString:self.texts[index]] stringByAppendingString:@"  "];
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = [UIColor lightGrayColor];
                label.clipsToBounds = YES;
                label.layer.cornerRadius = labelHeight/2;
                label.alpha = 0;
                [self addSubview:label];
                
                label.translatesAutoresizingMaskIntoConstraints = NO;
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
                NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
                [self addConstraint:bottomConstraint];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:labelHeight]];
                [self layoutIfNeeded];
                
                // 滚动
                bottomConstraint.constant = CGRectGetHeight(self.frame) - labelHeight;
                [UIView animateKeyframesWithDuration:animationDuration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5/maxShowingLabels animations:^{
                        label.alpha = 1;
                    }];
                    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
                        [self layoutIfNeeded];
                    }];
                    [UIView addKeyframeWithRelativeStartTime:(maxShowingLabels-1)/maxShowingLabels relativeDuration:1.0/maxShowingLabels animations:^{
                        label.alpha = 0;
                    }];
                } completion:^(BOOL finished) {
                    [label removeFromSuperview];
                    [self.reusableLabels addObject:label];
                }];
                
                index += 1;
                if (index > self.texts.count - 1) {
                    index = 0;
                }
            });
            
            
            sleep(animationDuration * 1.0/maxShowingLabels);
        }
    });
}

- (void)endAnimation {
    self.animating = NO;
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
