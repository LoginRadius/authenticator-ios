//
//  AuthListVC.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-11-02.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "AuthListVC.h"
#import "AuthDetailVC.h"
#import "WelcomeVC.h"
#import "HOTPKeyVC.h"
#import "OTPTableViewCell.h"

#define kCatNameTextF 100
#define kAccNameTextF 101

@interface AuthListVC ()<UITableViewDelegate,UITableViewDataSource,SWRevealViewControllerDelegate,UITextFieldDelegate>
{
    NSMutableArray *arrSelected;
}
@property (weak, nonatomic) IBOutlet UIButton *sideBarButton;
@property(nonatomic, weak)IBOutlet UITableView *tblVList;
@property(nonatomic, weak)IBOutlet UIView *viewAnimated;
@property(nonatomic, weak)IBOutlet UIButton *btn1;
@property(nonatomic, weak)IBOutlet UIButton *btn2;
@property(nonatomic, weak)IBOutlet UIButton *btn3;
@property(nonatomic, weak)IBOutlet UIButton *btn4;
@property(nonatomic, weak)IBOutlet UIButton *btn5;
@property(nonatomic, weak)IBOutlet UIButton *btnAcc;
@property(nonatomic, weak)IBOutlet UIButton *btnCat;
@property(nonatomic, weak)IBOutlet UIButton *btnHow;

@end

@implementation AuthListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!_authURLs.count)
        [CommonOps showToastOnVC:self message:@"No account added to this category"];
    _viewAnimated.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
    
    NSLog(@"authurls in list%@",_authURLs);
    arrSelected = [[NSMutableArray alloc]initWithCapacity:_authURLs.count];
    for (int i = 0; i<_authURLs.count; i++) {
        [arrSelected addObject:@"0"];
    }
    _btn1.layer.masksToBounds = true;
    _btn1.layer.cornerRadius = SCREEN_WIDTH * .16 / 2;
    _btn2.layer.masksToBounds = true;
    _btn2.layer.cornerRadius = SCREEN_WIDTH * .16 / 2;
    _btn3.layer.masksToBounds = true;
    _btn3.layer.cornerRadius = SCREEN_WIDTH * .12 / 2;
    _btn4.layer.masksToBounds = true;
    _btn4.layer.cornerRadius = SCREEN_WIDTH * .12 / 2;
    _btn5.layer.masksToBounds = true;
    _btn5.layer.cornerRadius = SCREEN_WIDTH * .12 / 2;
    _btnAcc.layer.masksToBounds = true;
    _btnAcc.layer.cornerRadius = 8.0;
    _btnHow.layer.masksToBounds = true;
    _btnHow.layer.cornerRadius = 8.0;
    _btnCat.layer.masksToBounds = true;
    _btnCat.layer.cornerRadius = 8.0;
    _viewAnimated.hidden = true;
    // _viewAnimated.alpha = 0.0;
    if(!_isBack){
        _btn1.hidden = NO;
        self.title = @"Authenticator";
        
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
            [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
            
            revealViewController.delegate = self;
            
        }
        [self.sideBarButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [self.sideBarButton addTarget:revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        _btn1.hidden = YES;
        
        UIBarButtonItem *delButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(removeCategory)];
        self.navigationItem.rightBarButtonItem = delButton;
        self.title = _strCategory;
        
        [self.sideBarButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self.sideBarButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Do any additional setup after loading the view.
}

#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    // See otp_tableViewWillBeginEditing for comments on why this is being done.
    
    OTPURL *url = [self.authURLs objectAtIndex:indexPath.row];
    
    cellIdentifier = @"OTPTableViewCell";
    
    OTPTableViewCell *cell
    = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[OTPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellIdentifier] ;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if([[arrSelected objectAtIndex:indexPath.row] intValue] == 1){
        cell.viewBG.backgroundColor = [UIColor lightGrayColor];
    }
    else {
        cell.viewBG.backgroundColor = [UIColor colorWithRed:0/255.0 green:142/255.0 blue:207/255.0 alpha:1.0];
    }
    cell.viewBG.tag = indexPath.row;
    cell.btnMenu.tag = indexPath.row;
    //from side menu for particulaar category's list
    if(!_strCategory) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showRightBarButtons:)];
        [cell.viewBG addGestureRecognizer:gesture];
    }
    [cell.btnMenu addTarget:self action:@selector(pressMenu:) forControlEvents:UIControlEventTouchUpInside];
    if ([url.name.lowercaseString containsString:@"gmail.com"]){
        cell.lblName.text = @"Google";
    }else {
        NSArray *Arr = [url.name componentsSeparatedByString:@"@"];
        if((Arr.count>1) && ([Arr[1] rangeOfString:@"." options:0].location!=NSNotFound)) {
            
            cell.lblName.text=[[Arr[1] substringToIndex:( [Arr[1] rangeOfString:@"." options:0]).location] capitalizedString];
        }
        else {
            cell.lblName.text = @"Google";
        }
    }
    cell.lblEmail.text = url.name;
    
    return cell;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self pressClose:nil];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // See otp_tableViewWillBeginEditing for comments on why this is being done.
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65*SCREEN_WIDTH/320;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    // See otp_tableViewWillBeginEditing for comments on why this is being done.
    return _authURLs.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!_strCategory && [arrSelected containsObject:@"1"]) {
        //  already selected by long gesture
        if([[arrSelected objectAtIndex:indexPath.row] intValue] == 1)
            [self changeSelcteddArrayIndex:indexPath.row withValue:@"0"];
        else
            [self changeSelcteddArrayIndex:indexPath.row withValue:@"1"];
    }
    
    else {
        OTPURL *url = [self.authURLs objectAtIndex:indexPath.row];
        if(url.checkCode)
            [self performSegueWithIdentifier:@"toLRAuthDetail" sender:url];
        else
            [CommonOps showToastOnVC:self message:@"Wrong Keys"];
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"toLRAuthDetail"]) {
        AuthDetailVC *vc = (AuthDetailVC *)segue.destinationViewController;
        vc.authURL = sender;
    }
    
    else if([segue.identifier isEqualToString:@"ListToAddURLVC"]) {
        WelcomeVC *vc = (WelcomeVC *)segue.destinationViewController;
        vc.isBack = YES;
    }
    else if([segue.identifier isEqualToString:@"ListToHOTPKeyvc"]) {
        HOTPKeyVC *vc = (HOTPKeyVC *)segue.destinationViewController;
        vc.authURL = sender;
    }
}
#pragma mark - IBAction methods
- (void)showRightBarButtons:(UILongPressGestureRecognizer *)gesture {
    [self changeSelcteddArrayIndex:gesture.view.tag withValue:@"1"];
    UIBarButtonItem *selButton = [[UIBarButtonItem alloc] initWithTitle:@"SELECT ALL"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(pressSelectAll:)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"ADD"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(addToCategory:)];
    self.navigationItem.rightBarButtonItems = @[selButton,addButton,];
}
- (void)changeSelcteddArrayIndex:(NSInteger)indexx withValue:(NSString *)value {
    [arrSelected replaceObjectAtIndex:indexx withObject:value];
    NSInteger count = [arrSelected filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self LIKE[c] %@",@"1"]].count;
    if(!count){
        self.title = [NSString stringWithFormat:@"Authenticator"];
        self.navigationItem.rightBarButtonItems = nil;
    }
    else {
        self.title = [NSString stringWithFormat:@"%ld selected",count];
    }
    [_tblVList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}
- (IBAction)pressSelectAll:(id)sender {
    for (int i = 0; i<_authURLs.count; i++) {
        [self changeSelcteddArrayIndex:i withValue:@"1"];
    }
}
- (IBAction)addToCategory:(id)sender{
    OTPURLSession *uSession = [[OTPURLSession alloc] init];
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add to Category" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    NSMutableArray *catArr = [uSession getCategoriesArray];
    OTPURL *currentURL;
    
    for (int j = 0 ; j<self->_authURLs.count; j++) {
        if([[self->arrSelected objectAtIndex:j] intValue] == 1){
            currentURL = [self->_authURLs objectAtIndex:j];
        }
    }
    for (int i = 0;i<catArr.count;i++) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:[catArr objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //  [self dismissViewControllerAnimated:YES completion:^{
            OTPURL *tempURL = currentURL;
            currentURL.category = [catArr objectAtIndex:i];
            [currentURL saveToKeychain];
            [self->_authURLs replaceObjectAtIndex:[self->_authURLs indexOfObject:tempURL] withObject:currentURL];
            [uSession saveKeychainArray:self.authURLs];
            
            [CommonOps showToastOnVC:self message:[NSString stringWithFormat:@"Added to %@", currentURL.category]];
            
            
            // }];
        }]];
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Create a New Category" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Distructive button tapped.
        //   [self dismissViewControllerAnimated:YES completion:^{
        [self addCategoryFromAddToCategory:currentURL];
        //  }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)addCategory:(id)sender {
    [self addCategoryFromAddToCategory:nil];
}
- (IBAction)back:(id)sender {
    [CommonOps  goToHome];
}
- (IBAction)pressMenu:(UIButton *)sender {
    OTPURL *currentURL = ((OTPURL *)[_authURLs objectAtIndex:sender.tag]);
    OTPURLSession *uSession = [[OTPURLSession alloc] init];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:currentURL.name message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    if([currentURL isMemberOfClass:[HOTPAuth class]]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Check Key Value" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // [self dismissViewControllerAnimated:YES completion:^{
            [self performSegueWithIdentifier:@"ListToHOTPKeyvc" sender:currentURL];
            
            //  }];
        }]];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //  [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Rename" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.delegate = self;
            textField.tag = kAccNameTextF;
            textField.text = currentURL.name;
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            currentURL.name = [[alertController textFields][0] text];
            [self->_authURLs replaceObjectAtIndex:sender.tag withObject:currentURL];
            [currentURL saveToKeychain];
            [uSession saveKeychainArray:self.authURLs];
            arrSelected = [[NSMutableArray alloc]initWithCapacity:_authURLs.count];
            for (int i = 0; i<_authURLs.count; i++) {
                [arrSelected addObject:@"0"];
            }
            [self->_tblVList reloadData];
        }];
        [alertController addAction:confirmAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Canelled");
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        //  }];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //  [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Alert"
                                                                      message:[NSString stringWithFormat:@"Are you sure you want to remove %@?",currentURL.name]
                                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Remove Account"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
            [self->_authURLs removeObjectAtIndex:sender.tag];
            [uSession saveKeychainArray:self.authURLs];
            self->arrSelected = [[NSMutableArray alloc]initWithCapacity:self->_authURLs.count];
            for (int i = 0; i<self->_authURLs.count; i++) {
                [self->arrSelected addObject:@"0"];
            }
            [self->_tblVList reloadData];
        }];
        
        UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
            NSLog(@"you pressed No, thanks button");
        }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        //     }];
    }]];
    if(!_strCategory) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Add to Category" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // [self dismissViewControllerAnimated:YES completion:^{
            UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Add to Category" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            NSMutableArray *catArr = [uSession getCategoriesArray];
            for (int i = 0;i<catArr.count;i++) {
                [actionSheet addAction:[UIAlertAction actionWithTitle:[catArr objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    //  [self dismissViewControllerAnimated:YES completion:^{
                    currentURL.category = [catArr objectAtIndex:i];
                    [self->_authURLs replaceObjectAtIndex:sender.tag withObject:currentURL];
                    [currentURL saveToKeychain];
                    [uSession saveKeychainArray:self.authURLs];
                    
                    [CommonOps showToastOnVC:self message:[NSString stringWithFormat:@"Added to %@", currentURL.category]];
                    
                    //  }];
                }]];
            }
            
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
                // Cancel button tappped.
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }]];
            [actionSheet addAction:[UIAlertAction actionWithTitle:@"Create a New Category" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                
                // Distructive button tapped.
                //   [self dismissViewControllerAnimated:YES completion:^{
                [self addCategoryFromAddToCategory:currentURL];
                //  }];
            }]];
            
            
            // Present action sheet.
            [self presentViewController:actionSheet animated:YES completion:nil];
            
            // }];
        }]];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)pressPlusMenu:(id)sender {
    [UIView transitionWithView:_viewAnimated
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
        self->_btn1.hidden = true;
        self->_viewAnimated.hidden = false;
        // self->_viewAnimated.alpha = 0.5;
    }
                    completion:NULL];
}
- (IBAction)pressAddAction:(id)sender {
    [self performSegueWithIdentifier:@"ListToAddURLVC" sender:nil];
    
}
- (IBAction)pressHowItWorks:(id)sender {
    [self performSegueWithIdentifier:@"ListToWelcomeVC" sender:nil];
    
}
- (void)removeCategory {
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Alert"
                                                                  message:[NSString stringWithFormat:@"Are you sure you want to remove %@?",_strCategory]
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
        OTPURLSession *uSession = [[OTPURLSession alloc] init];
        NSMutableArray *arrCat = [uSession getCategoriesArray];
        [arrCat removeObject:self->_strCategory];
        [uSession saveCategoriesArray:arrCat];
        [CommonOps goToHome];
    }];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * action)
                               {
        /** What we write here???????? **/
        NSLog(@"you pressed No, thanks button");
        // call method whatever u need
    }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)addCategoryFromAddToCategory:(OTPURL *)url {
    OTPURLSession *uSession = [[OTPURLSession alloc] init];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Create Category" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.delegate = self;
        textField.tag = kCatNameTextF;
        textField.placeholder = @"Enter category";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *catArr = [uSession getCategoriesArray];
        if([catArr containsObject:[[alertController textFields][0] text]]) {
            [CommonOps showToastOnVC:self message:@"Category already exists."];
            
        }
        else if([[alertController textFields][0] text].length){
            [catArr addObject:[[alertController textFields][0] text]];
            [uSession saveCategoriesArray:catArr];
            [self pressClose:nil];
            
            if(url) {
                OTPURL *currentUrl = url;
                currentUrl.category = [[alertController textFields][0] text];
                [currentUrl saveToKeychain];
                [self->_authURLs replaceObjectAtIndex:[self->_authURLs indexOfObject:url] withObject:currentUrl];
                [uSession saveKeychainArray:self.authURLs];
                
                [CommonOps showToastOnVC:self message:[NSString stringWithFormat:@"Added to %@", currentUrl.category]];
            }
            
            
            
            else {
                [CommonOps showToastOnVC:self message:@"Category created."];
                
            }
            // [self->_tblVList reloadData];
        }
        
        else {
            [CommonOps showToastOnVC:self message:@"Enter category name."];
        }
    }];
    [alertController addAction:confirmAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];                       }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)pressAddCategory:(id)sender {
    [self addCategoryFromAddToCategory:nil];
}
- (IBAction)pressClose:(id)sender {
    if(_viewAnimated.isHidden == false) {
        [UIView transitionWithView:_viewAnimated
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
            self->_btn1.hidden = false;
            
            self->_viewAnimated.hidden = true;
            //  self->_viewAnimated.alpha = 0;
        }
                        completion:NULL];
    }
}
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        self.tblVList.userInteractionEnabled = true;
        revealController.frontViewController.view.alpha = 1.0;;
        
    } else {
        self.tblVList.userInteractionEnabled = false;
        revealController.frontViewController.view.alpha = 0.5;
    }
}
#pragma mark UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return (newString.length<=32);
}
@end
