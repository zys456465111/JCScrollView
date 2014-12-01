//
//  JCScrollView.m
//  JCScrollView
//
//  Created by JayChou on 14-10-27.
//  Copyright (c) 2014年 zys. All rights reserved.
//

#import "JCScrollView.h"

//direction Next -1 Previous 1便于后面计算
typedef enum {
    JCScrollViewMoveDirectionNext = -1,
    JCScrollViewMoveDirectionPrevious = 1
}JCScrollViewMoveDirection;

@interface JCScrollView ()

/**
 *  循环利用imageView数组
 */
@property (nonatomic, strong)NSArray *imageViews;

/**
 *  记录当前的索引
 */
@property (nonatomic, assign)NSInteger currentIndex;

/**
 *  图片数组
 */
@property (nonatomic, strong)NSMutableArray *imageNames;

@end

@implementation JCScrollView

+ (instancetype)scrollViewWithFrame:(CGRect)frame andImageNames:(NSArray *)imageNames {
    JCScrollView *jcSV = [[JCScrollView alloc]initWithFrame:frame];
    jcSV.imageNames = [NSMutableArray arrayWithArray:imageNames];
    return jcSV;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex == 3) {
        currentIndex = 0;
    } else if (currentIndex == -1) {
        currentIndex = 2;
    }
    _currentIndex = currentIndex;
}

- (void)setScrollDirection:(JCScrollViewScrollDirection)scrollDirection {
    if (_scrollDirection == scrollDirection) return;
    
    [self setScrollDirection:scrollDirection animated:NO];
    
    _scrollDirection = scrollDirection;
}

- (void)setPageControlEnabled:(BOOL)pageControlEnabled {
    
    if(_pageControlEnabled == pageControlEnabled) return;
    
    if(pageControlEnabled)
        [self.superview addSubview:self.pageControl];
    else
        [self.pageControl removeFromSuperview];
    
    _pageControlEnabled = pageControlEnabled;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    
    [super setContentOffset:contentOffset];
    
    NSUInteger prePage = self.pageControl.currentPage;
    
    switch (_scrollDirection) {
        case JCScrollViewScrollDirectionHorizontal:
            
            _pageControl.currentPage = contentOffset.x / self.bounds.size.width + 0.5;
            
            break;
            
        case JCScrollViewScrollDirectionVertical:
            
            _pageControl.currentPage = contentOffset.y / self.bounds.size.height + 0.5;
            
            break;
        default:
            break;
    }
    
    if (_pageControl.currentPage > prePage) {   //图片向前走
        
        [self moveImageViewWithDirection:JCScrollViewMoveDirectionNext];
        
    } else if (_pageControl.currentPage < prePage) {
        
        [self moveImageViewWithDirection:JCScrollViewMoveDirectionPrevious];
        
    }
    
}

- (NSArray *)imageViews {
    if (!_imageViews) {
        
        NSMutableArray *imageViews = [NSMutableArray array];
        
        /**
         *  如果图片数量小于3张，就只创建图片数量的imageView
         */
        NSInteger count = self.imageNames.count < 3 ? self.imageNames.count + 1 : 3;
        int startNum = self.imageNames.count < 3 ? 1 : 0;
        for (int i = startNum; i<count; i++) {
            
            UIImageView *imageView = [[UIImageView alloc]init];
            
            //第0张不用设置图片
            if (i)
                imageView.image = [UIImage imageNamed:self.imageNames[i-1]];
            
            switch (_scrollDirection) {
                case JCScrollViewScrollDirectionHorizontal:
                    
                    imageView.frame = (CGRect){{(i-1) * self.bounds.size.width, 0},self.bounds.size};
                    
                    break;
                    
                case JCScrollViewScrollDirectionVertical:
                    
                    imageView.frame = (CGRect){{0, (i-1) * self.bounds.size.height},self.bounds.size};
                    
                    break;
                    
                default:
                    break;
                    
            }
            
            /*
             UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
             label.text = [NSString stringWithFormat:@"%d",i];
             label.font= [UIFont systemFontOfSize:32];
             [imageView addSubview:label];
             */
            
            [imageViews addObject:imageView];
            [self addSubview:imageView];
        }
        
        _imageViews = imageViews;
        
    }
    return _imageViews;
}

- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        _pageControl.numberOfPages = _imageNames.count;
        _pageControl.hidesForSinglePage = YES;
    }
    
    return _pageControl;
}

- (void)setAnimating:(BOOL)animating {
    _animating = animating;
    
    self.userInteractionEnabled = !animating;
}

- (void)setImageNames:(NSMutableArray *)imageNames {
    _imageNames = imageNames;
    
    [self resizeContentWithIndex:-1];
}

- (void)addImageName:(NSString *)name {
    [self.imageNames addObject:name];
    
    [self resizeContentWithIndex:self.imageNames.count];
}

- (void)addImageNames:(NSArray *)names {
    [self.imageNames addObjectsFromArray:names];
    
    [self resizeContentWithIndex:self.imageNames.count];
}

- (void)insertImageName:(NSString *)name atIndex:(NSUInteger)index {
    [self.imageNames insertObject:name atIndex:index];
    
    [self resizeContentWithIndex:index];
}

- (void)insertImageNames:(NSArray *)names atIndex:(NSIndexSet *)indexes {
    [self.imageNames insertObjects:names atIndexes:indexes];
    
    [self resizeContentWithIndex:[indexes firstIndex]];
}

- (void)resizeContentWithIndex:(NSUInteger)index {
    //没必要每次都设置content大小，所以在这里设置
    //添加到数组中，默认显示第一张，让第0张退出屏幕
    switch (_scrollDirection) {
        case JCScrollViewScrollDirectionHorizontal:
        {
            self.contentSize = CGSizeMake(_imageNames.count * self.bounds.size.width, 0);
            
            break;
        }
            
        case JCScrollViewScrollDirectionVertical:
        {
            self.contentSize = CGSizeMake(0, _imageNames.count * self.bounds.size.height);
            
            break;
        }
        default:
            break;
    }
    
    self.pageControl.numberOfPages = _imageNames.count;
    
    if (index == -1)
        return;
    
    //插入图片操作，顺序插入
    if (self.pageControl.currentPage < index) {
        
        self.currentIndex--;
        [self moveImageViewWithDirection:JCScrollViewMoveDirectionNext];
        
        //逆序插入
    } else if (self.pageControl.currentPage > index) {
        
        self.currentIndex++;
        [self moveImageViewWithDirection:JCScrollViewMoveDirectionPrevious];
        
        //插入的图片那正好是当前图片
    } else if (self.pageControl.currentPage == index) {
        
        [self setImageWithImageIndex:self.currentIndex andImageNameIndex:index];
        
    }
    
}

/**
 *  转换垂直或水平滚动时子控件重新布局
 */
- (void)convertImageViewsBetweenHorizontalAndVertical {
    
    for (UIImageView *imageView in self.imageViews) {
        //只改变当前这张
        
        //还原一下尺寸
        //        imageView.transform = CGAffineTransformIdentity;
        
        switch (self.scrollDirection) {
            case JCScrollViewScrollDirectionHorizontal:
                //来到这里的imageView说明以前是垂直的，也就是说x为0 y有值，那么就转换一下
            {
                NSInteger currentPage = imageView.frame.origin.y / self.bounds.size.height;
                imageView.frame = (CGRect){{currentPage * self.bounds.size.width,0},imageView.bounds.size};
                //                NSLog(@"%@",NSStringFromCGRect(imageView.frame));
                break;
            }
            case JCScrollViewScrollDirectionVertical:
            {
                NSInteger currentPage = imageView.frame.origin.x / self.bounds.size.width;
                imageView.frame = (CGRect){{0,currentPage * self.bounds.size.height},imageView.bounds.size};
                break;
            }
            default:
                break;
        }
        
    }
    
    //要同时进行，不知不觉中切换，暗度陈仓
    switch (self.scrollDirection) {
        case JCScrollViewScrollDirectionHorizontal:
            
            [self setContentOffset:CGPointMake(self.pageControl.currentPage * self.bounds.size.width, 0)];
            
            break;
            
        case JCScrollViewScrollDirectionVertical:
            
            [self setContentOffset:CGPointMake(0, self.pageControl.currentPage * self.bounds.size.height)];
            
            break;
            
        default:
            break;
    }
    
    [self resizeContentWithIndex:-1];
}

/**
 *  动态切换滚动方向
 *
 *  @param direction 方向
 *  @param animated  是否执行动画
 */
- (void)setScrollDirection:(JCScrollViewScrollDirection)direction animated:(BOOL)animated {
    
    if (!animated) {
        /**
         *  方向相同不执行
         */
        if (_scrollDirection == direction) return;
        _scrollDirection = direction;
        [self convertImageViewsBetweenHorizontalAndVertical];
        return;
    }
    
    if (self.isAnimating)
        return;
    
    void (^JCAffineTransformTranslate)(UIImageView*, CGFloat, CGFloat) = ^(UIImageView *imageView, CGFloat tx, CGFloat ty){
        
        CGRect imageframe = imageView.frame;
        imageframe.origin.x += tx;
        imageframe.origin.y += ty;
        imageView.frame = imageframe;
        
    };
    
    void (^JCAffineTransformScale)(UIImageView*, CGFloat) = ^(UIImageView *imageView, CGFloat scale){
        CGRect imageBounds = imageView.bounds;
        imageBounds.size.width *= scale;
        imageBounds.size.height *= scale;
        imageView.bounds = imageBounds;
    };
    
    /**
     *  缩放比例 占据屏幕的3分之一
     */
    CGFloat scale = 0.33;
    
    /**
     *  动画时长
     */
    CGFloat duration = self.animationDuration;
    
    self.animating = YES;
    
    /**
     *   通知代理开始动画
     */
    if ([self.animationDelegate respondsToSelector:@selector(scrollViewDidBeginAnimating:)]) {
        [self.animationDelegate scrollViewDidBeginAnimating:self];
    }
    
    [UIView animateWithDuration:duration animations:^{
        
        for (UIImageView *imageView in self.imageViews) {
            
            if (self.currentIndex == [self.imageViews indexOfObject:imageView]) {
                
                JCAffineTransformScale(imageView,scale);
                
            } else {
                
                switch (self.scrollDirection) {
                    case JCScrollViewScrollDirectionHorizontal:
                        
                        JCAffineTransformTranslate(imageView,(self.contentOffset.x - imageView.frame.origin.x) * 0.65,0);
                        
                        break;
                    case JCScrollViewScrollDirectionVertical:
                        
                        JCAffineTransformTranslate(imageView,0,(self.contentOffset.y - imageView.frame.origin.y) * 0.65);
                        
                        break;
                    default:
                        break;
                }
            }
        }
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:duration animations:^{
            
            for (UIImageView *imageView in self.imageViews) {
                
                if (self.currentIndex == [self.imageViews indexOfObject:imageView]) {
                    
                    continue;
                    
                } else {
                    
                    /**
                     *  适配IOS8, IOS8中调用UIView动画连续调用两个不同的transform会有卡顿
                     */
                    JCAffineTransformScale(imageView,scale);
                }
            }
            
            //第三步，乾坤大挪移
        } completion:^(BOOL finished) {
            //如果方向没有改变，恢复，退出
            if (self.scrollDirection == direction) {
                
                [UIView animateWithDuration:duration animations:^{
                    for (UIImageView *imageView in self.imageViews) {
                        
                        JCAffineTransformScale(imageView, 1/scale);
                        
                        switch (self.scrollDirection) {
                            case JCScrollViewScrollDirectionHorizontal:
                            {
                                NSInteger currentPage = (imageView.frame.origin.x-self.bounds.size.width*self.pageControl.currentPage) / (self.bounds.size.width*scale);
                                currentPage += self.pageControl.currentPage;
                                imageView.frame = (CGRect){{currentPage * self.bounds.size.width,imageView.frame.origin.y},imageView.bounds.size};
                                break;
                            }
                            case JCScrollViewScrollDirectionVertical:
                            {
                                NSInteger currentPage = (imageView.frame.origin.y-self.bounds.size.height*self.pageControl.currentPage) / (self.bounds.size.height*scale);
                                currentPage += self.pageControl.currentPage;
                                imageView.frame = (CGRect){{imageView.frame.origin.x,currentPage * self.bounds.size.height},imageView.bounds.size};
                                
                                break;
                            }
                            default:
                                break;
                        }
                        
                    }
                }completion:^(BOOL finished) {
                    self.animating = NO;
                    if ([self.animationDelegate respondsToSelector:@selector(scrollViewDidEndAnimating:)]) {
                        [self.animationDelegate scrollViewDidEndAnimating:self];
                    }
                }];
                
                return;
            }
            
            //能来到这里说明方向不同
            _scrollDirection = direction;
            
            [UIView animateWithDuration:duration animations:^{
                
                CGFloat paddingV = 6.5;
                CGFloat paddingH = 11.5;
                CGFloat padding = 0;
                NSInteger flag = 0;
                for (UIImageView *imageView in self.imageViews) {
                    //当前显示的这张不变
                    if (self.currentIndex == [self.imageViews indexOfObject:imageView]) {
                        
                        continue;
                        
                    } else {
                        //要切换成哪个方向
                        switch (direction) {
                            case JCScrollViewScrollDirectionHorizontal:
                            {
                                
                                flag = imageView.frame.origin.y > self.contentOffset.y ? 1 : -1;
                                
                                padding = paddingH;
                                
                                break;
                            }
                            case JCScrollViewScrollDirectionVertical:
                            {
                                
                                flag = imageView.frame.origin.x > self.contentOffset.x ? -1 : 1;
                                
                                padding = paddingV;
                                
                                break;
                            }
                                
                            default:
                                break;
                        }
                        
                        JCAffineTransformTranslate(imageView,(imageView.bounds.size.width + padding)*flag,(-imageView.bounds.size.height - padding)*flag);
                        
                    }
                    
                }
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:duration animations:^{
                    for (UIImageView *imageView in self.imageViews) {
                        
                        JCAffineTransformScale(imageView, 1/scale);
                        
                        switch (self.scrollDirection) {
                            case JCScrollViewScrollDirectionHorizontal:
                            {
                                NSInteger currentPage = imageView.frame.origin.x / (self.bounds.size.width*scale);
                                imageView.frame = (CGRect){{currentPage * self.bounds.size.width,imageView.frame.origin.y},imageView.bounds.size};
                                break;
                            }
                            case JCScrollViewScrollDirectionVertical:
                            {
                                NSInteger currentPage = imageView.frame.origin.y / (self.bounds.size.height*scale);
                                imageView.frame = (CGRect){{imageView.frame.origin.x,currentPage * self.bounds.size.height},imageView.bounds.size};
                                break;
                            }
                            default:
                                break;
                        }
                        
                    }
                } completion:^(BOOL finished) {
                    
                    for (UIImageView *imageView in self.imageViews) {
                        
                        switch (self.scrollDirection) {
                            case JCScrollViewScrollDirectionHorizontal:
                            {
                                NSInteger currentPage = imageView.frame.origin.x / self.bounds.size.width;
                                currentPage += self.pageControl.currentPage;
                                imageView.frame = (CGRect){{0,currentPage * self.bounds.size.height},imageView.bounds.size};
                                break;
                            }
                            case JCScrollViewScrollDirectionVertical:
                            {
                                NSInteger currentPage = imageView.frame.origin.y / self.bounds.size.height;
                                currentPage += self.pageControl.currentPage;
                                imageView.frame = (CGRect){{currentPage * self.bounds.size.width,0},imageView.bounds.size};
                                break;
                            }
                            default:
                                break;
                        }
                        
                        
                    }
                    
                    [self convertImageViewsBetweenHorizontalAndVertical];
                    
                    self.animating = NO;
                    
                    if ([self.animationDelegate respondsToSelector:@selector(scrollViewDidEndAnimating:)]) {
                        [self.animationDelegate scrollViewDidEndAnimating:self];
                    }
                }];
                
            }];
            
        }];
        
    }];
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.currentIndex = 1;
    self.bounces = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.imageNames = [NSMutableArray array];
    self.animationDuration = 1;
    self.pageControlEnabled = YES;
//    _scrollDirection = JCScrollViewScrollDirectionVertical;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self imageViews];
    CGFloat pageControlW = self.bounds.size.width;
    CGFloat pageControlH = self.bounds.size.height * 0.1;
    CGFloat pageControlX = self.frame.origin.x;
    CGFloat pageControlY = self.bounds.size.height - pageControlH * 1.5;
    self.pageControl.frame = CGRectMake(pageControlX, pageControlY, pageControlW, pageControlH);
    
    if (self.pageControlEnabled)
        [self.superview addSubview:self.pageControl];
}

//direction Next -1 Previous 1
- (void)moveImageViewWithDirection:(JCScrollViewMoveDirection)direction{
    
    NSInteger preIndex = self.currentIndex + direction;
    if (preIndex == 3)
        preIndex = 0;
    else if (preIndex == -1)
        preIndex = 2;
    
    NSInteger offset = _pageControl.currentPage - direction;
    
    self.currentIndex-=direction;
    
    //把前一张或后一张移动
    [self setImageWithImageIndex:preIndex andImageNameIndex:offset];
}

- (void)setImageWithImageIndex:(NSInteger)imageIndex andImageNameIndex:(NSInteger)nameIndex {
    if (self.imageNames.count < 3) {
        return;
    }
    UIImageView *imageView = self.imageViews[imageIndex];
    CGRect imageRect = imageView.frame;
    
    switch (_scrollDirection) {
        case JCScrollViewScrollDirectionHorizontal:
            
            imageRect.origin.x = (nameIndex) * self.bounds.size.width;
            
            break;
        case JCScrollViewScrollDirectionVertical:
            
            imageRect.origin.y = (nameIndex) * self.bounds.size.height;
            
            break;
            
        default:
            break;
    }
    
    imageView.frame = imageRect;
    
    if (nameIndex < self.imageNames.count && nameIndex >= 0) {
        imageView.image = [UIImage imageNamed:self.imageNames[nameIndex]];
    }
    
}

@end
