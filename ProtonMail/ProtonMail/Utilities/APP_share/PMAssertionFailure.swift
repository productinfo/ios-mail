// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import ProtonMailAnalytics
import UIKit

func PMAssertionFailure(
    _ message: String,
    caller: StaticString = #function,
    file: StaticString = #file,
    line: UInt = #line
) {
#if !DEBUG
    Analytics.shared.sendError(
        .assertionFailure(message: message, caller: caller, file: file, line: line)
    )
#endif

    SystemLogger.log(
        message: message,
        category: .assertionFailure,
        isError: true,
        file: file,
        function: caller,
        line: Int(line),
        column: 0
    )

    // The `Swift.` is needed here since there is a compiler bug that will make it crash on release build.
    Swift.assertionFailure(message, file: file, line: line)
}

func PMAssertionFailure(
    _ error: Error,
    caller: StaticString = #function,
    file: StaticString = #file,
    line: UInt = #line
) {
    PMAssertionFailure("\(error)", caller: caller, file: file, line: line)
}

/// This will only call `PMAssertionFailure` if the backend is production.
func PMAssertionFailureIfBackendIsProduction(
    _ message: String,
    caller: StaticString = #function,
    file: StaticString = #file,
    line: UInt = #line
) {
    guard BackendConfiguration.shared.isProduction else { return }
    PMAssertionFailure(message, caller: caller, file: file, line: line)
}
