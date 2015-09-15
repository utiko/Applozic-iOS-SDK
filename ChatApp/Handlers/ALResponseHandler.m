//
//  ALResponseHandler.m
//  ALChat
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "ALResponseHandler.h"

@implementation ALResponseHandler

#define message_SomethingWentWrong @"SomethingWentWrong"

+(void)processRequest:(NSMutableURLRequest *)theRequest andTag:(NSString *)tag WithCompletionHandler:(void (^)(id, NSError *))reponseCompletion
{
    
    [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        //connection error
        if (connectionError) {
            reponseCompletion(nil,[self errorWithDescription:@"Unable to connect with the server. Check your internet connection and try again"]);
            return ;
        }
        
      
        // reponse code
        
        NSHTTPURLResponse * theHttpResponse = (NSHTTPURLResponse *) response;
        
        if (theHttpResponse.statusCode != 200) {
            
            NSMutableString * errorString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"api error : %@ - %@",tag,errorString);
            
            reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
            
            return;
        }
        
        if (data == nil) {
          
            reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
            
            NSLog(@"api error - %@",tag);

            return;
        }
        
        id theJson = nil;
        
        if ([tag isEqualToString:@"SEND MESSAGE"] || [tag isEqualToString:@"CREATE FILE URL"] || [tag isEqualToString:@"IMAGE POSTING"]) {
            
            theJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
        }else {
            
            NSError * theJsonError = nil;
            
            theJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&theJsonError];
            
            if (theJsonError) {
                
                NSMutableString * errorString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                NSLog(@"api error : %@ - %@",tag,errorString);
                
                reponseCompletion(nil,[self errorWithDescription:message_SomethingWentWrong]);
                
                return;
            }
        }
        reponseCompletion(theJson,nil);
        
    }];
    
}

+(NSError *) errorWithDescription:(NSString *) reason
{
    return [NSError errorWithDomain:@"AppLogic" code:1 userInfo:[NSDictionary dictionaryWithObject:reason forKey:NSLocalizedDescriptionKey]];
}


@end
