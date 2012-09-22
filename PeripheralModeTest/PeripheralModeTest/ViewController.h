//
//  ViewController.h
//  PeripheralModeTest
//
//  Created by Khaos Tian on 6/12/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBPeripheralManager *manager;
    CBCentralManager *centmanager;
    CBMutableCharacteristic *characteristic;
    CBMutableCharacteristic *characteristic1;
    CBMutableCharacteristic *characteristic2;
    CBMutableService *servicea;
    NSData *mainData;
    NSString *range;
    
    CBPeripheral *aCperipheral;
}
@property (weak, nonatomic) IBOutlet UILabel *Label;
@property (weak, nonatomic) IBOutlet UITextView *Log;

- (void)willEnterBackgroud;
- (void)willBacktoForeground;

@end
