//
//  TUDevice.swift
//  TCP-UDP-Debuger
//
//  Created by Steven on 15/10/22.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

extension UIDevice {
    class func localAddress() -> String {

        return "192.168.1.102"
//        NSString *address = @"an error occurred when obtaining ip address";
//        struct ifaddrs *interfaces = NULL;
//        struct ifaddrs *temp_addr = NULL;
//        int success = 0;
//        
//        success = getifaddrs(&interfaces);
//        
//        if (success == 0) { // 0 表示获取成功
//            
//            temp_addr = interfaces;
//            while (temp_addr != NULL) {
//                if( temp_addr->ifa_addr->sa_family == AF_INET) {
//                    // Check if interface is en0 which is the wifi connection on the iPhone
//                    if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
//                        // Get NSString from C String
//                        address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
//                    }
//                }
//                
//                temp_addr = temp_addr->ifa_next;
//            }  
//        }  
//        
//        freeifaddrs(interfaces);  
//        
//        DDLogVerbose(@"手机的IP是：%@", address);  
//        return address;  

    }
}