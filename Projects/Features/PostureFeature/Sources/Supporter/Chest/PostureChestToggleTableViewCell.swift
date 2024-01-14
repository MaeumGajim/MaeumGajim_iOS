import UIKit
import SnapKit
import Then
import DSKit
import RxSwift

public class PostureChestToggleTableViewCell: UITableViewCell {
    static let identifier: String = "PostureChestToggleTableViewCell"
    
    let disposeBag = DisposeBag()
    private var firstButtonCliked: Bool = false
    private var secondButtonCliked: Bool = false

    
    private var firstButton = MaeumGaGymToggleButton(type: .bareBody)
    private var secondButton = MaeumGaGymToggleButton(type: .marchine)
    
    public func setup(firstType: ToggleButtonType, secondType: ToggleButtonType) {
        self.firstButton = MaeumGaGymToggleButton(type: firstType)
        self.secondButton = MaeumGaGymToggleButton(type: secondType)
        
        addViews()
        setupViews()
        bind(firstType: firstType, secondType: secondType)
    }
    
    private func addViews() {
        [
            firstButton, 
            secondButton
        ].forEach { contentView.addSubview($0) }
    }
    
    private func setupViews() {
        firstButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12.0)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60.0)
            $0.height.equalTo(36.0)
        }
        
        secondButton.snp.makeConstraints {
            $0.leading.equalTo(firstButton.snp.trailing).offset(8.0)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60.0)
            $0.height.equalTo(36.0)
        }
    }
    
    private func bind(firstType: ToggleButtonType, secondType: ToggleButtonType) {
        firstButton.rx.tap
            .subscribe(onNext: {
                switch self.firstButtonCliked {
                case false:
                    self.firstButton.buttonYesChecked(type: firstType)
                    self.secondButton.buttonNoChecked(type: secondType)
                    self.firstButtonCliked = true
                    self.secondButtonCliked = false
                case true:
                    self.firstButton.buttonNoChecked(type: firstType)
                    self.secondButton.buttonNoChecked(type: secondType)
                    self.firstButtonCliked = false
                    self.secondButtonCliked = false
                }
            }).disposed(by: disposeBag)
        
        secondButton.rx.tap
            .subscribe(onNext: {
                switch self.firstButtonCliked {
                case false:
                    self.firstButton.buttonYesChecked(type: secondType)
                    self.secondButton.buttonNoChecked(type: firstType)
                    self.secondButtonCliked = true
                    self.firstButtonCliked = false
                case true:
                    self.firstButton.buttonNoChecked(type: secondType)
                    self.secondButton.buttonNoChecked(type: firstType)
                    self.secondButtonCliked = false
                    self.firstButtonCliked = false
                }
            }).disposed(by: disposeBag)
    }

}
