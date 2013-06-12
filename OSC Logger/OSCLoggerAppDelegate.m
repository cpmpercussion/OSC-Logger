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
    connection = [[OSCConnection alloc] init];
    connection.delegate = self;
    connection.continuouslyReceivePackets = YES;
    
    NSError *error;
    
    if (![connection bindToAddress:nil port:PORT error:&error])
    {
        // do something with the error
        NSLog(@"Failed to bind connection");
    }
    [connection receivePacket];
    // Connection ready.
    if (error == nil) {
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
    }
    
    // Init some logging objects
    self.initialTime = [[NSDate alloc] init];
    self.clientsList = [[OSCLoggerClientsList alloc] init];
    
    
    // Init the file to write data.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"OSCLog %@",[self.initialTime descriptionWithCalendarFormat:nil timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.txt",documentsDirectory,fileName];
    
    NSLog(filePath);
    
    self.fileManager = [NSFileManager defaultManager];
    [self.fileManager createFileAtPath:filePath contents:nil attributes:nil];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
}

-(void)applicationWillTerminate:(NSNotification *)notification {
    [connection disconnect];
    connection = nil;
    [self.fileHandle closeFile];
    NSLog(@"Cleaning up.");
}

#pragma mark - OSC Delegate Methods

- (void)oscConnection:(OSCConnection *)connection didReceivePacket:(OSCPacket *)packet {
    // save the packet
    //NSLog ([packet description]);
}

- (void)oscConnection:(OSCConnection *)connection didReceivePacket:(OSCPacket *)packet fromHost:(NSString *)host port:(UInt16)port {
    // Record connected client details
    if ([self.clientsList addClient:host]) {
        [self.connectedClientList setStringValue:[self.clientsList asString]];
        NSLog(@"Updated Client List");
    } else {
        NSLog(@"Client List still current.");
    }
    
    // display the packet
    NSString *loggedPacket = [NSString stringWithFormat:@"%f, %@, %@\n",[self.initialTime timeIntervalSinceNow] * -1, host,[packet description]];
    [self.lastMessageField setStringValue:loggedPacket];
    // save the packet to the log.
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:[loggedPacket dataUsingEncoding:NSASCIIStringEncoding]];
    
}

@end
