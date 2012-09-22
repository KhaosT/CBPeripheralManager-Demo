//
//  AppDelegate.m
//  Scan
//
//  Created by Khaos Tian on 6/12/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize TextView;
@synthesize RSSIText;
@synthesize DisconnectButton;
@synthesize Button;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    finaldata = [[NSMutableData alloc]init];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_current_queue()];
    // Insert code here to initialize your application
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%ld",[manager state]);
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    RSSIText.title = [NSString stringWithFormat:@"%@",RSSI];
    NSLog(@"%@",[advertisementData description]);
    //if ([RSSI floatValue]>=-45.f) {
        //NSLog(@"Greater than 45");
        [central stopScan];
        peripheral = aPeripheral;
        [central connectPeripheral:peripheral options:nil];
    //}
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed:%@",error);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{    
    NSLog(@"Connected:%@",aPeripheral.UUID);
    [TextView insertText:[NSString stringWithFormat:@"Connected:%@\n",aPeripheral.UUID]];
    [DisconnectButton setEnabled:YES];
    Button.title = @"Connected";
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Disconnected");
    [TextView insertText:@"Disconnected\n"];
    [DisconnectButton setEnabled:NO];
    Button.title = @"Connect";
    [finaldata setLength:0];
    [Button setEnabled:YES];
    [manager stopScan];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services){
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics){
        NSLog(@"%@",aChar.UUID);
        [TextView insertText:[NSString stringWithFormat:@"Characteristic UUID:%@\n",aChar.UUID]];
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA18"]]) {
            NSLog(@"%lu",aChar.properties);
            [TextView insertText:[NSString stringWithFormat:@"Characteristic Prop:%lu\n",aChar.properties]];
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA17"]]) {
            //NSLog(@"Find DA17");
            NSLog(@"%lu",aChar.properties);
            [TextView insertText:[NSString stringWithFormat:@"Characteristic Prop:%lu\n",aChar.properties]];
            NSString *mainString = [NSString stringWithFormat:@"12345"];
            NSData *mainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
            [aPeripheral writeValue:mainData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA16"]]) {
            NSLog(@"Find DA16");
            NSLog(@"%lu",aChar.properties);
            [TextView insertText:[NSString stringWithFormat:@"Characteristic Prop:%lu\n",aChar.properties]];
            //[aPeripheral readValueForCharacteristic:aChar];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"Finish Write\n");
    [TextView insertText:@"Finish Write\n"];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData * updatedValue = characteristic.value;
    NSLog(@"%@",[[NSString alloc]initWithData:updatedValue encoding:NSUTF8StringEncoding]);
    if ([[[NSString alloc]initWithData:updatedValue encoding:NSUTF8StringEncoding]isEqualToString:@"ENDAL"]) {
        [manager cancelPeripheralConnection:aPeripheral];
        [TextView insertText:[NSString stringWithFormat:@"%@\n",[[NSJSONSerialization JSONObjectWithData:finaldata options:kNilOptions error:nil]description]]];
    }else{
        [finaldata appendData:updatedValue];
    }
}

- (IBAction)Connect:(id)sender {
    //A workaround for CBPeripheralManager
    [manager scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:@"FC44DD96-71BC-DFB0-BA4D-9B0D5089A3EB"],[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
    Button.title = @"Scanning";
    [Button setEnabled:NO];
}

- (IBAction)disconnect:(id)sender {
    [manager cancelPeripheralConnection:peripheral];
}
@end
