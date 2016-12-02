//
//  VIVRVivrCellProtocol.swift
//  vivr
//
//  Created by max blessen on 1/27/16.
//  Copyright © 2016 max blessen. All rights reserved.
//

import Foundation

protocol VivrCellDelegate {
    func tappedCommentButton(cell: vivrCell)
    func reloadAPI(cell: vivrCell)
    func tappedUserButton(cell: vivrCell)
    func helpfulTrue(cell: vivrCell)
    func helpfulFalse(cell: vivrCell)
    func wishlistTrue(cell: vivrCell)
    func wishlistFalse(cell: vivrCell)
    func tappedProductButton(cell: vivrCell)
    func tappedMoreButton(cell: vivrCell)
}