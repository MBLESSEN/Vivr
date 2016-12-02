//
//  VIVRSearchDelegate.swift
//  vivr
//
//  Created by max blessen on 1/21/16.
//  Copyright © 2016 max blessen. All rights reserved.
//

import Foundation

protocol searchDelegate {
    func dismissSearch(view: VIVRSearchViewController, cell: ProductTableViewCell?)
    func hideKeyboard(view: VIVRSearchViewController)
    func reloadSearch()
    
}