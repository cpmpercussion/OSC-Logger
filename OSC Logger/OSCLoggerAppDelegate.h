//
//  OSCLoggerAppDelegate.h
//  OSC Logger
//
//  Created by Charles Martin on 12/06/13.
//  Copyright (c) 2013 Charles Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "CocoaOSC.h"
#import "OSCLoggerClientsList.h"


@interface OSCLoggerAppDelegate : NSObject <NSApplicationDelegate, OSCConnectionDelegate> {
    OSCConnection *connection;
}


@property (assign) IBOutlet NSWindow *window;

@property NSNetService *netService;
@property (weak) IBOutlet NSTextField *connectedClientList;
@property (weak) IBOutlet NSTextField *lastMessageField;
@property (strong, nonatomic) NSDate *initialTime;
@property (strong, nonatomic) OSCLoggerClientsList *clientsList;
@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong,nonatomic) NSFileHandle *fileHandle;

@end
