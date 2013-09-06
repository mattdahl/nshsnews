//
//  NewsViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 4/7/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "NewsViewController.h"
#import "ArticleStore.h"
#import "ArticleCell.h"
#import "ArticleViewController.h"
#import "Article.h"

@implementation NewsViewController

@synthesize loadingViewController;

static NSArray *articles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationItem setTitle:@"All News"];
        [self setTitle:@"All News"]; // used for tabBarItem
        [self.tabBarItem setImage:[UIImage imageNamed:@"AllNewsTabBarImage"]];
        
        articles = [NSMutableArray array];
        isFinishedLoading = false;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ArticleCell"];
    
    if ([ArticleStore hasArticlesForSection:@"All News"])
        [self loadArticles];
    else
        loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil delegate:self task:[ArticleStore isFinishedLoadingArticlesBlock]];
    
    UIRefreshControl *r = [[UIRefreshControl alloc] init];
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to Refresh"]];
    [r addTarget:self
          action:@selector(refreshView:)
forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:r];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!isFinishedLoading)
        [UIApplication.sharedApplication.delegate.window addSubview:loadingViewController.view];
    else
        [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [loadingViewController.view removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)loadArticles {    
    articles = [[NSMutableArray alloc] initWithArray:[ArticleStore getArticlesForSection:@"All News"]];
    [self.tableView setNeedsDisplay];
}

- (void)updateArticles { //pull down refresh thing
    [ArticleStore updateArticles];
}

+ (NSString *)archivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    NSLog(@"%@", [documentDirectory stringByAppendingPathComponent:@"newsViewController.archive"]);
    return [documentDirectory stringByAppendingPathComponent:@"newsViewController.archive"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Refresh callback

- (void)refreshView:(UIRefreshControl *)r {
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
    
    [ArticleStore updateArticles];
    [self loadArticles];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, HH:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[ArticleStore lastUpdateDate]]];
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
    [r endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [articles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ArticleCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Article *a;
    
    if (indexPath.row == 0)
        a = [ArticleStore teacherAbsenceArticle];
    else
        a = [articles objectAtIndex:indexPath.row-1];
           
    [(ArticleCell *)cell setArticle:a];
    [(ArticleCell *)cell setArticleTitle:a.title];
    [a setDelegate:(ArticleCell *)cell];
    [[(ArticleCell *)cell thumbnailImageView] setImage:nil]; // clears old thumbnail
    [(ArticleCell *)cell setNeedsDisplay];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM dd, yyyy"];
    NSString *formattedDate = [formatter stringFromDate:a.date];
    [[(ArticleCell *)cell articleDate] setText:formattedDate];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *navBarTitle = [NSString stringWithFormat:@"%d of %d", indexPath.row+1, [articles count]+1];
    ArticleViewController *avc;
    
    if (indexPath.row == 0) {
        avc = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController"
                                                      bundle:nil
                                                     article:[ArticleStore teacherAbsenceArticle]
                                                 navBarTitle:navBarTitle];
        [[ArticleStore teacherAbsenceArticle] setDelegate:avc]; // passes the delegate
    }
    else {
        avc = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController"
                                                      bundle:nil
                                                     article:[articles objectAtIndex:indexPath.row-1]
                                                 navBarTitle:navBarTitle];
        [[articles objectAtIndex:indexPath.row-1] setDelegate:avc]; // passes the delegate
    }
    
    [self.navigationController pushViewController:avc animated:YES];
}

#pragma mark - LoadingViewControllerDelegate

- (BOOL)shouldLoadingViewControllerAnimate:(LoadingViewController *)loadingViewController {
    return YES;
}

- (void)loadingViewControllerDidStartLoading:(LoadingViewController *)loadingViewController {
    [UIApplication.sharedApplication.delegate.window addSubview:self->loadingViewController.view];
}

- (void)loadingViewControllerDidFinishLoading:(LoadingViewController *)loadingViewController {
    isFinishedLoading = true;
    [self->loadingViewController.view removeFromSuperview];
    [self loadArticles];
    [self.tableView reloadData];
    [self.tableView setUserInteractionEnabled:YES];
}

@end
