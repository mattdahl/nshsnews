//
//  TopStoryCell.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "AppDelegate.h"
#import "TopArticleCell.h"
#import "Article.h"
#import <QuartzCore/QuartzCore.h>

@implementation TopArticleCell

@synthesize article, articleTitle, bigThumbnailImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withArticle:(Article *)anArticle {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        article = anArticle;
        [article setDelegate:self];
        topDrawingView = [[UIView alloc] initWithFrame:CGRectMake(0, 145, self.frame.size.width, 35)];
        [topDrawingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.6]];
        [self addSubview:topDrawingView];
        
        arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow2"]];
        [arrowView setFrame:CGRectMake(300, 154, 14, 20)];
        [self addSubview:arrowView];
        
        articleTitle = [[UILabel alloc] init];
        [articleTitle setText:article.title];
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        
        [articleTitle setFrame:CGRectMake(5, 150, 300, 30)];
        
        [articleTitle setFont:font];
        [articleTitle setBackgroundColor:[UIColor clearColor]];
        [articleTitle setTextColor:[UIColor whiteColor]];
        [self addSubview:articleTitle];
        
        bigThumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
        [self insertSubview:bigThumbnailImageView atIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [article setDelegate:self];
    topDrawingView = [[UIView alloc] initWithFrame:CGRectMake(0, 145, self.frame.size.width, 35)];
    [topDrawingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.6]];
    
    
    arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow2"]];
    [arrowView setFrame:CGRectMake(300, 150, 14, 20)];
    [self addSubview:arrowView];
    
    articleTitle = [[UILabel alloc] init];
    [articleTitle setText:article.title];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    
    [articleTitle setFrame:CGRectMake(5, 150, 320, 30)];
    
    [articleTitle setFont:font];
    [articleTitle setBackgroundColor:[UIColor clearColor]];
    [articleTitle setTextColor:[UIColor whiteColor]];
    [self addSubview:articleTitle];
    
    bigThumbnailImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    [self insertSubview:bigThumbnailImageView atIndex:0];
}

- (void)drawRect:(CGRect)rect {
    if (article.bigThumbnail) {
        [bigThumbnailImageView setImage:article.bigThumbnail];
        [bigThumbnailImageView setNeedsDisplay];
    }
    else if (!bigThumbnailImageView.image)
        [article loadBigThumbnail];
    
    [self bringSubviewToFront:topDrawingView];
    [self bringSubviewToFront:articleTitle];
    [self bringSubviewToFront:arrowView];
}

#pragma mark - ArticleImageLoaderDelegate methods

- (void)articleImageRequest:(articleImageRequestType)requestType didLoad:(Article *)anArticle {
    if (requestType == bigThumbnailRequestType) {
        [bigThumbnailImageView setImage:anArticle.bigThumbnail];
        [bigThumbnailImageView setNeedsDisplay];
    }
}

- (void)articleImageRequest:(articleImageRequestType)requestType didHaveErrorLoading:(Article *)article error:(NSString *)e {
    [bigThumbnailImageView setImage:[UIImage imageNamed:@"NoThumbnail"]];
    [bigThumbnailImageView setNeedsDisplay];
}

- (int)widthForResize {
    if ([AppDelegate isRetina])
        return 2*320;
    else
        return 320;
}

- (int)heightForResize {
    if ([AppDelegate isRetina])
        return 2*180;
    else
        return 180;
}

@end
