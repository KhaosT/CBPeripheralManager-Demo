//
//  ViewController.m
//  PeripheralModeTest
//
//  Created by Khaos Tian on 6/12/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize Label;
@synthesize Log;

- (void)viewDidLoad
{
    [super viewDidLoad];
    manager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    centmanager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [centmanager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
            break;
            
        default:
            NSLog(@"%i",central.state);
            break;
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if ([RSSI floatValue]>=-45.f) {
    NSLog(@"Greater than 45");
        [central stopScan];
        aCperipheral = aPeripheral;
        [central connectPeripheral:aCperipheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed:%@",error);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"Connected:%@",aPeripheral.UUID);
    [aCperipheral setDelegate:self];
    [aCperipheral discoverServices:nil];
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
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"DA17"]]) {
            //NSLog(@"Find DA17");
            NSString *mainString = [NSString stringWithFormat:@"DA12312"];
            NSData *mainData1= [mainString dataUsingEncoding:NSUTF8StringEncoding];
            [aPeripheral writeValue:mainData1 forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [centmanager cancelPeripheralConnection:aPeripheral];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    NSLog(@"Done");
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:{
            CBUUID *cUDID = [CBUUID UUIDWithString:@"DA18"];
            CBUUID *cUDID1 = [CBUUID UUIDWithString:@"DA17"];
            CBUUID *cUDID2 = [CBUUID UUIDWithString:@"DA16"];
            
            
            CBUUID *sUDID = [CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"];
            characteristic = [[CBMutableCharacteristic alloc]initWithType:cUDID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
            characteristic1 = [[CBMutableCharacteristic alloc]initWithType:cUDID1 properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
            characteristic2 = [[CBMutableCharacteristic alloc]initWithType:cUDID2 properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
            NSLog(@"%u",characteristic2.properties);
            servicea = [[CBMutableService alloc]initWithType:sUDID primary:YES];
            servicea.characteristics = @[characteristic,characteristic1,characteristic2];
            [peripheral addService:servicea];
        }
            break;
            
        default:
            NSLog(@"%i",peripheral.state);
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"Added");
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : @"KhaosT", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]};

    [peripheral startAdvertising:advertisingData];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"Hahah");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic12{
    NSLog(@"Core:%@",characteristic12.UUID);
    NSLog(@"Connected");
    [self writeData:peripheral];
}

- (void)writeData:(CBPeripheralManager *)peripheral{
    NSDictionary *dict = @{ @"NAME" : @"Khaos Tian",@"EMAIL":@"khaos.tian@gmail.com" };
    mainData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    while ([self hasData]) {
        if([peripheral updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:nil]){
            [self ridData];
        }else{
            return;
        }
    }
    NSString *stra = @"ENDAL";
    NSData *dataa = [stra dataUsingEncoding:NSUTF8StringEncoding];
    [peripheral updateValue:dataa forCharacteristic:characteristic onSubscribedCentrals:nil];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    while ([self hasData]) {
        if([peripheral updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:nil]){
            [self ridData];
        }else{
            return;
        }
    }
    NSString *stra = @"ENDAL";
    NSData *dataa = [stra dataUsingEncoding:NSUTF8StringEncoding];
    [peripheral updateValue:dataa forCharacteristic:characteristic onSubscribedCentrals:nil];
}

- (BOOL)hasData{
    if ([mainData length]>0) {
        return YES;
    }else{
        return NO;
    }
}

- (void)ridData{
    if ([mainData length]>19) {
        mainData = [mainData subdataWithRange:NSRangeFromString(range)];
    }else{
        mainData = nil;
    }
}

- (NSData *)getNextData
{
    NSData *data;
    if ([mainData length]>19) {
        int datarest = [mainData length]-20;
        data = [mainData subdataWithRange:NSRangeFromString(@"{0,20}")];
        range = [NSString stringWithFormat:@"{20,%i}",datarest];
    }else{
        int datarest = [mainData length];
        range = [NSString stringWithFormat:@"{0,%i}",datarest];
        data = [mainData subdataWithRange:NSRangeFromString(range)];
    }
    return data;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSString *mainString = [NSString stringWithFormat:@"GN123"];
    NSData *cmainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    request.value = cmainData;
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    for (CBATTRequest *aReq in requests){
        //NSLog(@"%@",[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]);
        Log.text = [Log.text stringByAppendingString:[[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]];
        Log.text = [Log.text stringByAppendingString:@"\n"];
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
    }
}

- (void)willEnterBackgroud{
    [manager stopAdvertising];
    [centmanager stopScan];
}

- (void)willBacktoForeground{
    NSDictionary *advertisingData = @{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:@"EBA38950-0D9B-4DBA-B0DF-BC7196DD44FC"]]};
    [manager startAdvertising:advertisingData];
    [centmanager scanForPeripheralsWithServices:nil options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
