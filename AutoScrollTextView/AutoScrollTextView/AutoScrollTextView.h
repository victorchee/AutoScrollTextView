//
//  AutoScrollTextView.h
//  AutoScrollTextView
//
//  Created by Migu on 2017/9/4.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoScrollTextView : UIView

@property (nonatomic, strong) NSArray<NSString *> *texts;

- (void)beginAnimation;
- (void)endAnimation;

@end
