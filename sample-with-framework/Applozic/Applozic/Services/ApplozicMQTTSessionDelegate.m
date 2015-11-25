//
//  ApplozicMQTTSessionDelegate.m
//  Applozic
//
//  Created by Applozic Inc on 11/26/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ApplozicMQTTSessionDelegate.h"

@implementation ApplozicMQTTSessionDelegate

- (void)handleEvent:(MQTTSession *)session
              event:(MQTTSessionEvent)eventCode
              error:(NSError *)error {
    NSLog(@"###inside handleEvent");
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    NSLog(@"###inside newMessage");
}


@end
