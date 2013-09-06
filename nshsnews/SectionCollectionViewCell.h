//
//  SectionCollectionViewCell.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/29/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface SectionCollectionViewCell : UICollectionViewCell <ArticleImageLoaderDelegate> {
    __strong UIView *topDrawingView;
}

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (strong, nonatomic) UILabel *sectionTitle;
@property (strong, nonatomic) Article *article;

@end
