//
//  LoadingViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 5/3/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewControllerDelegate;

@interface LoadingViewController : UIViewController {
    NSTimer *t;
}

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *actvityIndicatorView;
@property (nonatomic, strong) IBOutlet UILabel *loadingLabel;
@property (nonatomic, weak) NSObject <LoadingViewControllerDelegate> *delegate;
@property (nonatomic, strong) bool(^loadingTask)(void);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<LoadingViewControllerDelegate>)delegateOrNil task:(bool(^)(void))task;

@end

@protocol LoadingViewControllerDelegate <NSObject>

@required

@property (nonatomic, strong) LoadingViewController *loadingViewController;

- (BOOL)shouldLoadingViewControllerAnimate:(LoadingViewController *)loadingViewController;
- (void)loadingViewControllerDidStartLoading:(LoadingViewController *)loadingViewController;
- (void)loadingViewControllerDidFinishLoading:(LoadingViewController *)loadingViewController;

@end