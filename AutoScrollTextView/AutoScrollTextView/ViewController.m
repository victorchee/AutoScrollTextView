//
//  ViewController.m
//  AutoScrollTextView
//
//  Created by Migu on 2017/9/4.
//  Copyright © 2017年 VictorChee. All rights reserved.
//

#import "ViewController.h"
#import "AutoScrollTextView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet AutoScrollTextView *autoScrollTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.autoScrollTextView.texts = @[@"静夜思", @"床前明月光", @"疑是地上霜", @"举头望明月", @"低头思故乡"];
    [self.autoScrollTextView beginAnimation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
