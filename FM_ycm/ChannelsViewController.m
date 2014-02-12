//
//  ChannelsViewController.m
//  FM_ycm
//
//  Created by yangcaimu on 14-2-4.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import "ChannelsViewController.h"
#import "Channel.h"

@interface ChannelsViewController ()

@end

@implementation ChannelsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Channels"];
    self.channel=[self.channels objectAtIndex:indexPath.row];
    cell.textLabel.text=self.channel.name;
    return cell;
}

#pragma mark - UITableViewDelegate method
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.channel=[self.channels objectAtIndex:indexPath.row];
    [self.delegate ChannelsViewControllerDidSelect:self didChannel:self.channel];
}

@end
