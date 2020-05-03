//
//  NextScheduleOfStaff.swift
//  XWorkerBee
//
//  Created by MacbookPro on 11/2/19.
//  Copyright © 2019 XEP. All rights reserved.
//

import Foundation

struct NextScheduleOfStaff: Codable {
    let gio, noiDung, loaiNhacNho, tenCA: String
    let idCA, tieuDe: String
    
    enum CodingKeys: String, CodingKey {
        case gio = "Gio"
        case noiDung = "NoiDung"
        case loaiNhacNho = "LoaiNhacNho"
        case tenCA = "TenCa"
        case idCA = "idCa"
        case tieuDe = "TieuDe"
    }
}
