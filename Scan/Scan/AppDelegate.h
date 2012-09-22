//
//  AppDelegate.h
//  Scan
//
//  Created by Khaos Tian on 6/12/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    NSMutableData *finaldata;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)Connect:(id)sender;
@property (weak) IBOutlet NSButton *Button;
- (IBAction)disconnect:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *TextView;
@property (weak) IBOutlet NSTextFieldCell *RSSIText;
@property (weak) IBOutlet NSButton *DisconnectButton;

@end
