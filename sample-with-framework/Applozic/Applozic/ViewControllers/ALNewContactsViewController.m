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
#import "ALUserDefaultsHandler.h"
#import "ALMessagesViewController.h"
#import "ALColorUtility.h"

#define DEFAULT_TOP_LANDSCAPE_CONSTANT -34
#define DEFAULT_TOP_PORTRAIT_CONSTANT -64

@interface ALNewContactsViewController ()

@property (strong, nonatomic) NSMutableArray *contactList;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *filteredContactList;

@property (strong, nonatomic) NSString *stopSearchText;

@property  NSUInteger lastSearchLength;

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
    self.navigationItem.title = @"Contacts";
    self.contactList = [NSMutableArray new];
    [self handleFrameForOrientation];
//    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
//    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton:@"Back"]];
    [self.navigationItem setLeftBarButtonItem: barButtonItem];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchConversationsGroupByContactId];
    });
    
    
    
    self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
    //    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height+ [UIApplication sharedApplication].statusBarFrame.size.height;
    //
    
    float y = self.navigationController.navigationBar.frame.origin.y+self.navigationController.navigationBar.frame.size.height;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,y, self.view.frame.size.width, 40)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Email, userid, number";
    [self.view addSubview:self.searchBar];
    // self.navigationItem.titleView = self.searchBar;
    
    // Do any additional setup after loading the view.
    
    /*UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
     initWithTarget:self
     action:@selector(dismissKeyboard)];
     
     [self.view addGestureRecognizer:tap];*/
    self.colors = [[NSArray alloc] initWithObjects:@"#617D8A",@"#628B70",@"#8C8863",@"8B627D",@"8B6F62", nil];
}

- (void) dismissKeyboard
{
    // add self
    [self.searchBar resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden: [ALUserDefaultsHandler isBottomTabBarHidden]];
    
    //    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
    //        // iOS 6.1 or earlier
    //        self.navigationController.navigationBar.tintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    //    } else {
    //        // iOS 7.0 or later
    //        self.navigationController.navigationBar.barTintColor = (UIColor *)[ALUtilityClass parsedALChatCostomizationPlistForKey:APPLOZIC_TOPBAR_COLOR];
    //    }
    
    if([ALApplozicSettings getColourForNavigation] && [ALApplozicSettings getColourForNavigationItem])
    {
        
        [self.navigationController.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:[ALApplozicSettings getFontFace] size:18]}];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColourForNavigation]];
        [self.navigationController.navigationBar setTintColor: [ALApplozicSettings getColourForNavigationItem]];
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self.tabBarController.tabBar setHidden: NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsTableView?1:0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.filteredContactList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"NewContactCell";
    
    ALNewContactCell *newContactCell = (ALNewContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel* nameIcon = (UILabel*)[newContactCell viewWithTag:101];
    nameIcon.layer.cornerRadius = nameIcon.frame.size.width/2;
    NSUInteger randomIndex = random()% [self.colors count];
    nameIcon.backgroundColor = [ALColorUtility colorWithHexString:self.colors[randomIndex]];
    [nameIcon setTextColor:[UIColor whiteColor]];
    nameIcon.layer.masksToBounds = YES;
    ALContact *contact = [self.filteredContactList objectAtIndex:indexPath.row];
    //Write the logic to get display nme
    if (contact) {
        newContactCell.contactPersonName.text = [contact getDisplayName];
        NSLog(@"DISPLAY NAME %@", [contact getDisplayName]);
        NSString *firstLetter = [newContactCell.contactPersonName.text substringToIndex:1];
        //        nameIcon.text=firstLetter;
        NSRange whiteSpaceRange = [newContactCell.contactPersonName.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if (whiteSpaceRange.location != NSNotFound)
        {
            NSArray *listNames = [newContactCell.contactPersonName.text componentsSeparatedByString:@" "];
            NSString *firstLetter = [[listNames[0] substringToIndex:1] uppercaseString];
            NSString *lastLetter = [[listNames[1] substringToIndex:1] uppercaseString];
            nameIcon.text = [[firstLetter stringByAppendingString:lastLetter] uppercaseString];
        }
        else
        {
            nameIcon.text = [firstLetter uppercaseString];
        }
        
        
        
        if (contact.contactImageUrl) {
            newContactCell.contactPersonImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:contact.contactImageUrl]]];
        }else{
            newContactCell.contactPersonImageView.image = [ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"];
            
        }
        
    }
    
    
    return newContactCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALContact *selectedContact =  self.filteredContactList[indexPath.row];
    [self launchChatForContact:selectedContact.userId];
    
    
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
        contact.localImageResourceName = dbContact.localImageResourceName;
        [self.contactList addObject:contact];
    }
    
    //    self.filteredContactList = [NSMutableArray arrayWithArray:self.contactList];
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray * descriptors = [NSArray arrayWithObject:valueDescriptor];
    self.filteredContactList = [NSMutableArray arrayWithArray:[self.contactList sortedArrayUsingDescriptors:descriptors]];
    
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    // Do the search...
    ALChatViewController * theVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ALChatViewController"];
    theVC.contactIds = searchBar.text;
    
}

#pragma mark - Search Bar Delegate Methods -

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.stopSearchText = searchText;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getSerachResult:searchText];
    });
    
}

-(void)getSerachResult:(NSString*)searchText {
    
    if (searchText.length!=0) {
        
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ OR userId CONTAINS[cd] %@ OR contactNumber CONTAINS[cd] %@ OR fullName CONTAINS[cd] %@", searchText, searchText, searchText,searchText];
        if(self.lastSearchLength >searchText.length ){
            NSArray *searchResults = [self.contactList filteredArrayUsingPredicate:searchPredicate];
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
            
        }else{
            NSArray *searchResults = [self.filteredContactList filteredArrayUsingPredicate:searchPredicate];
            [self.filteredContactList removeAllObjects];
            [self.filteredContactList addObjectsFromArray:searchResults];
        }
    }else {
        [self.filteredContactList removeAllObjects];
        [self.filteredContactList addObjectsFromArray:self.contactList];
    }
    
    self.lastSearchLength = searchText.length;
    [self.contactsTableView reloadData];
}


-(void)back:(id)sender {
    NSLog(@"backbuttonClicked.....");
    // UIViewController uiController = [self.navigationController pop];
    
    UIViewController *    viewControllersFromStack = [self.navigationController popViewControllerAnimated:YES];
    if(!viewControllersFromStack){
        self.tabBarController.selectedIndex = 0;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

-(void)launchChatForContact:( NSString *)contactId{
    
    
    BOOL isFoundInBackStack =false;
    
    NSMutableArray *viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
    
    for (UIViewController *currentVC in viewControllersFromStack)
    {
        if ([currentVC isKindOfClass:[ALMessagesViewController class]])
        {
            NSLog(@"found in backStack .....launching from current vc");
            
            [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
            isFoundInBackStack = true;
        }
    }
    if(!isFoundInBackStack){
        NSLog(@"Not found in backStack .....");
        self.tabBarController.selectedIndex=0;
        UINavigationController * uicontroller =  self.tabBarController.selectedViewController;
        NSMutableArray *viewControllersFromStack = [uicontroller.childViewControllers mutableCopy];
        
        for (UIViewController *currentVC in viewControllersFromStack)
        {
            if ([currentVC isKindOfClass:[ALMessagesViewController class]])
            {
                NSLog(@"f####ound in backStack .....launching from current vc");
                [(ALMessagesViewController*) currentVC createDetailChatViewController:contactId];
                isFoundInBackStack = true;
            }
        }
    }else{
        //remove ALNewContactsViewController from back stack...
        
        viewControllersFromStack = [self.navigationController.viewControllers mutableCopy];
        if(viewControllersFromStack.count >=2 && [ [viewControllersFromStack objectAtIndex:viewControllersFromStack.count -2] isKindOfClass:[ALNewContactsViewController class]]){
            [ viewControllersFromStack removeObjectAtIndex:viewControllersFromStack.count -2];
            self.navigationController.viewControllers = viewControllersFromStack;
            
        }
    }
}

-(UIView *)setCustomBackButton:(NSString *)text
{
    UIImageView *imageView=[[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , @"back".length, 15)];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    return view;
    
}

@end
