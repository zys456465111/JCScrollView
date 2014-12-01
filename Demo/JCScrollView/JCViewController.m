//
//  JCViewController.m
//  JCScrollView
//
//  Created by JayChou on 14-10-27.
//  Copyright (c) 2014年 zys. All rights reserved.
//

#import "JCViewController.h"
#import "JCScrollView.h"

@interface JCViewController () <UIScrollViewDelegate, JCScrollViewDelegate>
@property (nonatomic, weak)IBOutlet JCScrollView *jcSV;
@end

@implementation JCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.jcSV addImageNames:@[@"1",@"2",@"3",@"4"]];
//    self.jcSV.pageControlEnabled = NO;
    self.jcSV.animationDuration = 0.8;
    self.jcSV.animationDelegate = self;
    self.jcSV.scrollDirection = JCScrollViewScrollDirectionVertical;
}

int i = 0;
- (IBAction)changeDirection {
    i = i == 1 ? 0 : 1;
    [self.jcSV setScrollDirection:i animated:YES];

}

int o = 0;
- (IBAction)addImageLast {

    if (o++ == 3)
        o = 0;
    
    NSArray *array = @[@"1",@"2",@"3",@"4"];
    [self.jcSV addImageName:array[o]];
}

/**
 *  insert lots of images
 */
- (void)addImages {

    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    [self.jcSV insertImageNames:@[@"jay_1",@"jay_2.jpg"] atIndex:set];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - jcScrollViewDelegate

/**
 *  动画开始就会调用
 */
- (void)scrollViewDidBeginAnimating:(JCScrollView *)scrollView {
    NSLog(@"动画开始");
}

/**
 *  动画结束就会调用
 */
- (void)scrollViewDidEndAnimating:(JCScrollView *)scrollView {
    NSLog(@"动画结束");
}

@end
