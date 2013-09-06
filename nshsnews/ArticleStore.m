//
//  ArticleStore.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/16/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "ArticleStore.h"
#import "Article.h"
#import "APIConnection.h"

@implementation ArticleStore

static NSMutableDictionary *articles;
static NSMutableArray *lionsRoarArticleIDs; // Lion's Roar ids
static NSMutableArray *denebolaArticleIDs; // Denebola ids

static NSMutableArray *newsSectionIDs, *featuresSectionIDs, *sportsSectionIDs, *communitySectionIDs, *centerfoldSectionIDs, *opinionsSectionIDs;
static NSArray *topNewsSectionIDs;
static Article *teacherAbsenceArticle;

static NSDate *lastUpdateDate;
static NSMutableArray *APIConnections;
static BOOL isFinishedLoadingDenebolaArticles;
static BOOL isFinishedLoadingLionsRoarArticles;
static BOOL isFinishedLoadingTopNewsArticleIDs;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        lastUpdateDate = [aDecoder decodeObjectForKey:@"lastUpdateDate"];
        articles = [aDecoder decodeObjectForKey:@"articles"];
        lionsRoarArticleIDs = [aDecoder decodeObjectForKey:@"lionsRoarArticleIDs"];
        denebolaArticleIDs = [aDecoder decodeObjectForKey:@"denebolaArticleIDs"];
        topNewsSectionIDs = [aDecoder decodeObjectForKey:@"topNewsSectionIDs"];
        newsSectionIDs = [aDecoder decodeObjectForKey:@"newsSectionIDs"];
        featuresSectionIDs = [aDecoder decodeObjectForKey:@"featuresSectionIDs"];
        sportsSectionIDs = [aDecoder decodeObjectForKey:@"sportsSectionIDs"];
        communitySectionIDs = [aDecoder decodeObjectForKey:@"communitySectionIDs"];
        centerfoldSectionIDs = [aDecoder decodeObjectForKey:@"centerfoldSectionIDs"];
        opinionsSectionIDs = [aDecoder decodeObjectForKey:@"opinionsSectionIDs"];
        lastUpdateDate = [aDecoder decodeObjectForKey:@"lastUpdateDate"];
        teacherAbsenceArticle = [aDecoder decodeObjectForKey:@"teacherAbsenceArticle"];
        
        if (!articles)
            articles = [[NSMutableDictionary alloc] init];
        if (!lionsRoarArticleIDs)
            lionsRoarArticleIDs = [[NSMutableArray alloc] init];
        if (!denebolaArticleIDs)
            denebolaArticleIDs = [[NSMutableArray alloc] init];
        if (!newsSectionIDs)
            newsSectionIDs = [[NSMutableArray alloc] init];
        if (!featuresSectionIDs)
            featuresSectionIDs = [[NSMutableArray alloc] init];
        if (!sportsSectionIDs)
            sportsSectionIDs = [[NSMutableArray alloc] init];
        if (!communitySectionIDs)
            communitySectionIDs = [[NSMutableArray alloc] init];
        if (!centerfoldSectionIDs)
            centerfoldSectionIDs = [[NSMutableArray alloc] init];
        if (!opinionsSectionIDs)
            opinionsSectionIDs = [[NSMutableArray alloc] init];
        if (!lastUpdateDate)
            lastUpdateDate = [NSDate date];
    }
    return self;
}

+ (void)initialize {
    isFinishedLoadingDenebolaArticles = NO;
    isFinishedLoadingLionsRoarArticles = NO;
    isFinishedLoadingTopNewsArticleIDs = NO;
    articles = [[NSMutableDictionary alloc] init];
    APIConnections = [[NSMutableArray alloc] initWithObjects:[[APIConnection alloc] init], nil];
    
    lionsRoarArticleIDs = [[NSMutableArray alloc] init];
    denebolaArticleIDs = [[NSMutableArray alloc] init];
    newsSectionIDs = [[NSMutableArray alloc] init];
    featuresSectionIDs = [[NSMutableArray alloc] init];
    sportsSectionIDs = [[NSMutableArray alloc] init];
    communitySectionIDs = [[NSMutableArray alloc] init];
    centerfoldSectionIDs = [[NSMutableArray alloc] init];
    opinionsSectionIDs = [[NSMutableArray alloc] init];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunched"]) { // loads a lot of articles at first launch
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        lastUpdateDate = [dateFormatter dateFromString:@"2013-01-08"];
        [self startup];
    }
}

+ (void)startup {
    if (![APIConnection isConnectedToInternet]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                     message:@"You can try loading new articles later."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    
    if (!lastUpdateDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        lastUpdateDate = [dateFormatter dateFromString:@"2013-01-08"];
    }
    
    [[self getAPIConnection] getDenebolaArticleIDsForFeaturedArticles];
    [[self getAPIConnection] getLionsRoarArticleIDsWithDateRangeFrom:lastUpdateDate to:[NSDate date]];
    [[self getAPIConnection] getDenebolaArticleIDsWithDateRangeFrom:lastUpdateDate to:[NSDate date]];
    [[self getAPIConnection] getTeacherAbsenceArticle];
    
   /* dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        [[self getAPIConnection] getDenebolaArticleIDsForFeaturedArticles];
        CFRunLoopRun();
    });
    dispatch_async(queue, ^{
        [[self getAPIConnection] getLionsRoarArticleIDsWithDateRangeFrom:lastUpdateDate to:[NSDate date]];
        CFRunLoopRun();
    });
    dispatch_async(queue, ^{
        [[self getAPIConnection] getDenebolaArticleIDsWithDateRangeFrom:lastUpdateDate to:[NSDate date]];
        CFRunLoopRun();
    });
*/
    
    lastUpdateDate = [NSDate date];
}

+ (NSDate *)lastUpdateDate {
    return lastUpdateDate;
}

+ (void)releaseAPIConnection:(APIConnection *)conn {
    if ([APIConnections count] > 1 && ![conn isBusy]) {
        [APIConnections removeObject:conn];
        conn = nil;
    }
}

+ (void)APIConnection:(APIConnection *)conn didFinishLoadingWithRequestType:(requestType)req withData:(NSObject *)data {
    if (req == lionsRoarArticleIDRequestType) { // expect NSArray with data [articleIDs, sectionArticleIDs]
        [lionsRoarArticleIDs addObjectsFromArray:[(NSArray *)data objectAtIndex:0]];
        [newsSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"News"]];
        [featuresSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Features"]];
        [sportsSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Sports"]];
        [communitySectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Community"]];
        [centerfoldSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Centerfold"]];
        [opinionsSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Opinions"]];
    }
    else if (req == denebolaArticleIDRequestType) { // expect NSArray with data [articleIDs, sectionArticleIDs]
        [denebolaArticleIDs addObjectsFromArray:[(NSArray *)data objectAtIndex:0]];
        [newsSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"News"]];
        [featuresSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Features"]];
        [sportsSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Sports"]];
        [communitySectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Community"]];
        [centerfoldSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Centerfold"]];
        [opinionsSectionIDs addObjectsFromArray:(NSArray *)[(NSDictionary *)[(NSArray *)data objectAtIndex:1] objectForKey:@"Opinions"]];
    }
    else if (req == lionsRoarArticleRequestType) { // expect NSDictionary with articles as objects and IDs as keys
        [articles addEntriesFromDictionary:(NSDictionary *)data];
        [self releaseAPIConnection:conn];
        isFinishedLoadingLionsRoarArticles = YES;
    }
    else if (req == denebolaArticleRequestType) { // expect NSDictionary with articles as objects and IDs as keys
        [articles addEntriesFromDictionary:(NSDictionary *)data];
        [self releaseAPIConnection:conn];
        isFinishedLoadingDenebolaArticles = YES;
    }
    else if (req == denebolaTopNewsArticleIDRequestType) { // expect NSArray with data as array of IDs
        topNewsSectionIDs = (NSArray *)data;
        [self releaseAPIConnection:conn];
        isFinishedLoadingTopNewsArticleIDs = YES;
    }
    else if (req == teacherAbsenceArticleRequestType) { // expect Article
        teacherAbsenceArticle = (Article *)data;
        [self releaseAPIConnection:conn];
    }
}

+ (NSArray *)getArticlesForSection:(NSString *)section {
    if ([section isEqualToString:@"All News"]) {
        NSMutableArray *IDs = [NSMutableArray arrayWithArray:lionsRoarArticleIDs];
        [IDs addObjectsFromArray:denebolaArticleIDs];
        return [self getArticlesWithIDs:IDs];
    }
    if ([section isEqualToString:@"Top News"])
        return [self getArticlesWithIDs:topNewsSectionIDs];
    else if ([section isEqualToString:@"News"])
        return [self getArticlesWithIDs:newsSectionIDs];
    else if ([section isEqualToString:@"Features"])
        return [self getArticlesWithIDs:featuresSectionIDs];
    else if ([section isEqualToString:@"Sports"])
        return [self getArticlesWithIDs:sportsSectionIDs];
    else if ([section isEqualToString:@"Community"])
        return [self getArticlesWithIDs:communitySectionIDs];
    else if ([section isEqualToString:@"Centerfold"])
        return [self getArticlesWithIDs:centerfoldSectionIDs];
    else if ([section isEqualToString:@"Opinions"])
        return [self getArticlesWithIDs:opinionsSectionIDs];
    else
        return nil;
}

+ (BOOL)hasArticlesForSection:(NSString *)section {
    if ([section isEqualToString:@"All News"])
        return [lionsRoarArticleIDs count] + [denebolaArticleIDs count]; // 0 is NO, anything else is YES
    else if ([section isEqualToString:@"Top News"])
        return [topNewsSectionIDs count];
    else if ([section isEqualToString:@"News"])
        return [newsSectionIDs count];
    else if ([section isEqualToString:@"Features"])
        return [featuresSectionIDs count];
    else if ([section isEqualToString:@"Sports"])
        return [sportsSectionIDs count];
    else if ([section isEqualToString:@"Community"])
        return [communitySectionIDs count];
    else if ([section isEqualToString:@"Centerfold"])
        return [centerfoldSectionIDs count];
    else if ([section isEqualToString:@"Opinions"])
        return [opinionsSectionIDs count];
    else
        return NO;
}

+ (BOOL)doTask:(bool (^)(void))taskBlock { // executes the given block
    NSLog(@"%d", taskBlock());
   /* BOOL a = isFinishedLoadingTopNewsArticleIDs;
    BOOL b = isFinishedLoadingLionsRoarArticles;
    BOOL c = isFinishedLoadingDenebolaArticles; */
    return taskBlock();
}

+ (bool (^)(void))isFinishedLoadingArticlesBlock {
    return ^bool(void) {
        return (isFinishedLoadingLionsRoarArticles && isFinishedLoadingDenebolaArticles);
    };
}

+ (NSArray *)getArticlesWithIDs:(NSArray *)IDs {
    NSMutableArray *articlesWithIDs = [[NSMutableArray alloc] initWithArray:[articles objectsForKeys:IDs notFoundMarker:@"Not Found"]];
    [articlesWithIDs removeObject:@"Not Found"];
    [articlesWithIDs sortUsingSelector:@selector(compare:)];
    return articlesWithIDs;
}

+ (Article *)teacherAbsenceArticle {
    return teacherAbsenceArticle;
}

+ (APIConnection *)getAPIConnection {
    for (int i = 0; i < [APIConnections count]; i++) {
        if (![(APIConnection *)[APIConnections objectAtIndex:i] isBusy])
            return [APIConnections objectAtIndex:i];
        else if (i == [APIConnections count]-1) {
            APIConnection *con = [[APIConnection alloc] init];
            [APIConnections addObject:con];
            return con;
        }
    }
    return nil;
}

+ (void)updateArticles {
    if ([APIConnection isConnectedToInternet]) {
        [[self getAPIConnection] getLionsRoarArticleIDsWithDateRangeFrom:lastUpdateDate to:[NSDate date]];
        [[self getAPIConnection] getDenebolaArticleIDsWithDateRangeFrom:lastUpdateDate to:[NSDate date]];
        [[self getAPIConnection] getDenebolaArticleIDsForFeaturedArticles];
        [[self getAPIConnection] getTeacherAbsenceArticle];
        lastUpdateDate = [NSDate date]; // resets lastUpdateDate to now
    }
    else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                     message:@"Try updating again later."
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }
        
}

+ (NSArray *)searchArticleStoreWithSearchType:(searchType)searchType filterType:(filterType)filterType criterion:(NSString *)criterion {
    NSMutableArray *foundArray = [NSMutableArray array];
    Article *a;
    
    switch (searchType) {
        case titleSearchType: {
            for (NSNumber *key in articles) {
                a = (Article *)[articles objectForKey:key];
                switch (filterType) {
                    case lionsRoarFilterType:
                        if ([a.title rangeOfString:criterion options:NSCaseInsensitiveSearch].length && a.newspaperType == lionsRoarNewspaperType)
                            [foundArray addObject:a];
                        break;
                    case denebolaFilterType:
                        if ([a.title rangeOfString:criterion options:NSCaseInsensitiveSearch].length && a.newspaperType == denebolaFilterType)
                            [foundArray addObject:a];
                        break;
                    case allFilterType:
                        if ([a.title rangeOfString:criterion options:NSCaseInsensitiveSearch].length)
                            [foundArray addObject:a];
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        case authorSearchType: {
            for (NSNumber *key in articles) {
                a = (Article *)[articles objectForKey:key];
                switch (filterType) {
                    case lionsRoarFilterType:
                        if ([a.author rangeOfString:criterion options:NSCaseInsensitiveSearch].length && a.newspaperType ==lionsRoarNewspaperType)
                            [foundArray addObject:a];
                        break;
                    case denebolaFilterType:
                        if ([a.author rangeOfString:criterion options:NSCaseInsensitiveSearch].length && a.newspaperType == denebolaFilterType)
                        [foundArray addObject:a];
                        break;
                    case allFilterType:
                        if ([a.author rangeOfString:criterion options:NSCaseInsensitiveSearch].length)
                        [foundArray addObject:a];
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        case dateSearchType:
            break;
        case bodySearchType: {
            for (NSNumber *key in articles) {
                a = (Article *)[articles objectForKey:key];
                switch (filterType) {
                    case lionsRoarFilterType:
                        if ([a.body rangeOfString:criterion options:NSCaseInsensitiveSearch].length && a.newspaperType == lionsRoarNewspaperType)
                        [foundArray addObject:a];
                        break;
                    case denebolaFilterType:
                        if ([a.body rangeOfString:criterion options:NSCaseInsensitiveSearch].length && a.newspaperType == denebolaFilterType)
                        [foundArray addObject:a];
                        break;
                    case allFilterType:
                        if ([a.body rangeOfString:criterion options:NSCaseInsensitiveSearch].length)
                        [foundArray addObject:a];
                        break;
                    default:
                        break;
                }
            }
            break;
        }
        default:
            break;
    }
    
    if ([foundArray count] > 0)
        [foundArray sortUsingSelector:@selector(compare:)];
    
    return foundArray;
}

#pragma mark - Encode method

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:articles forKey:@"articles"];
    [aCoder encodeObject:lionsRoarArticleIDs forKey:@"lionsRoarArticleIDs"];
    [aCoder encodeObject:denebolaArticleIDs forKey:@"denebolaArticleIDs"];
    [aCoder encodeObject:topNewsSectionIDs forKey:@"topNewsSectionIDs"];
    [aCoder encodeObject:newsSectionIDs forKey:@"newsSectionIDs"];
    [aCoder encodeObject:featuresSectionIDs forKey:@"featuresSectionIDs"];
    [aCoder encodeObject:sportsSectionIDs forKey:@"sportsSectionIDs"];
    [aCoder encodeObject:communitySectionIDs forKey:@"communitySectionIDs"];
    [aCoder encodeObject:centerfoldSectionIDs forKey:@"centerfoldSectionIDs"];
    [aCoder encodeObject:opinionsSectionIDs forKey:@"opinionsSectionIDs"];
    [aCoder encodeObject:lastUpdateDate forKey:@"lastUpdateDate"];
    [aCoder encodeObject:teacherAbsenceArticle forKey:@"teacherAbsenceArticle"];
}
/*
+ (void)saveArticleStoreData {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    [NSKeyedArchiver archiveRootObject:articles toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.articles"]];
    [NSKeyedArchiver archiveRootObject:lionsRoarArticleIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.lionsRoarArticleIDs"]];
    [NSKeyedArchiver archiveRootObject:denebolaArticleIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.denebolaArticleIDs"]];
    [NSKeyedArchiver archiveRootObject:newsSectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.newsSectionIDs"]];
    [NSKeyedArchiver archiveRootObject:featuresSectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.featuresSectionIDs"]];
    [NSKeyedArchiver archiveRootObject:sportsSectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.sportsSectionIDs"]];
    [NSKeyedArchiver archiveRootObject:communitySectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.communitySectionIDs"]];
    [NSKeyedArchiver archiveRootObject:centerfoldSectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.centerfoldSectionIDs"]];
    [NSKeyedArchiver archiveRootObject:opinionsSectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.opinionsSectionIDs"]];
    [NSKeyedArchiver archiveRootObject:topNewsSectionIDs toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.topNewsSectionIDs"]];
    [NSKeyedArchiver archiveRootObject:lastUpdateDate toFile:[documentDirectory stringByAppendingString:@"articleStore.archive.lastUpdateDate"]];
}
*/
@end
