//
//  DB_ConversationProxy.h
//  Applozic
//
//  Created by devashish on 13/01/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface DB_ConversationProxy : NSManagedObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *topicId;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic) BOOL *created;

@end
