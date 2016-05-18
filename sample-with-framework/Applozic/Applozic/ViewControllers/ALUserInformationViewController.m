//
//  ALUserInformationViewController.m
//  Applozic
//
//  Created by devashish on 16/05/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALUserInformationViewController.h"
#import "ALUserInfoTableCell.h"
#import "UIImageView+WebCache.h"
#import "ALColorUtility.h"
#import "ALUtilityClass.h"
#import "ALApplozicSettings.h"

#define HEADER_HEIGHT 80
#define ROW_HEIGHT 60
#define PROFILE_PADDING_X 10
#define PROFILE_PADDING_Y 10
#define PROFILE_WIDTH 60
#define PROFILE_HEIGHT 60

#define NAME_PADDING_X 20
#define NAME_PADDING_Y 10
#define NAME_PADDING_WIDTH 20
#define NAME_HEIGHT 20

#define NAME_ALPHABET_SIZE 20
#define NAME_SIZE 18

@implementation ALUserInformationViewController
{
    
}
-(void)viewDidLoad
{
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;

    [self.userTableView setBackgroundColor:[UIColor whiteColor]];
}

-(void)genearateDictionary
{
    self.userDetailDictionary = [NSMutableDictionary new];

    NSString * status = self.alContact.connected ? @"Online" : [self getLastSeenString:self.alContact.lastSeenAt];
    NSString * contact = self.alContact.contactNumber ? self.alContact.contactNumber : @"";
    NSString * email = self.alContact.email ? self.alContact.email : @"";
    
    [self.userDetailDictionary setObject:status forKey:@"Status"];
    [self.userDetailDictionary setObject:contact forKey:@"Contact"];
    [self.userDetailDictionary setObject:email forKey:@"EmailId"];
    
    self.keys = [NSArray arrayWithArray:[self.userDetailDictionary allKeys]];
}

-(NSString *)getLastSeenString:(NSNumber *)lastSeen
{
    ALUtilityClass * utility = [ALUtilityClass new];
    [utility getExactDate:lastSeen];
    NSString * text = [NSString stringWithFormat:@"Last seen %@ %@", utility.msgdate, utility.msgtime];
    return text;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self genearateDictionary];
    
    if([ALApplozicSettings getColorForNavigation] && [ALApplozicSettings getColorForNavigationItem])
    {
        [self.navigationController.navigationBar setBarTintColor: [ALApplozicSettings getColorForNavigation]];
        [self.navigationController.navigationBar setTintColor:[ALApplozicSettings getColorForNavigationItem]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userDetailDictionary.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self mainHeaderView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALUserInfoTableCell * tableCell = (ALUserInfoTableCell *)[tableView dequeueReusableCellWithIdentifier:@"userInfoCell"];
    
    NSString * key = [self.keys objectAtIndex:indexPath.row];
    
    tableCell.userPropertyLabel.text = key;
    tableCell.userValueLabel.text = [self.userDetailDictionary objectForKey:key];
    
    return tableCell;
}


-(UIView *)mainHeaderView
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.frame.size.width, HEADER_HEIGHT)];
    
    [headerView setBackgroundColor:self.navigationController.navigationBar.barTintColor];
    
    UIImageView * userProfileView = [[UIImageView alloc] initWithFrame:CGRectMake(PROFILE_PADDING_X,
                                                                                  headerView.frame.origin.y + PROFILE_PADDING_Y,
                                                                                  PROFILE_WIDTH, PROFILE_HEIGHT)];
    
    [userProfileView setContentMode:UIViewContentModeScaleAspectFill];
    
    UILabel * alphabetLabel = [[UILabel alloc] initWithFrame:userProfileView.frame];
    
    [alphabetLabel setBackgroundColor:[UIColor clearColor]];
    [alphabetLabel setFont:[UIFont fontWithName:@"Helvetica" size:NAME_ALPHABET_SIZE]];
    [alphabetLabel setTextColor:[UIColor whiteColor]];
    [alphabetLabel setTextAlignment:NSTextAlignmentCenter];
    
    userProfileView.layer.cornerRadius = userProfileView.frame.size.width/2;
    userProfileView.layer.masksToBounds = YES;
    
    alphabetLabel.layer.cornerRadius = alphabetLabel.frame.size.width/2;
    alphabetLabel.layer.masksToBounds = YES;
    [alphabetLabel setHidden:YES];
    
    CGFloat x = userProfileView.frame.origin.x + userProfileView.frame.size.width + NAME_PADDING_X;
    CGFloat y = userProfileView.frame.origin.y + userProfileView.frame.size.width/2 - NAME_PADDING_Y;
    CGFloat width = headerView.frame.size.width - userProfileView.frame.size.width - NAME_PADDING_WIDTH;
    
    UILabel * userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, NAME_HEIGHT)];
    
    [userNameLabel setBackgroundColor:[UIColor clearColor]];
    [userNameLabel setTextColor:[UIColor whiteColor]];
    [userNameLabel setFont:[UIFont fontWithName:@"Helvetica" size:NAME_SIZE]];
    [userNameLabel setNumberOfLines:2];
    [userNameLabel setText:[self.alContact getDisplayName]];
    
    userProfileView.backgroundColor = [UIColor whiteColor];
    
    if(self.alContact.contactImageUrl)
    {
        NSURL * theUrl = [NSURL URLWithString:self.alContact.contactImageUrl];
        [userProfileView sd_setImageWithURL:theUrl];
    }
    else
    {
        [userProfileView sd_setImageWithURL:[NSURL URLWithString:@""]];
        [alphabetLabel setHidden:NO];
        [alphabetLabel setText:[ALColorUtility getAlphabetForProfileImage:[self.alContact getDisplayName]]];
        userProfileView.backgroundColor = [ALColorUtility getColorForAlphabet:[self.alContact getDisplayName]];
    }
    
    [headerView addSubview:userProfileView];
    [headerView addSubview:alphabetLabel];
    [headerView addSubview:userNameLabel];
    [headerView addSubview:userNameLabel];
    
    return headerView;
}

@end
