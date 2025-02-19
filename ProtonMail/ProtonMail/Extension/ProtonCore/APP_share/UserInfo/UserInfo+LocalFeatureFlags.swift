// Copyright (c) 2021 Proton AG
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

import ProtonCore_DataModel

extension UserInfo {
    static var isToolbarCustomizationEnable: Bool {
        if ProcessInfo.isRunningUnitTests {
            return true
        }
        if ProcessInfo.hasLaunchArgument(.disableToolbarSpotlight) {
            return false
        }
        return true
    }

    /// Swipe to show previous / next conversation or messages
    static var isConversationSwipeEnabled: Bool {
        #if DEBUG_ENTERPRISE
        return true
        #else
        return false
        #endif
    }

    // Highlight body without encrypted search will give a wrong impression to user that we can search body without ES
    static var isBodySearchKeywordHighlightEnabled: Bool {
        false
    }

    static var isSenderImageEnabled: Bool {
        return true
    }

    static var isBlockSenderEnabled: Bool {
        true
    }

    static var isAutoDeleteEnabled: Bool {
        #if DEBUG_ENTERPRISE
        true
        #else
        true
        #endif
    }
}
