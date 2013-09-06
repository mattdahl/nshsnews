//
//  AboutViewController.m
//  nshsnews
//
//  Created by Matt Dahl on 6/3/13.
//  Copyright (c) 2013 mattdahl. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.navigationItem setTitle:@"About"];
        
        [mailTo addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(openMailToURL)]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openMailToURL {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:matt.dahl.2013@gmail.com"]];
}

@end
