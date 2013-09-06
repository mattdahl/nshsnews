//
//  ArticleStore.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/16/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIConnection.h"

@class Article;

typedef enum {
    lionsRoarNewspaperType,
    denebolaNewspaperType
} newspaperType;

typedef enum {
    titleSearchType,
    authorSearchType,
    dateSearchType,
    bodySearchType
} searchType;

typedef enum {
    lionsRoarFilterType,
    denebolaFilterType,
    allFilterType,
} filterType;

@interface ArticleStore : NSObject <NSCoding, NSURLConnectionDataDelegate>

+ (void)startup;
+ (void)updateArticles;

+ (NSArray *)getArticlesForSection:(NSString *)section;
+ (Article *)teacherAbsenceArticle;
+ (NSDate *)lastUpdateDate;
+ (BOOL)hasArticlesForSection:(NSString *)section;
+ (NSArray *)searchArticleStoreWithSearchType:(searchType)searchType filterType:(filterType)filterType criterion:(NSString *)criterion;

// informal delegate protocol method
+ (void)APIConnection:(APIConnection *)conn didFinishLoadingWithRequestType:(requestType)req withData:(NSObject *)data;

+ (BOOL)doTask:(bool(^)(void))taskBlock;
+ (bool(^)(void))isFinishedLoadingArticlesBlock;

@end
