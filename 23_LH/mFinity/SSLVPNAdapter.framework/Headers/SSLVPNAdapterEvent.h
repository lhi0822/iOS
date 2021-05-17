//
//  SSLVPNAdapterEvent.h
//  SSLVPN Adapter


#import <Foundation/Foundation.h>

/**
 SSLVPN event codes
 */
typedef NS_ENUM(NSInteger, SSLVPNAdapterEvent) {
    SSLVPNAdapterEventDisconnected,
    SSLVPNAdapterEventConnected,
    SSLVPNAdapterEventReconnecting,
    SSLVPNAdapterEventResolve,
    SSLVPNAdapterEventWait,
    SSLVPNAdapterEventWaitProxy,
    SSLVPNAdapterEventConnecting,
    SSLVPNAdapterEventGetConfig,
    SSLVPNAdapterEventAssignIP,
    SSLVPNAdapterEventAddRoutes,
    SSLVPNAdapterEventEcho,
    SSLVPNAdapterEventInfo,
    SSLVPNAdapterEventPause,
    SSLVPNAdapterEventResume,
    SSLVPNAdapterEventRelay,
    SSLVPNAdapterEventUnknown
};
