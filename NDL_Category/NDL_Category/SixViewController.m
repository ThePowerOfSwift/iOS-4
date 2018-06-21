//
//  SixViewController.m
//  NDL_Category
//
//  Created by dzcx on 2018/6/19.
//  Copyright © 2018年 ndl. All rights reserved.
//

#import "SixViewController.h"
#import "MagicMoveTransitionAnimator.h"

@interface SixViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UILabel *label;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;

@end

@implementation SixViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Six viewDidLoad");
    NSLog(@"Six self.view = %@", self.view);
    
    self.navigationController.delegate = self;
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
    iv.tag = kTransitionAnimationViewTag;
    iv.image = [UIImage imageNamed:@"avatar"];
//    iv.backgroundColor = [UIColor greenColor];
    [self.view addSubview:iv];
    iv.center = self.view.center;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(iv.frame) + 20, NDLScreenW - 40, 40)];
    label.backgroundColor = [UIColor yellowColor];
    label.text = @"我是头像";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.label = label;
    
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationTransition:)];
    edgePan.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePan];
    
    
    // 设置了viewController.navigationItem.leftBarButtonItem需要设置这个
//    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    
    // 全屏返回
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // 1.
//    id target = self.navigationController.interactivePopGestureRecognizer.delegate;// target = _UINavigationInteractiveTransition
//    // 2.handleNavigationTransition是私有类_UINavigationInteractiveTransition的方法，系统主要在这个方法里面实现动画的。
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
//    [pan addTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
//    // 3.设置代理
//    pan.delegate = self;
//    // 4.添加到导航控制器的视图上
//    [self.navigationController.view addGestureRecognizer:pan];
//    NSLog(@"Six viewDidLoad");
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    //只有导航的根控制器不需要右滑的返回的功能。
//    if (self.navigationController.viewControllers.count <= 1)
//    {
//        
//        return NO;
//    }
//    
//    return YES;
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    self.navigationController.delegate = self;
    NSLog(@"Six viewDidAppear frame = %@", NSStringFromCGRect(self.view.frame));
//    NSLog(@"Six left = %@ back = %@", self.navigationItem.leftBarButtonItem, self.navigationItem.backBarButtonItem);
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
////    UIView *labelView = [self.label snapshotViewAfterScreenUpdates:NO];
////    [self.view addSubview:labelView];
////    labelView.y = 100;
//
//
//    NSLog(@"six vc view = %@", labelView);
//}

#pragma mark - Gesture Callback
- (void)handleNavigationTransition:(UIScreenEdgePanGestureRecognizer *)gesture
{
//    NSLog(@"===handleNavigationTransition===");
    CGFloat progress = [gesture translationInView:self.view].x / (self.view.width * 2.0);
    progress = MIN(1.0, MAX(0.0, progress));// 把这个百分比限制在0~1之间
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"change progress = %lf", progress);
            [self.interactiveTransition updateInteractiveTransition:progress];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"progress = %lf", progress);
            if (progress > 0.1) {
                [self.interactiveTransition finishInteractiveTransition];
            } else {
                [self.interactiveTransition cancelInteractiveTransition];
            }
            self.interactiveTransition = nil;
        }
            break;
        default:
        {
            [self.interactiveTransition cancelInteractiveTransition];
            self.interactiveTransition = nil;
        }
            break;
    }
}

#pragma mark - UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        MagicMoveTransitionAnimator *animator = [[MagicMoveTransitionAnimator alloc] init];
        animator.transitionDuration = 0.5;
        animator.isPushFlag = NO;
        animator.animationTempView = self.animationSnapshotView;
        animator.animationOriginView = self.animationOriginView;
        NSLog(@"Six animator = %@", animator);
        return animator;
    }
    
    return nil;
}

// 返回转场交互对象
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if ([animationController isKindOfClass:[MagicMoveTransitionAnimator class]]) {
        return self.interactiveTransition;
    }
    
    return nil;
}

@end