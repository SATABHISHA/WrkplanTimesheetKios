//
//  UserSingletonModel.swift
//  WrkplanTimesheetKiosk
//
//  Created by SATABHISHA ROY on 08/12/20.
//

import Foundation

class UserSingletonModel: NSObject {
    static let sharedInstance = UserSingletonModel()
    
    
    //------variables for login-------
    var PayrollClerkYN:Int!
    var UserType:String!
    var CorpID:String!
    var AdminYN:Int!
    var Msg:String!
    var PwdSetterId:Int!
    var EmpName:String!
    var UserRole:String!
    var SupervisorId:Int!
    var UserID:Int!
    var CompID:Int!
    var PayableClerkYN:Int!
    var UserName:String!
    var CompanyName:String!
    var FinYearID:String!
    var SupervisorYN:Int!
    var PurchaseYN:Int!
    var EmailId:String!
    var EmailServer:String!
    var EmailServerPort:String!
    var EmailSendingUsername:String!
    var EmailPassword:String!
    var EmailHostAddress:String!
}
