//
//  PMUIFoundations.swift
//  ProtonCore-UIFoundations - Created on 09.06.20.
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

#if canImport(ProtonCore_UIFoundations_Resources_iOS)
import ProtonCore_UIFoundations_Resources_iOS
#elseif canImport(ProtonCore_UIFoundations_Resources_macOS)
import ProtonCore_UIFoundations_Resources_macOS
#endif
import Foundation

public class PMUIFoundations {

    static let bundle = module ?? podsBundle ?? Bundle(for: PMUIFoundations.self)

    // Generated by SPM 5.3 on Xcode 12
    static var module: Bundle? = {
        
        #if SPM
        return spmResourcesBundle
        #else
        //        let bundleName = "PMUIFoundations_PMUIFoundations"
        let bundleName = "Resources-UIFoundations"
        
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: PMUIFoundations.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        return nil
        #endif
    }()

    private static var podsBundle: Bundle? {
        guard let url = Bundle(for: PMUIFoundations.self).url(forResource: String(describing: PMUIFoundations.self), withExtension: "bundle"), let bundle = Bundle(url: url) else {
            return nil
        }
        return bundle
    }

}
