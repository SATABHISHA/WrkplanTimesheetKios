//
//  Connectivity.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 08/12/20.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
