//
//  AutoScrollTextView.m
//  AutoScrollTextView
//
//  Created by Migu on 2017/9/4.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "AutoScrollTextView.h"

@interface AutoScrollTextView() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSString *> *showingTexts;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation AutoScrollTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.showingTexts = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self addSubview:self.tableView];
}

- (void)beginAnimation {
    if (self.showingTexts.count == 0) {
        self.showingTexts = [self.texts mutableCopy];
        [self.tableView reloadData];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSString *firstText = self.showingTexts.firstObject;
        [self.showingTexts removeObjectAtIndex:0];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        
        [self.showingTexts insertObject:firstText atIndex:self.showingTexts.count];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.showingTexts.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    }];
}

- (void)endAnimation {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showingTexts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.showingTexts[indexPath.row];
    return cell;
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0.1;
    [UIView animateWithDuration:.1 animations:^{
        cell.alpha = 1;
    }];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [UIView animateWithDuration:.1 animations:^{
        cell.alpha = 0.1;
    }];
}

@end
