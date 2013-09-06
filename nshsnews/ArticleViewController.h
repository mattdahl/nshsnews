//
//  ArticleViewController.h
//  LionsRoar
//
//  Created by Matt Dahl on 2/25/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@class BodyView;

@interface ArticleViewController : UIViewController <UIScrollViewDelegate, ArticleImageLoaderDelegate> {
    IBOutlet UILabel *articleTitle;
    IBOutlet UILabel *articleDate;
    IBOutlet UILabel *articleAuthor;
    IBOutlet UITextView *bodyView;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *mastheadView;
    IBOutlet UIActivityIndicatorView *activityIndicatorView;
    CGPoint oldOffset;
}

@property (nonatomic, strong) Article *article;
@property (nonatomic) CGSize contentSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article *)a navBarTitle:(NSString *)t;

@end
