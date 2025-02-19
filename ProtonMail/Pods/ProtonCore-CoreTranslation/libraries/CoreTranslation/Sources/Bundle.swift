//
//  Common.swift
//  ProtonCore-CoreTranslation - Created on 07.11.20.
//
//  Copyright (c) 2022 Proton Technologies AG
//
//  This file is part of Proton Technologies AG and ProtonCore.
//
//  ProtonCore is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonCore is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonCore.  If not, see <https://www.gnu.org/licenses/>.

import Foundation

public class Common {
    public static var bundle: Bundle {
        let bundle: Bundle
        #if SPM
        bundle = Bundle.module
        #else
        bundle = Bundle(path: Bundle(for: Common.self).path(forResource: "Resources-CoreTranslation", ofType: "bundle")!)!
        #endif
        return bundle
    }
}
