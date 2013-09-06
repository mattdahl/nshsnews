
//
//  APIConnection.m
//  LionsRoar
//
//  Created by Matt Dahl on 3/16/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "APIConnection.h"
#import "Article.h"
#import "ArticleStore.h"
#import "Reachability.h"

@implementation APIConnection

NSString *const apiKey = @"a91d1d4e9a741c311a52f8e0b0b04684";

- (id)init {
    self = [super init];
    if (self) {
        isBusy = YES;
    }
    return self;
}

- (BOOL)isBusy {
    return isBusy;
}

- (NSURLConnection *)getLionsRoarArticleWithID:(NSString *)ID {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thelionsroar.com/getArticleWithID.php?ID=%@&apiKey=%@", ID, apiKey]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = lionsRoarArticleRequestType;
    return connection;
}

- (NSURLConnection *)getDenebolaArticleWithID:(NSString *)ID {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.nshsdenebola.com/getArticleWithID.php?ID=%@&apiKey=%@", ID, apiKey]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = denebolaArticleRequestType;
    return connection;
}

- (NSURLConnection *)getLionsRoarArticlesWithIDs:(NSArray *)IDs {
    NSMutableString *POSTdata = [NSMutableString stringWithString:@"IDs=["];
    for (NSString *element in IDs)
        [POSTdata appendString:[NSString stringWithFormat:@"%d,", [element intValue]]];
    [POSTdata deleteCharactersInRange:NSMakeRange(POSTdata.length-1, 1)]; // removes last comma
    [POSTdata appendString:@"]"];
    
   // NSLog(@"%@", POSTdata);
        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thelionsroar.com/getArticlesWithIDs.php?apiKey=%@", apiKey]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[POSTdata dataUsingEncoding:NSUTF8StringEncoding]];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = lionsRoarArticleRequestType;
    return connection;
}

- (NSURLConnection *)getDenebolaArticlesWithIDs:(NSArray *)IDs {
    NSMutableString *POSTdata = [NSMutableString stringWithString:@"IDs=["];
    for (NSString *element in IDs)
        [POSTdata appendString:[NSString stringWithFormat:@"%d,", [element intValue]]];
    [POSTdata deleteCharactersInRange:NSMakeRange(POSTdata.length-1, 1)]; // removes last comma
    [POSTdata appendString:@"]"];
    
   // NSLog(@"%@", POSTdata);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.nshsdenebola.com/getArticlesWithIDs.php?apiKey=%@", apiKey]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[POSTdata dataUsingEncoding:NSUTF8StringEncoding]];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = denebolaArticleRequestType;
    return connection;
}

- (NSURLConnection *)getLionsRoarArticleIDsWithDateRangeFrom:(NSDate *)firstDate to:(NSDate *)secondDate {
    NSString *POSTdata = [NSString stringWithFormat:@"date1=%d&date2=%d", (int)[firstDate timeIntervalSince1970], (int)[secondDate timeIntervalSince1970]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.thelionsroar.com/getArticleIDsWithDateRange.php?apiKey=%@", apiKey]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[POSTdata dataUsingEncoding:NSUTF8StringEncoding]];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = lionsRoarArticleIDRequestType;
    return connection;
}

- (NSURLConnection *)getDenebolaArticleIDsWithDateRangeFrom:(NSDate *)firstDate to:(NSDate *)secondDate {
    NSString *POSTdata = [NSString stringWithFormat:@"date1=%d&date2=%d", (int)[firstDate timeIntervalSince1970], (int)[secondDate timeIntervalSince1970]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.nshsdenebola.com/getArticleIDsWithDateRange.php?apiKey=%@", apiKey]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[POSTdata dataUsingEncoding:NSUTF8StringEncoding]];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = denebolaArticleIDRequestType;
    return connection;
}

- (NSURLConnection *)getDenebolaArticleIDsForFeaturedArticles {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.nshsdenebola.com/getArticleIDsForFeaturedArticles.php?apiKey=%@", apiKey]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = denebolaTopNewsArticleIDRequestType;
    return connection;
}

- (NSURLConnection *)getTeacherAbsenceArticle {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.nshsdenebola.com/getTeacherAbsenceArticle.php?apiKey=%@", apiKey]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    self->requestType = teacherAbsenceArticleRequestType;
    return connection;
}

#pragma mark - Parse Methods

- (NSDictionary *)parseJSONDataIntoArticles:(NSData *)data {
    NSError *error = nil;
    NSArray *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    newspaperType nType;
    
    if (self->requestType == lionsRoarArticleRequestType) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        nType = lionsRoarNewspaperType;
    }
    else if (self->requestType == denebolaArticleRequestType) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        nType = denebolaNewspaperType;
    }

    NSMutableDictionary *articleDictionary = [[NSMutableDictionary alloc] init];
    NSArray *row, *innerRow;
    NSURL *url;
    Article *a;
    
    for (int i = 0; i < [parsedJSON count]; i++) {
        row = [parsedJSON objectAtIndex:i];
        
        if ([[row objectAtIndex:0] isEqualToString:@"article"]) {
            innerRow = [row objectAtIndex:1];
            if ([innerRow objectAtIndex:4] != [NSNull null])
                url = [NSURL URLWithString:[innerRow objectAtIndex:4]];
            else
                url = nil;
            a = [[Article alloc] initWithTitle:[innerRow objectAtIndex:0] // title
                                        author:[innerRow objectAtIndex:1] // author
                                          date:[dateFormatter dateFromString:[innerRow objectAtIndex:2]] // date
                                          body:[[innerRow objectAtIndex:3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] // body
                                      imageURL:url // image url
                                       section:[innerRow objectAtIndex:5] // section
                                 newspaperType:nType
                                            ID:[innerRow objectAtIndex:6]]; // id
            [articleDictionary setObject:a forKey:[innerRow objectAtIndex:6]];
        }
        else {
            NSLog(@"parseJSONIntoArticles... no article found for request type: %u at row %d... row 0: %@... row 1: %@", self->requestType, i, [row objectAtIndex:0], [row objectAtIndex:1]);
        }
     }    
    return articleDictionary;
}

- (NSDictionary *)parseJSONDataIntoSectionArticleIDs:(NSData *)data {
    NSError *error = nil;
    NSArray *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
    NSNumber *ID;
    NSString *section;
    NSMutableArray *newsSectionIDs = [[NSMutableArray alloc] init];
    NSMutableArray *featuresSectionIDs = [[NSMutableArray alloc] init];
    NSMutableArray *sportsSectionIDs = [[NSMutableArray alloc] init];
    NSMutableArray *communitySectionIDs = [[NSMutableArray alloc] init];
    NSMutableArray *centerfoldSectionIDs = [[NSMutableArray alloc] init];
    NSMutableArray *opinionsSectionIDs = [[NSMutableArray alloc] init];
    
    NSArray *row;
    
    for (int i = 0; i < [parsedJSON count]; i++) {
        row = [parsedJSON objectAtIndex:i];
        ID = [NSNumber numberWithInt:[[row objectAtIndex:0] intValue]];
        section = [row objectAtIndex:1];
        
        if ([section isEqualToString:@"News"])
            [newsSectionIDs addObject:ID];
        else if ([section isEqualToString:@"Features"])
            [featuresSectionIDs addObject:ID];
        else if ([section isEqualToString:@"Sports"])
            [sportsSectionIDs addObject:ID];
        else if ([section isEqualToString:@"Community"])
            [communitySectionIDs addObject:ID];
        else if ([section isEqualToString:@"Centerfold"])
            [centerfoldSectionIDs addObject:ID];
        else if ([section isEqualToString:@"Opinions"] || [section isEqualToString:@"Editorials"])
            [opinionsSectionIDs addObject:ID];
    }
        
    return [NSDictionary dictionaryWithObjectsAndKeys:newsSectionIDs, @"News", featuresSectionIDs, @"Features", sportsSectionIDs, @"Sports", communitySectionIDs, @"Community", centerfoldSectionIDs, @"Centerfold", opinionsSectionIDs, @"Opinions", nil];
}

- (NSArray *)parseJSONDataIntoArticleIDs:(NSData *)data {
    NSError *error = nil;
    NSArray *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
    NSMutableArray *masterIDs = [[NSMutableArray alloc] init];
    
    for (NSArray *row in parsedJSON)
        [masterIDs addObject:[NSNumber numberWithInt:[[row objectAtIndex:0] intValue]]];
    
    return masterIDs;
}

- (NSArray *)parseJSONDataIntoTopNewsArticleIDs:(NSData *)data {
    NSError *error = nil;
    NSArray *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
    NSMutableArray *masterIDs = [[NSMutableArray alloc] init];
    
    for (NSString *s in parsedJSON)
        [masterIDs addObject:[NSNumber numberWithInt:[s intValue]]];
    
    return masterIDs;
}

- (Article *)parseJSONDataIntoTeacherArticle:(NSData *)data {
    NSError *error = nil;
    NSArray *parsedJSON = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:&error];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSArray *innerRow = [[parsedJSON objectAtIndex:0] objectAtIndex:1];
    
    NSDate *date = [dateFormatter dateFromString:[innerRow objectAtIndex:2]];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    
    Article *a = [[Article alloc] initWithTitle:[NSString stringWithFormat:@"%@ For %@", [innerRow objectAtIndex:0], [dateFormatter stringFromDate:date]] // title
                                         author:@"Denebola" // author
                                           date:date // date
                                           body:[innerRow objectAtIndex:3] // body
                                       imageURL:nil
                                        section:nil // section
                                  newspaperType:denebolaNewspaperType
                                             ID:[innerRow objectAtIndex:6]]; // id
    return a;
}


#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"APIConnection received response for request type: %u", self->requestType);
    incomingData = [[NSMutableData alloc] init];
    isBusy = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // add the incoming chunk of data to the container we have
    [incomingData appendData:data];
   // if (self->requestType == denebolaArticleRequestType)
   //     NSLog(@"data %@", [NSString stringWithUTF8String:[incomingData bytes]]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    NSLog(@"connectionDidFinishLoading %u", requestType);
    
    requestType req = self->requestType;
    
    if (req == lionsRoarArticleRequestType || req == denebolaArticleRequestType) {
        isBusy = NO;
        [ArticleStore APIConnection:self didFinishLoadingWithRequestType:req withData:[self parseJSONDataIntoArticles:incomingData]];
    }
    else if (req == lionsRoarArticleIDRequestType) {
        NSArray *articleIDs = [self parseJSONDataIntoArticleIDs:incomingData];
        NSDictionary *sectionArticleIDs = [self parseJSONDataIntoSectionArticleIDs:incomingData];
        [ArticleStore APIConnection:self didFinishLoadingWithRequestType:req withData:[NSArray arrayWithObjects:articleIDs, sectionArticleIDs, nil]];
        [self getLionsRoarArticlesWithIDs:articleIDs];
    }
    else if (req == denebolaArticleIDRequestType) {
        NSArray *articleIDs = [self parseJSONDataIntoArticleIDs:incomingData];
        NSDictionary *sectionArticleIDs = [self parseJSONDataIntoSectionArticleIDs:incomingData];
        [ArticleStore APIConnection:self didFinishLoadingWithRequestType:req withData:[NSArray arrayWithObjects:articleIDs, sectionArticleIDs, nil]];
        [self getDenebolaArticlesWithIDs:articleIDs];
    }
    else if (req == denebolaTopNewsArticleIDRequestType) {
        isBusy = NO;
        NSArray *articleIDs = [self parseJSONDataIntoTopNewsArticleIDs:incomingData];
        [ArticleStore APIConnection:self didFinishLoadingWithRequestType:req withData:articleIDs];
    }
    else if (req == teacherAbsenceArticleRequestType) {
        isBusy = NO;
        Article *a = [self parseJSONDataIntoTeacherArticle:incomingData];
        [ArticleStore APIConnection:self didFinishLoadingWithRequestType:req withData:a];
    }
    
    incomingData = nil;
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
    incomingData = nil;
    isBusy = NO;
    
    NSString *errorString = [NSString stringWithFormat:@"Fetch failed: %@", [error localizedDescription]];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                 message:errorString
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
}

+ (BOOL)isConnectedToInternet {
    NetworkStatus currentNetworkStatus = [[Reachability reachabilityWithHostName:@"www.google.com"]currentReachabilityStatus];
    
    switch (currentNetworkStatus) {
        case NotReachable:
            return NO;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            return YES;
        default:
            return NO;
    }
}

@end
