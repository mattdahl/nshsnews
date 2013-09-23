//
//  ArticleCell.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "AppDelegate.h"
#import "ArticleCell.h"
#import "Article.h"
#import <QuartzCore/QuartzCore.h>

@implementation ArticleCell

@synthesize article, articleTitle, articleDate, thumbnailImageView;

// this method is probably never called
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withArticle:(Article *)anArticle {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        article = anArticle;
        [article setDelegate:self];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *formattedDate = [formatter stringFromDate:[NSDate date]];
        [articleDate setText:formattedDate];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)drawRect:(CGRect)rect {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *formattedDate = [formatter stringFromDate:article.date];
    [articleDate setText:formattedDate];
    
    [articleTitle setText:article.title];
    
    [articleDate setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
    [articleDate setTextColor:[UIColor colorWithRed:209.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0]];
    
    
   // [theTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
   // [theTitle setTextColor:[UIColor colorWithRed:209.0/255.0 green:46.0/255.0 blue:46.0/255.0 alpha:1.0]];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    
    CGSize maximumBodySize = CGSizeMake(220, 50);
   /* CGSize titleSize = [articleTitle sizeWithFont:font
                              constrainedToSize:maximumBodySize
                                  lineBreakMode:NSLineBreakByTruncatingTail];
    CGRect titleRect = CGRectMake(82, 8, titleSize.width, titleSize.height);
    
    // drawInRect:withFont:lineBreakMode: is deprecated in iOS 7 so use a different function if the device is running it
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        [ps setLineBreakMode:NSLineBreakByWordWrapping];
       /* [articleTitle drawInRect:titleRect
                  withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, ps, NSParagraphStyleAttributeName, NSForegroundColorAttributeName, [UIColor blackColor], nil]];
        [@"blah blah" drawAtPoint:CGPointMake(0, 0) withFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
    }
    else {
        [articleTitle drawInRect:titleRect
                        withFont:font
                   lineBreakMode:NSLineBreakByWordWrapping];
    } */
    
    if (article.thumbnail) {
        [thumbnailImageView setImage:article.thumbnail];
        [thumbnailImageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [thumbnailImageView.layer setBorderWidth:1.0];
        [thumbnailImageView setNeedsDisplay];
    }
    else if (!thumbnailImageView.image)
        [article loadThumbnail];
}

#pragma mark - ArticleImageLoaderDelegate methods

- (void)articleImageRequest:(articleImageRequestType)requestType didLoad:(Article *)anArticle {
    if (requestType == thumbnailRequestType) {
        [thumbnailImageView setImage:anArticle.thumbnail];
        [thumbnailImageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
        [thumbnailImageView.layer setBorderWidth:1.0];
        [thumbnailImageView setNeedsDisplay];
    }
}

- (void)articleImageRequest:(articleImageRequestType)requestType didHaveErrorLoading:(Article *)anArticle error:(NSString *)e {
    if (anArticle.newspaperType == denebolaNewspaperType) {
        [thumbnailImageView setImage:[UIImage imageNamed:@"DenebolaThumbnail"]];
        [anArticle setThumbnail:[UIImage imageNamed:@"DenebolaThumbnail"]];
    }
    else if (anArticle.newspaperType == lionsRoarNewspaperType) {
        [thumbnailImageView setImage:[UIImage imageNamed:@"LionsRoarThumbnail"]];
        [anArticle setThumbnail:[UIImage imageNamed:@"LionsRoarThumbnail"]];
    }
    [anArticle setImage:[UIImage imageNamed:@"NoImage"]];

    [thumbnailImageView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [thumbnailImageView.layer setBorderWidth:1.0];
    [thumbnailImageView setNeedsDisplay];
}

- (int)widthForResize {
    if ([AppDelegate isRetina])
        return 2*67;
    else
        return 67;
}

- (int)heightForResize {
    if ([AppDelegate isRetina])
        return 2*67;
    else
        return 67;
}

@end
