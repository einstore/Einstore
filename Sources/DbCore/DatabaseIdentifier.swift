//
//  DatabaseIdentifier.swift
//  Boost
//
//  Created by Ondrej Rafaj on 28/12/2017.
//

import Foundation
import Fluent
import FluentMySQL


extension DatabaseIdentifier {
    
    public static var db: DatabaseIdentifier<DbCoreDatabase> {
        return .init("db")
    }
    
}