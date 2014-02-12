//
//  LoginViewController.m
//  FM_ycm
//
//  Created by yangcaimu on 14-2-4.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController{

}

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

#pragma mark - UITableViewDelegate method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self.nameText becomeFirstResponder];
    }else if (indexPath.section == 1){
        [self.passwordText becomeFirstResponder];
    }
}

#pragma mark - Action method

- (IBAction)cancelAction:(id)sender {
    [self.delegate loginViewControllerDidCancel:self];
}

- (IBAction)loginAction:(id)sender {
    [self.delegate loginViewControllerDidSave:self];
}

- (IBAction)TextField_DidEndOnExit:(UITextField *)sender{
    if (sender.tag == 100) {
        [self.passwordText becomeFirstResponder];
    }else if (sender.tag == 200){
        [self.passwordText resignFirstResponder];
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
