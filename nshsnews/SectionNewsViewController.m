//
//  SectionNewsViewController.m
//  LionsRoar
//
//  Created by Matt Dahl on 4/23/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "SectionNewsViewController.h"
#import "ArticleCell.h"
#import "ArticleViewController.h"
#import "ArticleStore.h"
#import "LoadingViewController.h"
#import "Article.h"

@implementation SectionNewsViewController

@synthesize sectionTitle, loadingViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil sectionTitle:(NSString *)t {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sectionTitle = t;
        isFinishedLoading = NO;
        articles = [ArticleStore getArticlesForSection:sectionTitle];
        [self.tableView setUserInteractionEnabled:NO];
        [self setTitle:[NSString stringWithFormat:@"Section: %@", t]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    UINib *nib = [UINib nibWithNibName:@"ArticleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"ArticleCell"];
    
    if ([ArticleStore hasArticlesForSection:sectionTitle]) {
        articles = [ArticleStore getArticlesForSection:sectionTitle];
        NSLog(@"section articles: %@", articles);
        isFinishedLoading = YES;
        [self.tableView setUserInteractionEnabled:YES];
    }
    else
        loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil delegate:self task:[ArticleStore isFinishedLoadingArticlesBlock]];
    
    UIRefreshControl *r = [[UIRefreshControl alloc] init];
    [r setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Pull to Refresh"]];
    [r addTarget:self
          action:@selector(refreshView:)
forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:r];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!isFinishedLoading)
        [UIApplication.sharedApplication.delegate.window addSubview:loadingViewController.view];
    else
        [self.tableView setUserInteractionEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [loadingViewController.view removeFromSuperview];
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

- (void)loadArticles {
    articles = [[NSMutableArray alloc] initWithArray:[ArticleStore getArticlesForSection:sectionTitle]];
    [self.tableView reloadData];
    [self.tableView setNeedsDisplay];
}

- (Article *)firstArticle {
    if ([articles count])
        return [articles objectAtIndex:0];
    return nil;
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
    
    if ([articles count] == 0)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        Article *a = [articles objectAtIndex:indexPath.row];
        
        [(ArticleCell *)cell setArticle:a];
        [(ArticleCell *)cell setArticleTitle:a.title];
        [a setDelegate:(ArticleCell *)cell];
        [[(ArticleCell *)cell thumbnailImageView] setImage:nil]; // clears old thumbnail
        [(ArticleCell *)cell setNeedsDisplay];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMMM dd, yyyy"];
        NSString *formattedDate = [formatter stringFromDate:a.date];
        [[(ArticleCell *)cell articleDate] setText:formattedDate];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *navBarTitle = [NSString stringWithFormat:@"%d of %d", indexPath.row+1, [articles count]];
    ArticleViewController *avc = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController"
                                                                         bundle:nil
                                                                        article:[articles objectAtIndex:indexPath.row]
                                                                    navBarTitle:navBarTitle];
    [[articles objectAtIndex:indexPath.row] setDelegate:avc]; // passes the delegate
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
    isFinishedLoading = YES;
    [self->loadingViewController.view removeFromSuperview];
    [self loadArticles];
    [self.tableView reloadData];
    [self.tableView setUserInteractionEnabled:YES];
}

@end
