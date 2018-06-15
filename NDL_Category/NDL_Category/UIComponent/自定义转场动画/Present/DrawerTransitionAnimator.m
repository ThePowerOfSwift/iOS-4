//
//  DrawerTransitionAnimator.m
//  NDL_Category
//
//  Created by dzcx on 2018/6/12.
//  Copyright © 2018年 ndl. All rights reserved.
//

#import "DrawerTransitionAnimator.h"
#import "DrawerPresentationController.h"

@implementation DrawerTransitionAnimator

#pragma mark - UIViewControllerTransitioningDelegate
/*
 该方法用于告诉系统谁来负责自定义转场
 第一个参数: 被展现的控制
 第二个参数: 发起的控制器
 */
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[DrawerPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

// 告诉系统谁来负责展现的样式
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.isPresentFlag = YES;
    
    return self;
}

// 告诉系统谁来负责消失的样式
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    NSLog(@"===animationControllerForDismissedController===");// dismiss 先执行这个
    self.isPresentFlag = NO;
    
    return self;
}

//- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
//{
//    
//}

// 手势dismiss
- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    if (animator) {
        return self.interactiveTransition;
    }
    
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning
// 该方法用于告诉系统展现或者消失动画的时长
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

/// 无论是展现还是消失都会调用这个方法
/// 注意点: 只要实现了这个方法, 那么系统就不会再管控制器如何弹出和消失了, 所有的操作都需要我们自己做
// transitionContext: 里面就包含了我们所有需要的参数
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresentFlag) {// present
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        NSLog(@"containerView subView = %@", transitionContext.containerView.subviews);
        [transitionContext.containerView addSubview:toView];
        
        NSLog(@"toVC:initialFrame = %@ finalFrame = %@ containerView = %@", NSStringFromCGRect([transitionContext initialFrameForViewController:toVC]), NSStringFromCGRect([transitionContext finalFrameForViewController:toVC]), transitionContext.containerView);// UITransitionView与UIPresentationController.containerView同一个
        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
        CGRect animationStartFrame = CGRectOffset(finalFrame, 0, finalFrame.size.height);
        toView.frame = animationStartFrame;
        
        // UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            toView.frame = finalFrame;// next向上
            
        } completion:^(BOOL finished) {
            if (finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }
        }];
    } else {// dismiss
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
//        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
//        [transitionContext.containerView addSubview:toView];
        
        CGRect animationStartFrame = fromView.frame;
        CGRect animationEndFrame = CGRectOffset(fromView.frame, 0, fromView.height + 10);// 10为额外的安全区域,保证看不到view,如果不写,一直向下移动的时候，会露出一点view
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            // next向下
            fromView.frame = animationEndFrame;
            
        } completion:^(BOOL finished) {
            if (finished) {
                NSLog(@"===dismiss completeTransition before wasCancelled = %ld isInteractive = %ld===", [[NSNumber numberWithBool:transitionContext.transitionWasCancelled] integerValue], [[NSNumber numberWithBool:transitionContext.isInteractive] integerValue]);
                
                if ([transitionContext transitionWasCancelled]) {// 被取消
                    [transitionContext completeTransition:NO];
                    fromView.frame = animationStartFrame;
                } else {
                    [transitionContext completeTransition:YES];
                }
//                [transitionContext completeTransition:![transitionContext transitionWasCancelled] || ![transitionContext isInteractive]];// 我觉得会调用dismissalTransitionDidEnd
                
                
                NSLog(@"===dismiss completeTransition after===");
            }
        }];
    }
}

@end
