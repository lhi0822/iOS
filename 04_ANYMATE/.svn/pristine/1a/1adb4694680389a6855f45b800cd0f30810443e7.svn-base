//
//  MinewBeaconManager.h
//  BeaconCFG
//
//  Created by SACRELEE on 18/09/2016.
//  Copyright © 2016 YLWL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MinewBeacon.h"

// bluetooth state enum.
typedef NS_ENUM( NSInteger, BluetoothState) {
    
    BluetoothStateUnknown = 0,   // can't get the state of bluetooth
    BluetoothStatePowerOn,       // bluetooth power on
    BluetoothStatePowerOff,      // bluetooth power off
    
};


@class MinewBeaconManager;


@protocol MinewBeaconManagerDelegate <NSObject>

@optional

/**
 *  listen the state of bluetooth
 *
 *  @param manager a manager instance
 *  @param state   current bluetooth state
 *
 * 블루투스 상태 듣기
 * @param manager 관리자 인스턴스
 * @param state 현재 블루투스 상태
 */
- (void)minewBeaconManager:(MinewBeaconManager *)manager didUpdateState:(BluetoothState)state;


/**
 *  if manager scanned some new beacons, this method will call back.
 *
 *  @param manager a manager instance.
 *  @param beacons all new beacons.
 *
 *  관리자가 일부 새 비콘을 스캔 한 경우이 메서드는 콜백합니다.
 * @param manager 관리자 인스턴스입니다.
 * @param beacons 모든 새로운 비콘입니다.
 */
- (void)minewBeaconManager:(MinewBeaconManager * )manager appearBeacons:(NSArray<MinewBeacon *> *)beacons;

/**
 *  if a beacon didn't update any data (such as rssi/battery etc.) after 8 seconds since last
 *  update time, the manager think it has already out of the scanning range, 
 *  so this method will call back.
 *
 *  @param manager a manager instance
 *  @param beacons all disappear beacons.
 *
 * 비콘이 마지막 이후 8 초 후에 데이터 (예 : rssi / battery 등)를 업데이트하지 않은 경우
 * 업데이트 시간, 관리자는 이미 스캔 범위를 벗어났다고 생각합니다.
 * 따라서이 메서드는 콜백합니다.
 * @param manager 관리자 인스턴스
 * @param beacons 모두 비콘이 사라집니다.
 */
- (void)minewBeaconManager:(MinewBeaconManager * )manager disappearBeacons:(NSArray<MinewBeacon *> *)beacons;

/**
 *  if the manager scanned some beacons,this method call back every 1 second for giving newest 
 *  data / UI refreshing and so on.
 *
 *  @param manager a manager instance
 *  @param beacons all scanned beacons.
 *
 * 관리자가 일부 비콘을 스캔 한 경우이 메서드는 1 초마다 호출하여 최신 정보를 제공합니다.
 * 데이터 / UI 새로 고침 등.
 * @param manager 관리자 인스턴스
 * @param beacons 스캔 된 모든 비콘입니다.
 */
- (void)minewBeaconManager:(MinewBeaconManager * )manager didRangeBeacons:(NSArray<MinewBeacon *> * )beacons;

@end


@interface MinewBeaconManager : NSObject

// delegate
@property (nonatomic, weak) id<MinewBeaconManagerDelegate> delegate;

// all beacons scanned. // 모든 비콘이 스캔됩니다.
@property (nonatomic, readonly, copy) NSArray<MinewBeacon *> *scannedBeacons;

// all beacons in range. // 범위 내의 모든 비콘.
@property (nonatomic, readonly, copy) NSArray<MinewBeacon *> *inRangeBeacons;

// 当前的蓝牙状态
@property (nonatomic, readonly, assign) BluetoothState bluetoothState;

// a sharedinstance of the manager.
+ (MinewBeaconManager  *)sharedInstance;

- (void)startScan;
- (void)stopScan;


@end
