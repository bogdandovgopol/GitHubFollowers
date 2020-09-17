//
//  DateExtension.swift
//  GHFollowers
//
//  Created by Bogdan on 15/9/20.
//  Copyright © 2020 Bogdan. All rights reserved.
//

import Foundation

extension Date {
    
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        return dateFormatter.string(from: self)
    }
}
