//
//  OSCLoggerClientsList.m
//  OSC Logger
//
//  Created by Charles Martin on 7/06/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import "OSCLoggerClientsList.h"

@implementation OSCLoggerClientsList

-(NSMutableArray *) clients {
    if (!_clients) _clients = [[NSMutableArray alloc] init];
    return _clients;
}


-(BOOL)addClient:(NSString *)address
{
    if (![self.clients containsObject:address]) {
        [self.clients addObject:address];
        return YES;
    } else {
        return NO;
    }
}

-(NSString *)asString {
    NSString *list = [[NSString alloc] init];
    for (NSString *client in self.clients) {
        list = [NSString stringWithFormat:@"%@%@\n",list,client];
    }
    return list;
}

@end
