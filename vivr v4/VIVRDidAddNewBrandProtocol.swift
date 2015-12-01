//
//  VIVRDidAddNewBrandProtocol.swift
//  vivr
//
//  Created by max blessen on 12/1/15.
//  Copyright © 2015 max blessen. All rights reserved.
//

import Foundation


@objc protocol VIVRDidAddNewBrandProtocol {
    optional func brandCreated(brandName: String, brandID: Int)
    optional func checkInAnotherJuice()
}