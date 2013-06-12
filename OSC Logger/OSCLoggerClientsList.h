//
//  OSCLoggerClientsList.h
//  OSC Logger
//
//  Created by Charles Martin on 7/06/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCLoggerClientsList : NSObject

@property (strong, nonatomic) NSMutableArray *clients;

-(BOOL) addClient:(NSString *) address;
-(NSString *) asString;

@end
