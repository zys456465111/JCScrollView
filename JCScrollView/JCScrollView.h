//
//  JCScrollView.h
//  JCScrollView
//
//  Created by JayChou on 14-10-27.
//  Copyright (c) 2014年 zys. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JCScrollView;
@protocol JCScrollViewDelegate <NSObject>

/**
 *  动画开始就会调用
 */
- (void)scrollViewDidBeginAnimating:(JCScrollView *)scrollView;

/**
 *  动画结束就会调用
 */
- (void)scrollViewDidEndAnimating:(JCScrollView *)scrollView;

@end

/**
 *  滚动方向
 */
typedef enum {
    
    JCScrollViewScrollDirectionHorizontal = 0,
    
    JCScrollViewScrollDirectionVertical
    
}JCScrollViewScrollDirection;

@interface JCScrollView : UIScrollView

/**
 *  动画代理
 */
@property (nonatomic, weak)id<JCScrollViewDelegate> animationDelegate;

/**
 *  滚动方向
 */
@property (nonatomic, assign)JCScrollViewScrollDirection scrollDirection;

/**
 *  样式可以拿去设置
 */
@property (nonatomic, strong)UIPageControl *pageControl;

/**
 *  pageControl,默认开启
 */
@property (nonatomic, assign, getter = isPageControlEnabled)BOOL pageControlEnabled;

/**
 *  动画执行时间，当你调用这个方法时才用，默认- (void)setScrollDirection:(JCScrollViewScrollDirection)direction animated:(BOOL)animated;
 */
@property (nonatomic, assign)CGFloat animationDuration;

/**
 *  正在动画
 */
@property (nonatomic, assign, readonly, getter = isAnimating)BOOL animating;
/**
 *  添加多张图片名称
 *
 */
- (void)addImageNames:(NSArray *)names;

/**
 *  添加单张图片名称
 *
 */
- (void)addImageName:(NSString *)name;

/**
 *  添加单张图片在指定位置
 */
- (void)insertImageName:(NSString *)name atIndex:(NSUInteger)index;

/**
 *  添加多张图片在指定位置
 *
 */
- (void)insertImageNames:(NSArray *)names atIndex:(NSIndexSet *)indexes;

/**
 *  改变滚动方向
 *
 *  @param direction 方向
 *  @param animated  动画
 */
- (void)setScrollDirection:(JCScrollViewScrollDirection)direction animated:(BOOL)animated;

/**
 *  快速创建
 */
+ (instancetype)scrollViewWithFrame:(CGRect)frame andImageNames:(NSArray *)imageNames;

@end
