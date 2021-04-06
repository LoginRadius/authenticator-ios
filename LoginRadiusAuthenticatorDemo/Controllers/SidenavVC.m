//
//  SidenavVC.m
//  LoginRadiusAuthenticator
//
//  Created by LoginRadius Development Team on 2020-04-26.
//  Copyright © 2020 LoginRadius Inc. All rights reserved.
//

#import "SidenavVC.h"
#import "WebViewContainerVC.h"

@interface SidenavVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arrCat;
    int selectedCat;
}
@property (weak, nonatomic) IBOutlet UITableView *tblV1;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@end

@implementation SidenavVC

- (void)viewDidLoad {
    [super viewDidLoad];
    arrCat = [[NSMutableArray alloc] init];
   
    self.tblV1.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"])
    _lblVersion.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
else
    _lblVersion.text = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];

   // self.navigationController.navigationBarHidden =YES;
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
   
    return 3+arrCat.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
static NSString *simpleTableIdentifier = @"SimpleTableItem";

UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    imgV.image =[UIImage imageNamed:@"downarrow"];
    if(indexPath.row ==0){
        cell.textLabel.text = @"Categories";
        cell.accessoryView = imgV;

        cell.imageView.image = [UIImage imageNamed:@"bluecategory"];
    }
    else if(indexPath.row ==1+arrCat.count){
        cell.accessoryView = nil;

           cell.textLabel.text = @"About Us";
        cell.imageView.image = [UIImage imageNamed:@"about"];

    }
    else if(indexPath.row ==2+arrCat.count){
        cell.accessoryView = nil;

        cell.imageView.image = [UIImage imageNamed:@"contact"];
            cell.textLabel.text = @"Contact Us";
    }
    //categories cells
    else{
        cell.accessoryView = nil;

        cell.textLabel.text = [arrCat objectAtIndex:indexPath.row-1];
    }
    return cell;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"sideToListVC"]) {
        
        LRAuthListVC *listVC = (LRAuthListVC *)((UINavigationController *)segue.destinationViewController).viewControllers[0];
        listVC.isBack = true;
        listVC.strCategory = [arrCat objectAtIndex:selectedCat];
        listVC.authURLs = sender;
    }
    else if([segue.identifier isEqualToString:@"toWebVC"]) {
        WebViewContainerVC *webVC = (WebViewContainerVC*)((UINavigationController *)segue.destinationViewController).viewControllers[0];
        webVC.webMenu = ((NSNumber *)sender).intValue;
}
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LRURLSession *uSession = [[LRURLSession alloc] init];

    if(indexPath.row ==0)
        {

            if(!arrCat.count) {

                if([uSession getCategoriesArray].count){
                    [arrCat addObjectsFromArray:[uSession getCategoriesArray]];
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                                      for (int i = 0; i<arrCat.count; i++) {
                                                              [arr addObject:[NSIndexPath indexPathForRow:i+1 inSection:0]];

                                      }
                    [tableView beginUpdates];
                  
                    [tableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
                }
                    else {

                        [CommonOps showToastOnVC:self.revealViewController message:@"No category available"];
                           }
                
            }
            else {
                if([uSession getCategoriesArray].count){
                    NSMutableArray *arr = [[NSMutableArray alloc] init];
                                                         for (int i = 0; i<arrCat.count; i++) {
                                                                                 [arr addObject:[NSIndexPath indexPathForRow:i+1 inSection:0]];

                                                         }
                    [arrCat removeAllObjects];

                [tableView beginUpdates];
                    [_tblV1 deleteRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
                [tableView endUpdates];
                }
                else {
                    [CommonOps showToastOnVC:self.revealViewController message:@"No category available"];
                       }
            }
        }
    else if(indexPath.row ==1+arrCat.count) {
       
        [self performSegueWithIdentifier:@"toWebVC" sender:[NSNumber numberWithInt:about]];
    }
    else if(indexPath.row ==2+arrCat.count){
                [self performSegueWithIdentifier:@"toWebVC" sender:[NSNumber numberWithInt:contact]];
    }
    else if(indexPath.row ==3+arrCat.count){
    }
    else{
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[[uSession getKeychainArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(category == %@)",[arrCat objectAtIndex:indexPath.row-1]]]];
        //if(arr.count)
        selectedCat = indexPath.row - 1;
    [self performSegueWithIdentifier:@"sideToListVC" sender:arr];
    }
}

@end
