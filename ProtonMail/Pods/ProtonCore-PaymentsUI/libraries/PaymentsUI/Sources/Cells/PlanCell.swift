//
//  PlanCell.swift
//  ProtonCore_PaymentsUI - Created on 01/06/2021.
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

import UIKit
import ProtonCore_UIFoundations
import ProtonCore_Foundations
import ProtonCore_CoreTranslation

protocol PlanCellDelegate: AnyObject {
    func userPressedSelectPlanButton(plan: PlanPresentation, completionHandler: @escaping () -> Void)
    func cellDidChange(indexPath: IndexPath)
}

final class PlanCell: UITableViewCell, AccessibleCell {

    static let reuseIdentifier = "PlanCell"
    static let nib = UINib(nibName: "PlanCell", bundle: PaymentsUI.bundle)
    
    weak var delegate: PlanCellDelegate?
    var plan: PlanPresentation?
    var indexPath: IndexPath?
    var isSignup = false

    // MARK: - Outlets
    
    @IBOutlet weak var mainView: UIView! {
        didSet {
            mainView.layer.cornerRadius = 12.0
        }
    }
    @IBOutlet weak var planNameLabel: UILabel! {
        didSet {
            planNameLabel.textColor = ColorProvider.TextNorm
        }
    }
    @IBOutlet weak var offerPercentageView: UIView! {
        didSet {
            offerPercentageView.roundCorner(8.0)
            offerPercentageView.backgroundColor = ColorProvider.InteractionWeak
        }
    }
    @IBOutlet weak var offerPercentageLabel: UILabel! {
        didSet {
            offerPercentageLabel.textColor = ColorProvider.TextAccent
        }
    }
    @IBOutlet weak var offerDescriptionView: UIView! {
        didSet {
            offerDescriptionView.roundCorner(8.0)
            offerDescriptionView.backgroundColor = ColorProvider.TextAccent
        }
    }
    @IBOutlet weak var offerDescriptionLabel: UILabel! {
        didSet {
            offerDescriptionLabel.textColor = ColorProvider.BackgroundSecondary
        }
    }
    @IBOutlet weak var preferredImageView: UIImageView!
    
    @IBOutlet weak var planDescriptionLabel: UILabel! {
        didSet {
            planDescriptionLabel.textColor = ColorProvider.TextWeak
            planDescriptionLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.textColor = ColorProvider.TextNorm
        }
    }
    @IBOutlet weak var priceDescriptionLabel: UILabel! {
        didSet {
            priceDescriptionLabel.textColor = ColorProvider.TextWeak
        }
    }
    @IBOutlet weak var planDetailsStackView: UIStackView!
    @IBOutlet weak var detailsSpacerView: UIView!
    @IBOutlet weak var buttonSpacerView: UIView!
    @IBOutlet weak var selectPlanButton: ProtonButton! {
        didSet {
            selectPlanButton.isAccessibilityElement = true
            selectPlanButton.setMode(mode: .solid)
        }
    }
    @IBOutlet weak var expandButton: ProtonButton! {
        didSet {
            expandButton.setMode(mode: .image(type: .chevron))
            expandButton.isAccessibilityElement = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        planNameLabel.font = .adjustedFont(forTextStyle: .headline, weight: .semibold)
        planDescriptionLabel.font = .adjustedFont(forTextStyle: .footnote)
        offerPercentageLabel.font = .adjustedFont(forTextStyle: .footnote, weight: .semibold)
        offerDescriptionLabel.font = .adjustedFont(forTextStyle: .footnote, weight: .semibold)
        priceLabel.font = .adjustedFont(forTextStyle: .title2, weight: .bold)
        priceDescriptionLabel.font = .adjustedFont(forTextStyle: .footnote)
    }
    // MARK: - Properties
    
    func configurePlan(plan: PlanPresentation, indexPath: IndexPath, isSignup: Bool, isExpandButtonHidden: Bool) {
        planDetailsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard case PlanPresentationType.plan(let planDetails) = plan.planPresentationType else { return }
        self.plan = plan
        self.indexPath = indexPath
        self.isSignup = isSignup
        if isExpandButtonHidden {
            expandButton.isHidden = true
            plan.isExpanded = true
        }
        handleProcessedPlanWhenIsNeeded(plan: plan)
        generateCellAccessibilityIdentifiers(planDetails.name)
        
        planNameLabel.text = planDetails.name
        switch planDetails.highlight {
        case .no:
            preferredImageView.isHidden = true
            offerPercentageView.isHidden = true
            offerDescriptionView.isHidden = true
        case .preferred:
            preferredImageView.isHidden = false
            preferredImageView.tintColor = ColorProvider.InteractionNorm
            preferredImageView.image = IconProvider.starFilled
            offerPercentageView.isHidden = true
            offerDescriptionView.isHidden = true
        case let .offer(percentage, description):
            preferredImageView.isHidden = true
            if let percentage {
                offerPercentageLabel.text = percentage
                offerPercentageView.isHidden = false
            } else {
                offerPercentageView.isHidden = true
            }
            offerDescriptionLabel.text = description
            offerDescriptionView.isHidden = false
        }
        if let title = planDetails.title {
            planDescriptionLabel.text = title
        } else {
            planDescriptionLabel.isHidden = true
        }
        
        if let price = planDetails.price {
            priceLabel.isHidden = false
            priceDescriptionLabel.isHidden = false
            priceLabel.text = price
            priceDescriptionLabel.text = planDetails.cycle
        } else {
            priceLabel.isHidden = true
            priceDescriptionLabel.isHidden = true
        }
        planDetails.details.forEach {
            let detailView = PlanDetailView()
            detailView.configure(icon: $0.0.icon, text: $0.1)
            planDetailsStackView.addArrangedSubview(detailView)
        }
        drawView()
        drawAlphas()
    }
    
    func selectCell() {
        guard !expandButton.isHidden else { return }
        expandCollapseCell()
    }
    
    func showExpandButton() {
        expandButton.isHidden = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let plan = plan, case PlanPresentationType.plan(let planDetails) = plan.planPresentationType else { return }
        configureMainView(isSelectable: planDetails.isSelectable)
    }
    
    // MARK: - Actions
    
    @IBAction func onSelectPlanButtonTap(_ sender: ProtonButton) {
        if let plan = plan {
            selectPlanButton.isSelected = true
            delegate?.userPressedSelectPlanButton(plan: plan) {
                DispatchQueue.main.async {
                    self.selectPlanButton.isSelected = false
                }
            }
        }
    }
    
    @IBAction func onExpandButtonTap(_ sender: UIButton) {
        expandCollapseCell()
    }
    
    // MARK: Private interface
    
    private func drawView() {
        guard let plan = plan, case PlanPresentationType.plan(let planDetails) = plan.planPresentationType else { return }
        detailsSpacerView.isHidden = !planDetails.isSelectable || !plan.isExpanded
        buttonSpacerView.isHidden = !planDetails.isSelectable || !plan.isExpanded
        selectPlanButton.isHidden = !planDetails.isSelectable || !plan.isExpanded
        planDetailsStackView.isHidden = !planDetails.isSelectable || !plan.isExpanded
        expandButton.isSelected = plan.isExpanded

        if plan.accountPlan.isFreePlan {
            selectPlanButton.setTitle(CoreString._get_free_plan_button, for: .normal)
        } else {
            selectPlanButton.setTitle(String(format: CoreString._get_plan_button, planDetails.name), for: .normal)
        }
        if planDetails.isSelectable {
            priceLabel.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        } else {
            priceLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        }
        configureMainView(isSelectable: planDetails.isSelectable)
    }
    
    private func configureMainView(isSelectable: Bool) {
        guard let plan = plan else { return }
        if isSelectable {
            if plan.isExpanded {
                mainView.layer.borderWidth = 1.0
                mainView.layer.borderColor = ColorProvider.InteractionNorm
            } else {
                mainView.layer.borderWidth = 0.0
            }
            mainView.backgroundColor = ColorProvider.BackgroundSecondary
        } else {
            mainView.layer.borderWidth = 1.0
            mainView.layer.borderColor = ColorProvider.SeparatorNorm
        }
    }
    
    func drawAlphas() {
        guard let plan = plan else { return }
        selectPlanButton.alpha = plan.isExpanded ? 1 : 0
        planDetailsStackView.alpha = plan.isExpanded ? 1 : 0
    }
    
    private func expandCollapseCell() {
        plan?.isExpanded.toggle()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.drawView()
        })
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.curveEaseIn],
                       animations: { [weak self] in
            self?.drawAlphas()
        })
        guard let indexPath = indexPath else { return }
        delegate?.cellDidChange(indexPath: indexPath)
    }
    
    private func handleProcessedPlanWhenIsNeeded(plan: PlanPresentation) {
        guard plan.isCurrentlyProcessed else { return }
        // already processing plan
        if !plan.isExpanded {
            plan.isExpanded = true
        }
        selectPlanButton.isSelected = true
        isUserInteractionEnabled = false
        guard let indexPath = indexPath else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.cellDidChange(indexPath: indexPath)
        }
    }
}
