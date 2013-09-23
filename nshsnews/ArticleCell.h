//
//  ArticleCell.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface ArticleCell : UITableViewCell <ArticleImageLoaderDelegate>

@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) IBOutlet UILabel *articleDate;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *articleTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withArticle:(Article *)anArticle;

// idea: if a thumbnail doesn't load, display a stock image with a denebola or lion's roar logo on it

@end
