//
//  APIConnection.h
//  LionsRoar
//
//  Created by Matt Dahl on 3/16/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Article;

typedef enum {
    denebolaArticleRequestType,
    lionsRoarArticleRequestType,
    lionsRoarArticleIDRequestType,
    denebolaArticleIDRequestType,
    denebolaTopNewsArticleIDRequestType,
    teacherAbsenceArticleRequestType
} requestType;

@interface APIConnection : NSObject <NSURLConnectionDataDelegate> {
    __strong NSURLConnection *connection;
    __strong NSMutableData *incomingData;
    BOOL isBusy;
    requestType requestType;
}

// idea: keep one big list of articles on disk. each "section" of app has a list of the hashes for the articles it needs. upon loading each "section", query the local list of articles to return the data as prescribed by the hashes

// better idea: the section-specific IDs are stored in the Article Store, NOT in the individual view controllers. When a view controller wants to display section-specific articles, it simply queries the Article Store for the info

// use volume (lion's roar) as a proxy for date

- (NSURLConnection *)getLionsRoarArticleIDsWithDateRangeFrom:(NSDate *)firstDate to:(NSDate *)secondDate; // WORKING
- (NSURLConnection *)getDenebolaArticleIDsWithDateRangeFrom:(NSDate *)firstDate to:(NSDate *)secondDate; // WORKING
- (NSURLConnection *)getLionsRoarArticlesWithIDs:(NSArray *)IDs; // WORKING
- (NSURLConnection *)getDenebolaArticlesWithIDs:(NSArray *)IDs; // WORKING
- (NSURLConnection *)getLionsRoarArticleWithID:(NSString *)ID; // WORKING
- (NSURLConnection *)getDenebolaArticleWithID:(NSString *)ID; // WORKING
- (NSURLConnection *)getDenebolaArticleIDsForFeaturedArticles; // WORKING
- (NSURLConnection *)getTeacherAbsenceArticle; // WORKING

- (NSDictionary *)parseJSONDataIntoArticles:(NSData *)data;
- (NSArray *)parseJSONDataIntoArticleIDs:(NSData *)data;
- (NSDictionary *)parseJSONDataIntoSectionArticleIDs:(NSData *)data;
- (NSArray *)parseJSONDataIntoTopNewsArticleIDs:(NSData *)data;
- (Article *)parseJSONDataIntoTeacherArticle:(NSData *)data;

- (BOOL)isBusy;
+ (BOOL)isConnectedToInternet;

@end
