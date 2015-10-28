//
//  OSCLoggerAppDelegate.m
//  OSC Logger
//
//  Created by Charles Martin on 12/06/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import "OSCLoggerAppDelegate.h"

@implementation OSCLoggerAppDelegate

#define PORT 3000


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.connection = [[F53OSCServer alloc] init];
    
    [self.connection setDelegate:self];
    [self.connection setPort:PORT];
    [self.connection startListening];
    
    NSLog(@"Bound Connection");
    // register with Bonjour
    self.netService = [[NSNetService alloc]
                       initWithDomain:@""
                       type:@"_osclogger._udp"
                       name:[NSString stringWithFormat:@"%@'s OSC Logger", NSFullUserName()]
                       port:PORT];
    if (self.netService != nil) {
        [self.netService setDelegate: self];
        [self.netService publishWithOptions:0];
        NSLog(@"NetService Published.");
    }

    
    // Init some logging objects
    self.initialTime = [[NSDate alloc] init];
    self.clientsList = [[OSCLoggerClientsList alloc] init];
    
    
    // Init the file to write data.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"OSCLog %@",[self.initialTime descriptionWithCalendarFormat:nil timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",documentsDirectory,fileName];
    
    NSLog(@"File %@",filePath);
    
    self.fileManager = [NSFileManager defaultManager];
    [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [self.connection stopListening];
    [self.fileHandle closeFile];
    NSLog(@"Cleaning up.");
}

#pragma mark - OSC Delegate Methods
- (void)takeMessage:(F53OSCMessage *)message {
    // Record connected client details
    if ([self.clientsList addClient:message.replySocket.host]) {
        [self.connectedClientList setStringValue:[self.clientsList asString]];
        NSLog(@"Updated Client List");
    } else {
        NSLog(@"Client List still current.");
    }
    
    if (![message.addressPattern isEqualToString:@"/metatone/acceleration"]) {
        // display the packet
        NSString *loggedPacket = [NSString stringWithFormat:@"%f, %@, %@\n",[self.initialTime timeIntervalSinceNow] * -1, message.replySocket.host,[message description]];
        loggedPacket = [loggedPacket stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        loggedPacket = [loggedPacket stringByReplacingOccurrencesOfString:@"OSCMutableMessage" withString:@""];
        loggedPacket = [loggedPacket stringByReplacingOccurrencesOfString:@"    " withString:@" "];
        loggedPacket = [loggedPacket stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        loggedPacket = [loggedPacket stringByAppendingString:@"\n"];
        [self.lastMessageField setStringValue:loggedPacket];
        // save the packet to the log.
 
        [self.fileHandle seekToEndOfFile];
        [self.fileHandle writeData:[loggedPacket dataUsingEncoding:NSASCIIStringEncoding]];
    }
}

@end
