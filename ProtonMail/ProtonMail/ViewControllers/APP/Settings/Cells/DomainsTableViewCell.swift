//
//  DomainsTableViewCell.swift
//  Proton Mail - Created on 3/17/15.
//
//
//  Copyright (c) 2019 Proton AG
//
//  This file is part of Proton Mail.
//
//  Proton Mail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Proton Mail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Proton Mail.  If not, see <https://www.gnu.org/licenses/>.

import UIKit

@IBDesignable class DomainsTableViewCell: UITableViewCell {
    @IBOutlet weak var domainText: UILabel!
    @IBOutlet weak var defaultMark: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

            self.domainText.font = UIFont.preferredFont(for: .footnote, weight: .regular)
            self.domainText.adjustsFontForContentSizeCategory = true

            self.defaultMark.font = UIFont.preferredFont(for: .footnote, weight: .regular)
            self.defaultMark.adjustsFontForContentSizeCategory = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
