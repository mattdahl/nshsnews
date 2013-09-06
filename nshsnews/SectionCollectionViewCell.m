//
//  SectionCollectionViewCell.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "SectionCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SectionCollectionViewCell

@synthesize sectionTitle, article, backgroundImageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:backgroundImageView];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:20];

        sectionTitle = [[UILabel alloc] init];
        [sectionTitle setFrame:CGRectMake(8, 8, self.frame.size.width-8, 22)];
        [sectionTitle setFont:font];
        [sectionTitle setBackgroundColor:[UIColor clearColor]];
        [sectionTitle setTextColor:[UIColor whiteColor]];
        [self addSubview:sectionTitle];
        
        topDrawingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
        [topDrawingView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.6]];
        [self addSubview:topDrawingView];
        
        [self bringSubviewToFront:topDrawingView];
        [self bringSubviewToFront:sectionTitle];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draws border
    CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 1.0);
    CGPoint points[] = {CGPointMake(0, 0), CGPointMake(self.frame.size.width, 0), CGPointMake(self.frame.size.width, self.frame.size.height), CGPointMake(0, self.frame.size.height), CGPointMake(0, 0)};
    CGContextAddLines(ctx, points, 5);
    CGContextStrokePath(ctx);
    
    if (article.sectionThumbnail) {
        [backgroundImageView setImage:article.sectionThumbnail];
        [backgroundImageView setNeedsDisplay];
    }
    else if (!backgroundImageView.image)
        [article loadSectionThumbnail];
}

#pragma mark - ArticleImageLoaderDelegate methods

- (void)articleImageRequest:(articleImageRequestType)requestType didLoad:(Article *)anArticle {
    if (requestType == sectionThumbnailRequestType) {
        [backgroundImageView setImage:anArticle.sectionThumbnail];
        [backgroundImageView setNeedsDisplay];
    }
}

- (void)articleImageRequest:(articleImageRequestType)requestType didHaveErrorLoading:(Article *)anArticle error:(NSString *)e {
    if (anArticle.newspaperType == denebolaNewspaperType)
        [backgroundImageView setImage:[UIImage imageNamed:@"DenebolaThumbnail"]];
    else if (anArticle.newspaperType == lionsRoarNewspaperType) {
        [backgroundImageView setImage:[UIImage imageNamed:@"LionsRoarSectionThumbnail"]];
        [anArticle setSectionThumbnail:[UIImage imageNamed:@"LionsRoarSectionThumbnail"]];
    }
    [backgroundImageView setNeedsDisplay];
}

- (int)widthForResize {
    return self.frame.size.width;
}

- (int)heightForResize {
    return self.frame.size.height;
}

@end
