//
//  ALNewContactsViewController.m
//  ChatApp
//
//  Created by Gaurav Nigam on 16/08/15.
//  Copyright (c) 2015 AppLogic. All rights reserved.
//

#import "ALNewContactsViewController.h"
#import "ALNewContactCell.h"
#import "ALDBHandler.h"
#import "DB_CONTACT.h"
#import "ALContact.h"
#import "ALChatViewController.h"
#import "ALUtilityClass.h"
#import "ALConstant.h"

#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64

@interface ALNewContactsViewController ()

@property (strong, nonatomic) NSMutableArray *contactList;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *filteredContactList;

@property (strong, nonatomic) NSString *stopSearchText;

@end

@implementation ALNewContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *color = [ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOGIC_TOPBAR_TITLE_COLOR];
    
    if (!color) {
        color = [UIColor blackColor];
    }
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    color,NSForegroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.contactList = [NSMutableArray new];
    
    [self handleFrameForOrientation];
    
    [self fetchConversationsGroupByContactId];
    
    self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Email, userid, number";
    self.navigationItem.titleView = self.searchBar;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsTableView?1:0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredContactList.count!=0?self.filteredContactList.count:0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"NewContactCell";
    
    ALNewContactCell *newContactCell = (ALNewContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel* nameIcon=(UILabel*)[newContactCell viewWithTag:101];
    ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];

    if (contact) {
        newContactCell.contactPersonName.text = contact.fullName;
        NSString *firstLetter = [contact.fullName substringToIndex:1];
        nameIcon.text=firstLetter;
        
        if (contact.contactImageUrl) 
            newContactCell.contactPersonImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contact.contactImageUrl]]];
        else
            newContactCell.contactPersonImageView.image = [UIImage imageNamed:@"ic_contact_picture_holo_light.png"];
    
        
    }
    
    
    return newContactCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALChatViewController * theVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    
    ALContact *selectedContact =  self.filteredContactList[indexPath.row];
    ALMessage *message = nil;
    if (selectedContact) {
        message = [[ALMessage alloc] init];
        
        message.contactIds = selectedContact.userId;
        message.to = selectedContact.fullName;
    }
    
    theVC.mLatestMessage = message;
    
    [self.navigationController pushViewController:theVC animated:YES];
    
}

-(void) fetchConversationsGroupByContactId
{
    
    ALDBHandler * theDbHandler = [ALDBHandler sharedInstance];
    
    // get all unique contacts
    
    NSFetchRequest * theRequest = [NSFetchRequest fetchRequestWithEntityName:@"DB_CONTACT"];
    
    [theRequest setReturnsDistinctResults:YES];
    
    NSArray * theArray = [theDbHandler.managedObjectContext executeFetchRequest:theRequest error:nil];
    
    for (DB_CONTACT *dbContact in theArray) {
        
        ALContact *contact = [[ALContact alloc] init];
        
        contact.userId = dbContact.userId;
        contact.fullName = dbContact.fullName;
        contact.contactNumber = dbContact.contactNo;
        contact.displayName = dbContact.displayName;
        contact.contactImageUrl = dbContact.contactImageUrl;
        contact.email = dbContact.email;
        
        [self.contactList addObject:contact];
    }
    
    [self.contactsTableView reloadData];
    
}

#pragma mark orientation method

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self handleFrameForOrientation];
    
}

-(void)handleFrameForOrientation {
   
    UIInterfaceOrientation toOrientation   = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
    
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone && (toOrientation == UIInterfaceOrientationLandscapeLeft || toOrientation == UIInterfaceOrientationLandscapeRight)) {
        
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_LANDSCAPE_CONSTANT;
        
    }else{
        
        self.mTableViewTopConstraint.constant = DEFAULT_TOP_PORTRAIT_CONSTANT;
    }
    
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Bar Delegate Methods -

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.stopSearchText = searchText;
    [self.filteredContactList removeAllObjects];
    if (searchText.length!=0) {
        
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ OR userId CONTAINS[cd] %@ OR contactNumber CONTAINS[cd] %@", searchText, searchText, searchText];
        NSArray *searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
        
        [self.filteredContactList addObjectsFromArray:searchResults];
       
    }else {
        [self.filteredContactList addObjectsFromArray:self.contactList];
    }
   
    [self.contactsTableView reloadData];
}

/*332
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
