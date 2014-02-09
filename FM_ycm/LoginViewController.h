//
//  LoginViewController.h
//  FM_ycm
//
//  Created by yangcaimu on 14-2-4.
//  Copyright (c) 2014年 yangcaimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

-(void)loginViewControllerDidCancel:(LoginViewController *)controller;
-(void)loginViewControllerDidSave:(LoginViewController *)controller;

@end

@interface LoginViewController : UITableViewController

@property(nonatomic,strong) id <LoginViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;


- (IBAction)cancelAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)TextField_DidEndOnExit:(UITextField *)sender;

@end
