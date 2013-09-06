//
//  TopStoryCell.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface TopArticleCell : UITableViewCell <ArticleImageLoaderDelegate> {
    __strong UIView *topDrawingView;
    __strong UIImageView *arrowView;
}

@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) UILabel *articleTitle;
@property (nonatomic, strong) UIImageView *bigThumbnailImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withArticle:(Article *)anArticle;

@end
